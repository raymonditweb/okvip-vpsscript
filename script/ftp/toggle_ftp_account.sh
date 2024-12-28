#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Đường dẫn shell bị khóa (để vô hiệu hóa tài khoản)
LOCKED_SHELL="/sbin/nologin"

# Hàm hiển thị hướng dẫn sử dụng
usage() {
  echo "Usage: $0 <username> <action>"
  echo "  <username>   : Tên người dùng cần quản lý"
  echo "  <action>     : 'enable' để kích hoạt hoặc 'disable' để vô hiệu hóa"
  return 1
}

# Kiểm tra số lượng tham số đầu vào
if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

USERNAME=$1
ACTION=$2

# Kiểm tra tính hợp lệ của tên người dùng
if [[ ! "$USERNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Error: Tên người dùng không hợp lệ!"
  exit 1
fi

# Kiểm tra người dùng hệ thống
is_system_user() {
  id "$USERNAME" &>/dev/null
}

# Kiểm tra người dùng Pure-FTPd (user ảo)
is_virtual_user() {
  pure-pw show "$USERNAME" &>/dev/null
}

# Kiểm tra xem người dùng có tồn tại không
if ! is_system_user && ! is_virtual_user; then
  echo "Error: Người dùng '$USERNAME' không tồn tại!"
  exit 1
fi

# Thực hiện hành động
case $ACTION in
enable)
  if is_system_user; then
    usermod -s /bin/bash "$USERNAME" && echo "Đã kích hoạt tài khoản hệ thống cho '$USERNAME'."
  elif is_virtual_user; then
    pure-pw unlock "$USERNAME" && pure-pw mkdb && echo "Đã kích hoạt tài khoản Pure-FTPd cho '$USERNAME'."
  fi
  ;;
disable)
  if is_system_user; then
    usermod -s "$LOCKED_SHELL" "$USERNAME" && echo "Đã vô hiệu hóa tài khoản hệ thống cho '$USERNAME'."
  elif is_virtual_user; then
    pure-pw lock "$USERNAME" && pure-pw mkdb && echo "Đã vô hiệu hóa tài khoản Pure-FTPd cho '$USERNAME'."
  fi
  ;;
*)
  echo "Error: Hành động không hợp lệ!"
  usage
  exit 1
  ;;
esac
