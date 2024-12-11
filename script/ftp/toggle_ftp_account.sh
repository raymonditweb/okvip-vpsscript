#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Đường dẫn đầy đủ đến tệp `/etc/passwd`
PASSWD_FILE="/etc/passwd"

# Hàm hiển thị hướng dẫn sử dụng
usage() {
  echo "Error: Sử dụng: $0 <username> <action>"
  echo "  <username>   : Tên người dùng FTP cần quản lý"
  echo "  <action>     : 'activate' để kích hoạt hoặc 'deactivate' để vô hiệu hóa"
  return 1
}

# Kiểm tra đầu vào
if [[ $# -ne 2 ]]; then
  usage
fi

USERNAME=$1
ACTION=$2

# Kiểm tra xem người dùng có tồn tại không
if ! id "$USERNAME" &>/dev/null; then
  echo "Error: Người dùng '$USERNAME' không tồn tại!"
  exit 1
fi

# Đường dẫn shell bị khóa (để vô hiệu hóa tài khoản)
LOCKED_SHELL="/sbin/nologin"

# Thực hiện hành động
case $ACTION in
enable)
  usermod -s /bin/bash "$USERNAME" && echo "Đã kích hoạt tài khoản FTP cho '$USERNAME'."
  ;;
disable)
  usermod -s "$LOCKED_SHELL" "$USERNAME" && echo "Đã vô hiệu hóa tài khoản FTP cho '$USERNAME'."
  ;;
*)
  echo "Error: Hành động không hợp lệ!"
  usage
  ;;
esac
