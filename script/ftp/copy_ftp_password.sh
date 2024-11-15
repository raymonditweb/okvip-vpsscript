#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"

# Hàm để hiển thị mật khẩu của tài khoản FTP
show_password() {
  local username="$1"

  if [ -z "$username" ]; then
    echo "Error: Vui lòng truyền tham số: $0 [tên_tài_khoản]"
    exit 1
  fi

  # Kiểm tra xem tài khoản có tồn tại không
  if grep -q "^$username:" "$FTP_USER_FILE"; then
    # Lấy mật khẩu từ tệp và hiển thị
    password=$(grep "^$username:" "$FTP_USER_FILE" | cut -d':' -f2)
    echo "Mật khẩu của tài khoản $username là: $password"
  else
    echo "Error: Tài khoản $username không tồn tại."
    exit 1
  fi
}

# Gọi hàm hiển thị mật khẩu với tham số từ dòng lệnh
show_password "$1"
