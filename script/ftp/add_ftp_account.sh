#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Hàm kiểm tra và cài đặt gói
install_package() {
  local package="$1"
  if ! command -v "$package" &>/dev/null; then
    echo "$package chưa được cài đặt. Đang tiến hành cài đặt..."
    if [ -x "$(command -v apt-get)" ]; then
      apt-get update && apt-get install -y "$package"
    elif [ -x "$(command -v yum)" ]; then
      yum install -y "$package"
    else
      echo "Error: Không thể xác định trình quản lý gói để cài đặt $package."
      exit 1
    fi
  fi
}

# Hàm cài đặt Pure-FTPd mới nhất từ mã nguồn
install_pureftpd_latest() {
  echo "Cài đặt phiên bản mới nhất của Pure-FTPd..."
  local temp_dir="/tmp/pure-ftpd"
  mkdir -p "$temp_dir"
  cd "$temp_dir" || exit 1

  # Tải mã nguồn Pure-FTPd mới nhất
  curl -LO https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-latest.tar.gz
  if [ $? -ne 0 ]; then
    echo "Error: Không thể tải mã nguồn Pure-FTPd."
    exit 1
  fi

  # Giải nén và cài đặt
  tar -xzf pure-ftpd-latest.tar.gz
  cd pure-ftpd-* || exit 1
  ./configure --prefix=/usr --sysconfdir=/etc --with-puredb --with-tls
  make && make install
  if [ $? -ne 0 ]; then
    echo "Error: Không thể cài đặt Pure-FTPd từ mã nguồn."
    exit 1
  fi

  echo "Pure-FTPd đã được cài đặt thành công từ mã nguồn."
  cd / || exit 1
  rm -rf "$temp_dir"
}

# Cài đặt expect và Pure-FTPd nếu chưa có
install_package "expect"
if ! command -v pure-ftpd &>/dev/null; then
  install_pureftpd_latest
else
  echo
fi

# Biến cấu hình
FTP_USER_FILE="/etc/ftp_users.txt"
FTP_HOME="/var/www"
FTP_SHELL="/sbin/nologin"
PURE_FTPD_CONF="/etc/pure-ftpd/pure-ftpd.conf"
PASSIVE_PORT_START=49152
PASSIVE_PORT_END=65535

# Đảm bảo shell tồn tại trong /etc/shells
if ! grep -q "^$FTP_SHELL$" /etc/shells; then
  echo "$FTP_SHELL" >>/etc/shells
fi

# Cập nhật pure-ftpd.conf
update_pure_ftpd_config() {
  echo "Cập nhật tệp cấu hình Pure-FTPd..."
  [ ! -f "$PURE_FTPD_CONF" ] && {
    echo "Error: Không tìm thấy tệp cấu hình $PURE_FTPD_CONF."
    exit 1
  }

  declare -A config_map=(
    ["ChrootEveryone"]="yes"
    ["PassivePortRange"]="$PASSIVE_PORT_START $PASSIVE_PORT_END"
    ["TimeoutIdle"]="600"
    ["TimeoutNoTransfer"]="600"
    ["TimeoutStalled"]="600"
  )

  for key in "${!config_map[@]}"; do
    if grep -q "^$key" "$PURE_FTPD_CONF"; then
      sed -i "s/^$key.*/$key ${config_map[$key]}/" "$PURE_FTPD_CONF"
    else
      echo "$key ${config_map[$key]}" >>"$PURE_FTPD_CONF"
    fi
  done

  echo "Tệp cấu hình Pure-FTPd đã được cập nhật."
}

# Mở dải port trong UFW
open_ports_ufw() {
  if command -v ufw &>/dev/null; then
    if ! ufw status | grep -q "$PASSIVE_PORT_START:$PASSIVE_PORT_END/tcp"; then
      ufw allow "$PASSIVE_PORT_START:$PASSIVE_PORT_END/tcp"
      ufw reload
      echo "Đã mở dải port trong UFW."
    fi
  else
    echo "Warning: UFW không được cài đặt, bỏ qua bước này."
  fi
}

# Hàm để thêm tài khoản FTP
add_account() {
  if [ "$#" -lt 3 ]; then
    echo "Error: Hàm add_account yêu cầu 3 tham số: username, password, và thư mục."
    echo "Sử dụng: add_account <username> <password> <directory>"
    return 1
  fi

  local username="$1"
  local password="$2"
  local directory="$FTP_HOME/$3"

  directory="${directory#/}" # Đảm bảo đường dẫn không bắt đầu bằng "/"
  directory="/$directory"

  if grep -q "^$username:" "$FTP_USER_FILE"; then
    echo "Error: Tài khoản $username đã tồn tại."
    return 1
  fi

  if ! id -u "$username" &>/dev/null; then
    useradd -m -d "$directory" -s "$FTP_SHELL" "$username" || {
      echo "Error: Không thể tạo tài khoản hệ thống $username."
      return 1
    }
    echo "$username:$password" | chpasswd || {
      echo "Error: Không thể đặt mật khẩu cho tài khoản $username."
      return 1
    }
  fi

  mkdir -p "$directory"
  chmod 770 "$directory"
  chown -R "$username:$username" "$directory"

  echo "$username:$password:$directory" >>"$FTP_USER_FILE"

  local uid gid
  uid=$(id -u "$username")
  gid=$(id -g "$username")

  if ! pure-pw show "$username" &>/dev/null; then
    expect -c "
    spawn pure-pw useradd $username -u $uid -g $gid -d $directory -r
    expect \"Password:\"
    send \"$password\r\"
    expect \"Repeat password:\"
    send \"$password\r\"
    expect eof
    " || {
      echo "Error: Không thể thêm tài khoản FTP $username vào Pure-FTPd."
      return 1
    }
    pure-pw mkdb || {
      echo "Error: Không thể cập nhật cơ sở dữ liệu Pure-FTPd."
      return 1
    }
  fi

  echo "$username" >> /etc/pure-ftpd/conf/ChrootUsers
  echo "Tài khoản FTP $username đã được thêm thành công với đầy đủ quyền."
}

# Khởi động lại Pure-FTPd
restart_pure_ftpd() {
  systemctl restart pure-ftpd || {
    echo "Error: Không thể khởi động lại Pure-FTPd."
    exit 1
  }
  echo "Pure-FTPd đã được khởi động lại."
}

# Thực thi các ham chính
update_pure_ftpd_config
open_ports_ufw
restart_pure_ftpd
add_account "$1" "$2" "$3"
