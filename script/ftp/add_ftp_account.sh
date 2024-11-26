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
    apt-get update && apt-get install -y expect # Trên Ubuntu/Debian
  elif [ -x "$(command -v yum)" ]; then
    yum install -y expect # Trên CentOS/RHEL
  else
    echo "Error: : Không thể xác định trình quản lý gói để cài đặt expect."
    exit 1
  fi
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"
DEFAULT_USERNAME="default_user"
DEFAULT_PASSWORD="default_password"
FTP_HOME="/home/ftp_users"

# Hàm để thêm tài khoản FTP
add_account() {
  local username="${1:-$DEFAULT_USERNAME}"
  local password="${2:-$DEFAULT_PASSWORD}"

  # Kiểm tra xem tài khoản đã tồn tại chưa
  if grep -q "^$username:" "$FTP_USER_FILE"; then
    echo "Error: Tài khoản $username đã tồn tại."
  else
    # Tạo tài khoản hệ thống và thiết lập thư mục FTP riêng
    useradd -m -d "$FTP_HOME/$username" -s /sbin/nologin "$username"

    # Tự động nhập mật khẩu cho lệnh chpasswd
    echo "$username:$password" | chpasswd

    # Thêm tài khoản vào tệp theo dõi tài khoản FTP
    echo "$username:$password" >>"$FTP_USER_FILE"

    # Thiết lập quyền thư mục
    mkdir -p "$FTP_HOME/$username"
    chown "$username:$username" "$FTP_HOME/$username"
    chmod 755 "$FTP_HOME/$username"

    # Tạo tài khoản FTP trong cơ sở dữ liệu Pure-FTPd bằng expect
    expect -c "
    spawn pure-pw useradd $username -u $username -d $FTP_HOME/$username
    expect \"Password:\"
    send \"$password\r\"
    expect \"Repeat password:\"
    send \"$password\r\"
    expect eof
    "

    # Cập nhật cơ sở dữ liệu của Pure-FTPd
    sudo pure-pw mkdb

    # Kích hoạt tài khoản FTP
    echo "Tài khoản FTP $username đã được thêm thành công với đầy đủ quyền."
  fi
}

# Gọi hàm thêm tài khoản với tham số từ dòng lệnh
add_account "$1" "$2"
