#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"

# Hàm để đặt quota cho tài khoản FTP
set_quota() {
  local username="$1"
  local quota="$2"  # Quota tính bằng MB

  if [ -z "$username" ] || [ -z "$quota" ]; then
    echo "Error: Vui lòng truyền tham số: $0 [tên_tài_khoản] [quota (MB)]"
    exit 1
  fi

  # Kiểm tra xem tài khoản có tồn tại không
  if ! grep -q "^$username:" "$FTP_USER_FILE"; then
    echo "Error: Tài khoản $username không tồn tại."
    exit 1
  fi

  # Thiết lập quota bằng Pure-FTPd (sử dụng pure-pw)
  pure-pw usermod "$username" -q "${quota}M" -m

  # Cập nhật cơ sở dữ liệu Pure-FTPd
  pure-pw mkdb

  echo "Đã đặt quota ${quota}MB cho tài khoản FTP $username."
}

# Gọi hàm đặt quota với tham số từ dòng lệnh
set_quota "$1" "$2"
