#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra và cài đặt expect nếu chưa có
if ! command -v expect &>/dev/null; then
  echo "Expect chưa được cài đặt. Đang tiến hành cài đặt..."
  if [ -x "$(command -v apt-get)" ]; then
    apt-get update && apt-get install -y expect
  elif [ -x "$(command -v yum)" ]; then
    yum install -y expect
  else
    echo "Error: Không thể xác định trình quản lý gói để cài đặt expect."
    exit 1
  fi
fi

# Kiểm tra và cài đặt Pure-FTPd nếu chưa có
if ! command -v pure-pw &>/dev/null; then
  echo "Pure-FTPd chưa được cài đặt. Đang tiến hành cài đặt..."
  if [ -x "$(command -v apt-get)" ]; then
    apt-get update && apt-get install -y pure-ftpd
  elif [ -x "$(command -v yum)" ]; then
    yum install -y pure-ftpd
  else
    echo "Error: Không thể xác định trình quản lý gói để cài đặt Pure-FTPd."
    exit 1
  fi
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"
FTP_HOME="/var/www"
FTP_SHELL="/sbin/nologin"
PURE_FTPD_CONF="/etc/pure-ftpd/pure-ftpd.conf"

# Cấu hình dải port Passive
PASSIVE_PORT_START=49152
PASSIVE_PORT_END=65535

# Đảm bảo shell tồn tại trong /etc/shells
if ! grep -q "^$FTP_SHELL$" /etc/shells; then
  echo "Thêm $FTP_SHELL vào /etc/shells..."
  echo "$FTP_SHELL" >>/etc/shells
fi

# Cập nhật pure-ftpd.conf
update_pure_ftpd_config() {
  echo "Cập nhật tệp cấu hình Pure-FTPd..."

  if [ ! -f "$PURE_FTPD_CONF" ]; then
    echo "Error: Không tìm thấy tệp cấu hình $PURE_FTPD_CONF."
    exit 1
  fi

  # Thêm hoặc cập nhật cấu hình chroot và dải PassivePortRange
  sed -i "s/^.*ChrootEveryone.*/ChrootEveryone yes/" "$PURE_FTPD_CONF"
  sed -i "s/^.*PassivePortRange.*/PassivePortRange $PASSIVE_PORT_START $PASSIVE_PORT_END/" "$PURE_FTPD_CONF"

  # Nếu không có, thêm mới
  if ! grep -q "^ChrootEveryone" "$PURE_FTPD_CONF"; then
    echo "ChrootEveryone yes" >>"$PURE_FTPD_CONF"
  fi
  if ! grep -q "^PassivePortRange" "$PURE_FTPD_CONF"; then
    echo "PassivePortRange $PASSIVE_PORT_START $PASSIVE_PORT_END" >>"$PURE_FTPD_CONF"
  fi

  # Thêm hoặc cập nhật cấu hình thời gian chờ và dải PassivePortRange
  sed -i "s/^.*TimeoutIdle.*/TimeoutIdle 600/" "$PURE_FTPD_CONF"
  sed -i "s/^.*TimeoutNoTransfer.*/TimeoutNoTransfer 600/" "$PURE_FTPD_CONF"
  sed -i "s/^.*TimeoutStalled.*/TimeoutStalled 600/" "$PURE_FTPD_CONF"
  sed -i "s/^.*PassivePortRange.*/PassivePortRange $PASSIVE_PORT_START $PASSIVE_PORT_END/" "$PURE_FTPD_CONF"

  # Nếu không có, thêm mới
  if ! grep -q "^TimeoutIdle" "$PURE_FTPD_CONF"; then
    echo "TimeoutIdle 600" >>"$PURE_FTPD_CONF"
  fi
  if ! grep -q "^TimeoutNoTransfer" "$PURE_FTPD_CONF"; then
    echo "TimeoutNoTransfer 600" >>"$PURE_FTPD_CONF"
  fi
  if ! grep -q "^TimeoutStalled" "$PURE_FTPD_CONF"; then
    echo "TimeoutStalled 600" >>"$PURE_FTPD_CONF"
  fi
  if ! grep -q "^PassivePortRange" "$PURE_FTPD_CONF"; then
    echo "PassivePortRange $PASSIVE_PORT_START $PASSIVE_PORT_END" >>"$PURE_FTPD_CONF"
  fi

  echo "Tệp cấu hình Pure-FTPd đã được cập nhật."
}

# Mở dải port trong UFW
open_ports_ufw() {
  echo "Mở dải port $PASSIVE_PORT_START-$PASSIVE_PORT_END trong UFW..."
  if command -v ufw &>/dev/null; then
    ufw allow "$PASSIVE_PORT_START:$PASSIVE_PORT_END/tcp"
    ufw reload
    echo "Đã mở dải port trong UFW."
  else
    echo "Warning: UFW không được cài đặt, bỏ qua bước này."
  fi
}

# Hàm để thêm tài khoản FTP
add_account() {

  # Kiểm tra đủ 3 tham số
  if [ "$#" -lt 3 ]; then
    echo "Error: Hàm add_account yêu cầu 3 tham số: username, password, và thư mục."
    echo "Sử dụng: add_account <username> <password> <directory>"
    return 1
  fi

  local username="$1"
  local password="$2"
  local directory="$FTP_HOME/$3"

  # Đảm bảo đường dẫn là tuyệt đối
  if [[ "$directory" != /* ]]; then
    directory="/$directory"
  fi

  # Kiểm tra xem tài khoản đã tồn tại chưa
  if grep -q "^$username:" "$FTP_USER_FILE"; then
    echo "Error: Tài khoản $username đã tồn tại."
    return 1
  fi

  # Tạo tài khoản hệ thống và thiết lập thư mục FTP riêng
  if ! useradd -m -d "$directory" -s "$FTP_SHELL" "$username"; then
    echo "Error: Không thể tạo tài khoản hệ thống $username."
    return 1
  fi

  # Tự động nhập mật khẩu cho lệnh chpasswd
  if ! echo "$username:$password" | chpasswd; then
    echo "Error: Không thể đặt mật khẩu cho tài khoản $username."
    return 1
  fi

  # Thêm tài khoản vào tệp theo dõi tài khoản FTP
  echo "$username:$password" >>"$FTP_USER_FILE"

  # Thiết lập quyền thư mục
  mkdir -p "$directory"

  chmod 770 "$directory"
  chown -R "$username:$username" "$directory"

  # Thêm tài khoản vào tệp theo dõi tài khoản FTP
  echo "$username:$password:$directory" >>"$FTP_USER_FILE"

  # Tạo tài khoản FTP trong cơ sở dữ liệu Pure-FTPd bằng expect
  uid=$(id -u "$username")
  gid=$(id -g "$username")

  expect -c "
  spawn pure-pw useradd $username -u $uid -g $gid -d $directory
  expect \"Password:\"
  send \"$password\r\"
  expect \"Repeat password:\"
  send \"$password\r\"
  expect eof
  " || {
    echo "Error: Không thể thêm tài khoản FTP $username vào Pure-FTPd."
    return 1
  }

  # Cập nhật cơ sở dữ liệu của Pure-FTPd
  pure-pw mkdb || {
    echo "Error: Không thể cập nhật cơ sở dữ liệu của Pure-FTPd."
    return 1
  }

  echo "Tài khoản FTP $username đã được thêm thành công với đầy đủ quyền."
}

# Khởi động lại Pure-FTPd
restart_pure_ftpd() {
  echo "Khởi động lại Pure-FTPd để áp dụng thay đổi..."
  systemctl restart pure-ftpd || {
    echo "Error: Không thể khởi động lại Pure-FTPd."
    exit 1
  }
  echo "Pure-FTPd đã được khởi động lại."
}

# Gọi các hàm để thực hiện
update_pure_ftpd_config
open_ports_ufw
restart_pure_ftpd

# Gọi hàm thêm tài khoản FTP nếu cần
add_account "$1" "$2" "$3"
