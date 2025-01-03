#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Hàm để hiển thị thông báo hoặc hướng dẫn đặt lại mật khẩu
show_password() {
  local username="$1"

  if [ -z "$username" ]; then
    echo "Error: Vui lòng truyền tham số: $0 [tên_tài_khoản]"
    return 1
  fi

  # Kiểm tra xem tài khoản có tồn tại trong Pure-FTPd không
  if ! pure-pw show "$username" &>/dev/null; then
    echo "Error: Tài khoản $username không tồn tại trong Pure-FTPd."
    return 1
  fi

  # Thông báo rằng mật khẩu không thể được lấy lại
  echo "Lưu ý: Pure-FTPd không lưu mật khẩu dạng văn bản thuần."
  echo "Nếu bạn quên mật khẩu, hãy đặt lại bằng cách sử dụng lệnh sau:"
  echo "  pure-pw passwd $username"
  echo "Sau đó cập nhật cơ sở dữ liệu Pure-FTPd bằng lệnh:"
  echo "  pure-pw mkdb"
}

# Gọi hàm hiển thị thông báo hoặc hướng dẫn đặt lại mật khẩu
show_password "$1"
