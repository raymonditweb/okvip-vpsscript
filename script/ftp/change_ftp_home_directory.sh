#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"

# Hàm để thay đổi thư mục home cho tài khoản FTP
change_home() {
  local username="$1"
  local new_home="$2"

  if [ -z "$username" ] || [ -z "$new_home" ]; then
    echo "Error: Vui lòng truyền tham số: $0 [tên_tài_khoản] [thư_mục_home_mới]"
    exit 1
  fi

  # Kiểm tra xem tài khoản có tồn tại không trong tệp
  if ! grep -q "^$username:" "$FTP_USER_FILE"; then
    echo "Error: Tài khoản $username không tồn tại."
    exit 1
  fi

  # Kiểm tra xem thư mục mới có tồn tại không
  if [ ! -d "$new_home" ]; then
    echo "Thư mục $new_home không tồn tại. Đang tạo thư mục..."
    mkdir -p "$new_home"
    if [ $? -eq 0 ]; then
      echo "Thư mục $new_home đã được tạo thành công."
    else
      echo "Error: Không thể tạo thư mục $new_home. Kiểm tra quyền truy cập."
      exit 1
    fi
  fi

  # Cập nhật thư mục home trong tệp
  sed -i "s|^$username:[^:]*:[^:]*|$username:$new_home|" "$FTP_USER_FILE"
  echo "Thư mục home cho tài khoản $username đã được thay đổi thành $new_home."

  # Nếu đang sử dụng Pure-FTPd, thay đổi thư mục home qua pure-pw
  if command -v pure-pw &>/dev/null; then
    pure-pw usermod "$username" -d "$new_home" -m
    # Cập nhật cơ sở dữ liệu Pure-FTPd
    pure-pw mkdb
    echo "Thư mục home cho tài khoản $username đã được cập nhật trong Pure-FTPd."
  fi
}

# Gọi hàm thay đổi thư mục home với tham số từ dòng lệnh
change_home "$1" "$2"
