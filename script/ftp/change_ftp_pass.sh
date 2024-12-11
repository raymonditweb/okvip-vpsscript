#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"

# Hàm để thay đổi mật khẩu cho tài khoản FTP
change_password() {
  local username="$1"
  local new_password="$2"

  if [ -z "$username" ] || [ -z "$new_password" ]; then
    echo "Error: Vui lòng truyền tham số: $0 [tên_tài_khoản] [mật_khẩu_mới]"
    return 1
  fi

  # Kiểm tra xem tài khoản có tồn tại không trong tệp
  if ! grep -q "^$username:" "$FTP_USER_FILE"; then
    echo "Error: Tài khoản $username không tồn tại."
    return 1
  fi

  # Thay đổi mật khẩu trong tệp
  sed -i "s/^$username:[^:]*$/$username:$new_password/" "$FTP_USER_FILE"
  echo "Mật khẩu cho tài khoản $username đã được thay đổi."

  # Nếu đang sử dụng Pure-FTPd, thay đổi mật khẩu qua pure-pw
  if command -v pure-pw &>/dev/null; then
    pure-pw passwd "$username" -u "$username" -P "$new_password" -m
    # Cập nhật cơ sở dữ liệu Pure-FTPd
    pure-pw mkdb
    echo "Mật khẩu cho tài khoản $username đã được cập nhật trong Pure-FTPd."
  fi
}

# Gọi hàm thay đổi mật khẩu với tham số từ dòng lệnh
change_password "$1" "$2"
