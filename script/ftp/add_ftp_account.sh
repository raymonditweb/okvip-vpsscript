#!/bin/bash

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
    echo "$username:$password" | chpasswd

    # Thêm tài khoản vào tệp theo dõi tài khoản FTP
    echo "$username:$password" >> "$FTP_USER_FILE"
    
    # Thiết lập quyền thư mục
    mkdir -p "$FTP_HOME/$username"
    chown "$username:$username" "$FTP_HOME/$username"
    chmod 755 "$FTP_HOME/$username"

    echo "Tài khoản FTP $username đã được thêm thành công với đầy đủ quyền."
  fi
}

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Gọi hàm thêm tài khoản với tham số từ dòng lệnh
add_account "$1" "$2"
