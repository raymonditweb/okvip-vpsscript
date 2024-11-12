#!/bin/bash

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
# Nếu không có tham số username, password thi dùng default
FTP_USER_FILE="/etc/ftp_users.txt"
DEFAULT_USERNAME="df_user"
DEFAULT_PASSWORD="123456"

# Hàm để thêm tài khoản FTP
add_account() {
  local username="${1:-$DEFAULT_USERNAME}"
  local password="${2:-$DEFAULT_PASSWORD}"

  # Kiểm tra xem tài khoản đã tồn tại chưa
  if grep -q "^$username:" $FTP_USER_FILE; then
    echo "Error: Tài khoản $username đã tồn tại."
  else
    # Thêm tài khoản vào tệp
    echo "$username:$password" >> $FTP_USER_FILE
    echo "Tài khoản $username đã được thêm thành công."
  fi
}

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Gọi hàm thêm tài khoản với tham số từ dòng lệnh
add_account "$1" "$2"
