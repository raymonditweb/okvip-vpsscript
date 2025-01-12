#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Hàm kiểm tra và cài đặt gói expect
install_expect() {
  if ! command -v expect &>/dev/null; then
    echo "Gói 'expect' chưa được cài đặt. Đang tiến hành cài đặt..."
    if [ -x "$(command -v apt-get)" ]; then
      apt-get update && apt-get install -y expect || {
        echo "Error: Không thể cài đặt 'expect' với apt-get."
        exit 1
      }
    elif [ -x "$(command -v yum)" ]; then
      yum install -y expect || {
        echo "Error: Không thể cài đặt 'expect' với yum."
        exit 1
      }
    else
      echo "Error: Không tìm thấy trình quản lý gói để cài đặt 'expect'."
      exit 1
    fi
    echo "Gói 'expect' đã được cài đặt thành công."
  else
    echo "Gói 'expect' đã được cài đặt sẵn."
  fi
}

# Gọi hàm kiểm tra và cài đặt expect
install_expect

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

  # Thay đổi mật khẩu bằng expect
  expect -c "
  spawn pure-pw passwd $username
  expect \"Password:\"
  send \"$new_password\r\"
  expect \"Repeat password:\"
  send \"$new_password\r\"
  expect eof
  " || {
    echo "Error: Không thể thay đổi mật khẩu cho tài khoản '$username'."
    return 1
  }

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
