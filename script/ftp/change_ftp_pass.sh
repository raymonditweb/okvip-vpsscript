#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Hàm để thay đổi mật khẩu cho tài khoản FTP
change_password() {
  local username="$1"
  local new_password="$2"

  # Kiểm tra tham số đầu vào
  if [ -z "$username" ] || [ -z "$new_password" ]; then
    echo "Error: Vui lòng truyền tham số: $0 [tên_tài_khoản] [mật_khẩu_mới]"
    return 1
  fi

  # Kiểm tra sự tồn tại của tài khoản trong Pure-FTPd
  if ! pure-pw show "$username" &>/dev/null; then
    echo "Error: Tài khoản '$username' không tồn tại."
    return 1
  fi

  # Thay đổi mật khẩu bằng pure-pw
  if pure-pw passwd "$username" -P "$new_password"; then
    echo "Mật khẩu cho tài khoản '$username' đã được thay đổi."
  else
    echo "Error: Không thể thay đổi mật khẩu cho tài khoản '$username'."
    return 1
  fi

  # Cập nhật cơ sở dữ liệu Pure-FTPd
  if pure-pw mkdb; then
    echo "Cơ sở dữ liệu Pure-FTPd đã được cập nhật."
  else
    echo "Error: Không thể cập nhật cơ sở dữ liệu Pure-FTPd."
    return 1
  fi
}

# Gọi hàm thay đổi mật khẩu với tham số từ dòng lệnh
change_password "$1" "$2"
