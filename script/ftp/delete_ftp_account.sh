#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"
FTP_HOME="/home/ftp_users"

# Hàm để xóa tài khoản FTP
delete_account() {
  local username="$1"

  if [ -z "$username" ]; then
    echo "Error: Vui lòng cung cấp tên tài khoản để xóa."
    exit 1
  fi

  # Kiểm tra xem tài khoản có tồn tại trong hệ thống không
  if id "$username" &>/dev/null; then
    # Xóa tài khoản hệ thống
    userdel -r "$username"  # Xóa người dùng và thư mục cá nhân

    # Xóa tài khoản khỏi tệp
    sed -i "/^$username:/d" "$FTP_USER_FILE"

    echo "Đã xóa tài khoản FTP cho $username."
  else
    echo "Error: Tài khoản $username không tồn tại."
  fi
}

# Gọi hàm xóa tài khoản với tham số từ dòng lệnh
delete_account "$1"
