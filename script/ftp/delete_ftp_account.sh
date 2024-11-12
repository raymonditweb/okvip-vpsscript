#!/bin/bash

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"

# Hàm để xóa tài khoản FTP
delete_account() {
  local username="$1"

  if grep -q "^$username:" "$FTP_USER_FILE"; then
    # Xóa tài khoản từ tệp
    sed -i "/^$username:/d" "$FTP_USER_FILE"
    echo "Tài khoản $username đã được xóa."
  else
    echo "Error: Tài khoản $username không tồn tại."
  fi
}

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra tên người dùng được truyền từ tham số
if [ -z "$1" ]; then
  echo "Error: Vui lòng cung cấp tên tài khoản FTP muốn xóa."
  echo "Cú pháp: $0 <username>"
  exit 1
fi

# Gọi hàm xóa tài khoản với tên người dùng truyền vào
delete_account "$1"
