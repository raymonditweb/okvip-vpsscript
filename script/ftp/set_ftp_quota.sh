#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Giá trị max quota (MB)
MAX_QUOTA=500

# Hàm kiểm tra tài khoản Pure-FTPd
is_virtual_user() {
  pure-pw show "$1" &>/dev/null
}

# Hàm để đặt quota cho tài khoản FTP
set_quota() {
  local username="$1"
  local quota="$2" # Quota tính bằng MB

  # Kiểm tra tham số đầu vào
  if [ -z "$username" ] || [ -z "$quota" ]; then
    echo "Error: Vui lòng truyền tham số: $0 [tên_tài_khoản] [quota (MB)]"
    return 1
  fi

  # Kiểm tra quota là số nguyên
  if ! [[ "$quota" =~ ^[0-9]+$ ]]; then
    echo "Error: Quota phải là số nguyên hợp lệ."
    return 1
  fi

  # Kiểm tra quota không vượt quá max quota
  if [[ "$quota" -gt "$MAX_QUOTA" ]]; then
    echo "Error: Quota ($quota MB) không được lớn hơn max quota ($MAX_QUOTA MB)."
    return 1
  fi

  # Kiểm tra tài khoản có tồn tại không
  if ! is_virtual_user "$username"; then
    echo "Error: Tài khoản FTP '$username' không tồn tại trong Pure-FTPd."
    return 1
  fi

  # Thiết lập quota bằng Pure-FTPd
  if pure-pw usermod "$username" -q "${quota}M" -m; then
    echo "Đã đặt quota ${quota}MB cho tài khoản FTP '$username'."
  else
    echo "Error: Không thể đặt quota cho tài khoản FTP '$username'."
    return 1
  fi

  # Cập nhật cơ sở dữ liệu Pure-FTPd
  if ! pure-pw mkdb; then
    echo "Error: Không thể cập nhật cơ sở dữ liệu của Pure-FTPd."
    return 1
  fi
}

# Gọi hàm đặt quota với tham số từ dòng lệnh
set_quota "$1" "$2"
