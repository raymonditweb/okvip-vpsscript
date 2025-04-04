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
  
  # Cài đặt với các tùy chọn bảo mật cao hơn
  ./configure --prefix=/usr \
    --sysconfdir=/etc \
    --with-puredb \
    --with-tls \
    --with-virtualchroot \
    --with-privsep \
    --with-peruserlimits
    
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
  echo "Pure-FTPd đã được cài đặt."
fi

# Biến cấu hình
FTP_USER_FILE="/etc/ftp_users.txt"
FTP_HOME="/var/www"  # Giữ nguyên thư mục này theo yêu cầu
FTP_SHELL="/sbin/nologin"
PURE_FTPD_CONF="/etc/pure-ftpd/pure-ftpd.conf"
PURE_FTPD_AUTH_DIR="/etc/pure-ftpd/auth"
PURE_FTPD_CONF_DIR="/etc/pure-ftpd/conf"
PASSIVE_PORT_START=49152
PASSIVE_PORT_END=65535

# Tạo thư mục cấu hình nếu chưa tồn tại
mkdir -p "$PURE_FTPD_CONF_DIR"
mkdir -p "$PURE_FTPD_AUTH_DIR"
mkdir -p "$FTP_HOME"

# Đảm bảo shell tồn tại trong /etc/shells
if ! grep -q "^$FTP_SHELL$" /etc/shells; then
  echo "$FTP_SHELL" >>/etc/shells
fi

# Cập nhật pure-ftpd.conf
update_pure_ftpd_config() {
  echo "Cập nhật tệp cấu hình Pure-FTPd..."
  
  # Tạo các tệp cấu hình riêng lẻ
  echo "yes" > "$PURE_FTPD_CONF_DIR/ChrootEveryone"
  echo "$PASSIVE_PORT_START $PASSIVE_PORT_END" > "$PURE_FTPD_CONF_DIR/PassivePortRange"
  echo "600" > "$PURE_FTPD_CONF_DIR/TimeoutIdle"
  echo "600" > "$PURE_FTPD_CONF_DIR/TimeoutNoTransfer"
  echo "600" > "$PURE_FTPD_CONF_DIR/TimeoutStalled"
  echo "yes" > "$PURE_FTPD_CONF_DIR/NoAnonymous"
  echo "yes" > "$PURE_FTPD_CONF_DIR/NoChmod"  # Không cho phép thay đổi quyền
  echo "yes" > "$PURE_FTPD_CONF_DIR/NoSymlinks"  # Không cho phép symlinks
  echo "yes" > "$PURE_FTPD_CONF_DIR/VerboseLog"  # Log chi tiết hơn
  echo "puredb:$PURE_FTPD_AUTH_DIR/pureftpd.pdb" > "$PURE_FTPD_CONF_DIR/PureDB"
  echo "yes" > "$PURE_FTPD_CONF_DIR/CreateHomeDir"  # Tự động tạo thư mục home nếu không tồn tại
  
  # Bật TLS nếu có thể
  if [ -f "/etc/ssl/private/pure-ftpd.pem" ]; then
    echo "1" > "$PURE_FTPD_CONF_DIR/TLS"
  fi
  
  echo "Tệp cấu hình Pure-FTPd đã được cập nhật."
}

# Tạo chứng chỉ SSL nếu chưa có
create_ssl_cert() {
  if [ ! -f "/etc/ssl/private/pure-ftpd.pem" ]; then
    echo "Tạo chứng chỉ SSL tự ký cho Pure-FTPd..."
    mkdir -p /etc/ssl/private
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
      -keyout /etc/ssl/private/pure-ftpd.pem \
      -out /etc/ssl/private/pure-ftpd.pem \
      -subj "/C=VN/ST=Local/L=Local/O=PureFTPd/CN=localhost" 
    chmod 600 /etc/ssl/private/pure-ftpd.pem
    echo "Đã tạo chứng chỉ SSL."
  fi
}

# Mở dải port trong UFW
open_ports_ufw() {
  if command -v ufw &>/dev/null; then
    if ! ufw status | grep -q "$PASSIVE_PORT_START:$PASSIVE_PORT_END/tcp"; then
      ufw allow 21/tcp comment "Pure-FTPd"
      ufw allow "$PASSIVE_PORT_START:$PASSIVE_PORT_END/tcp" comment "Pure-FTPd passive ports"
      ufw reload
      echo "Đã mở cổng FTP trong UFW."
    fi
  else
    echo "Warning: UFW không được cài đặt, bỏ qua bước này."
  fi
}

# Hàm để thêm tài khoản FTP với bảo mật hơn
add_account() {
  if [ "$#" -lt 3 ]; then
    echo "Error: Hàm add_account yêu cầu 3 tham số: username, password, và thư mục."
    echo "Sử dụng: add_account <username> <password> <directory>"
    return 1
  fi

  local username="$1"
  local password="$2"
  local directory="$3"
  
  # Đảm bảo đường dẫn thư mục là tương đối và không có dấu / ở đầu
  directory="/$directory"
  
  # Đường dẫn đầy đủ tới thư mục home của user FTP
  local full_path="$FTP_HOME/$directory"

  if grep -q "^$username:" "$FTP_USER_FILE" 2>/dev/null; then
    echo "Error: Tài khoản $username đã tồn tại."
    return 1
  fi

  # Tạo thư mục nếu chưa tồn tại
  mkdir -p "$directory"
  if [ -d "$full_path" ]; then
  echo "📁 Thư mục $full_path đã tồn tại. Sẽ sao chép sang $directory"

  cp -a "$full_path/." "$directory/"
fi
  
  # Tạo tài khoản hệ thống nếu chưa tồn tại
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
  chmod 750 "$directory"  # Giảm quyền xuống chỉ read/write/execute cho owner, read/execute cho group
  chown -R "$username:$username" "$directory"

  # Thêm vào file quản lý
  echo "$username:$password:$directory" >>"$FTP_USER_FILE"

  local uid gid
  uid=$(id -u "$username")
  gid=$(id -g "$username")

  # Thêm vào Pure-FTPd database
  if ! pure-pw show "$username" &>/dev/null; then
    expect -c "
    spawn pure-pw useradd $username -u $uid -g $gid -d $directory -m
    expect \"Password:\"
    send \"$password\r\"
    expect \"Repeat password:\"
    send \"$password\r\"
    expect eof
    " || {
      echo "Error: Không thể thêm tài khoản FTP $username vào Pure-FTPd."
      return 1
    }
    pure-pw mkdb "$PURE_FTPD_AUTH_DIR/pureftpd.pdb" || {
      echo "Error: Không thể cập nhật cơ sở dữ liệu Pure-FTPd."
      return 1
    }
  fi

  echo "Tài khoản FTP $username đã được thêm thành công với quyền giới hạn trong thư mục $full_path."
}

# Khởi động lại Pure-FTPd
restart_pure_ftpd() {
  echo "Đang khởi động lại Pure-FTPd..."

  if systemctl list-unit-files | grep -q "pure-ftpd.service"; then
    systemctl restart pure-ftpd || {
      echo "Error: Không thể khởi động lại Pure-FTPd service."
      exit 1
    }
  else
    echo "⚙️ Không có systemd service, chạy trực tiếp..."
    killall -9 pure-ftpd 2>/dev/null || true

    pure-ftpd \
      -l puredb:/etc/pure-ftpd/auth/pureftpd.pdb \
      -B -C 10 -c 50 -E -H -R -Y 2 -A -j -u 1000 || {
        echo "Error: Không thể khởi động Pure-FTPd thủ công."
        exit 1
      }
  fi

  echo "✅ Pure-FTPd đã được khởi động lại."
}


# Tạo systemd service nếu chưa có
create_systemd_service() {
  if [ ! -f "/etc/systemd/system/pure-ftpd.service" ]; then
    cat > "/etc/systemd/system/pure-ftpd.service" << EOF
[Unit]
Description=Pure-FTPd FTP server
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/pure-ftpd -B -C 10 -c 50 -E -H -R -Y 2
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable pure-ftpd
    echo "Đã tạo và kích hoạt systemd service cho Pure-FTPd."
  fi
}

# Vô hiệu hóa anonymous access
disable_anonymous() {
  if [ -d "/var/ftp" ] || [ -d "/srv/ftp" ]; then
    chmod 000 /var/ftp /srv/ftp 2>/dev/null || true
  fi
}

# Thực thi các hàm chính
update_pure_ftpd_config
create_ssl_cert
open_ports_ufw
create_systemd_service
disable_anonymous
restart_pure_ftpd

# Kiểm tra tham số dòng lệnh và thêm tài khoản nếu đủ
if [ $# -ge 3 ]; then
  add_account "$1" "$2" "$3"
  restart_pure_ftpd
else
  echo "Sử dụng: $0 <username> <password> <directory>"
  echo "Ví dụ: $0 user1 password123 site1"
fi