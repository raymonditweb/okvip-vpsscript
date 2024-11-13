#!/bin/bash

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"
FTP_HOME="/home/ftp_users"

# Hàm để bật hoặc tắt tài khoản FTP
toggle_account() {
  local username="$1"
  local action="$2"

  if [ -z "$username" ] || [ -z "$action" ]; then
    echo "Sử dụng: $0 [tên_tài_khoản] [enable/disable]"
    exit 1
  fi

  # Kiểm tra xem tài khoản có tồn tại không
  if ! id "$username" &>/dev/null; then
    echo "Error: Tài khoản $username không tồn tại."
    exit 1
  fi

  case "$action" in
    enable)
      usermod -s /sbin/nologin "$username"
      echo "Tài khoản FTP $username đã được bật."
      ;;
    disable)
      usermod -s /usr/sbin/nologin "$username"
      echo "Tài khoản FTP $username đã được tắt."
      ;;
    *)
      echo "Error: CHành động không hợp lệ. Vui lòng sử dụng 'enable' hoặc 'disable'."
      exit 1
      ;;
  esac
}

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Gọi hàm bật/tắt tài khoản với tham số từ dòng lệnh
toggle_account "$1" "$2"
