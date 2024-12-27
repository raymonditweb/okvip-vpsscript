#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Đường dẫn đầy đủ đến tệp `/etc/passwd`
PASSWD_FILE="/etc/passwd"

# Thời gian timeout (giây)
TIMEOUT=10

# Hàm hiển thị hướng dẫn sử dụng
usage() {
  echo "Error: Sử dụng: $0 <username> <action>"
  echo "  <username>   : Tên người dùng FTP cần quản lý"
  echo "  <action>     : 'enable' để kích hoạt hoặc 'disable' để vô hiệu hóa"
  return 1
}

# Kiểm tra đầu vào
if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

USERNAME=$1
ACTION=$2

# Kiểm tra danh sách tài khoản FTP hiện có
FTP_USERS=$(timeout $TIMEOUT awk -F: '{if ($7 == "/bin/bash" || $7 == "/sbin/nologin") print $1}' $PASSWD_FILE)
if [[ $? -ne 0 ]]; then
  echo "Error: Quá thời gian chờ ($TIMEOUT giây) khi kiểm tra tài khoản FTP!"
  exit 1
fi

if [[ -z "$FTP_USERS" ]]; then
  echo "Error: Không tồn tại tài khoản FTP nào trên hệ thống!"
  exit 1
fi

# Kiểm tra xem người dùng có tồn tại không
timeout $TIMEOUT id "$USERNAME" &>/dev/null
if [[ $? -eq 124 ]]; then
  echo "Error: Quá thời gian chờ ($TIMEOUT giây) khi kiểm tra người dùng!"
  exit 1
elif [[ $? -ne 0 ]]; then
  echo "Error: Người dùng '$USERNAME' không tồn tại!"
  exit 1
fi

# Đường dẫn shell bị khóa (để vô hiệu hóa tài khoản)
LOCKED_SHELL="/sbin/nologin"

# Thực hiện hành động
case $ACTION in
enable)
  timeout $TIMEOUT usermod -s /bin/bash "$USERNAME"
  if [[ $? -eq 124 ]]; then
    echo "Error: Quá thời gian chờ ($TIMEOUT giây) khi kích hoạt tài khoản!"
    exit 1
  elif [[ $? -eq 0 ]]; then
    echo "Đã kích hoạt tài khoản FTP cho '$USERNAME'."
  else
    echo "Error: Không thể kích hoạt tài khoản '$USERNAME'!"
  fi
  ;;
disable)
  timeout $TIMEOUT usermod -s "$LOCKED_SHELL" "$USERNAME"
  if [[ $? -eq 124 ]]; then
    echo "Error: Quá thời gian chờ ($TIMEOUT giây) khi vô hiệu hóa tài khoản!"
    exit 1
  elif [[ $? -eq 0 ]]; then
    echo "Đã vô hiệu hóa tài khoản FTP cho '$USERNAME'."
  else
    echo "Error: Không thể vô hiệu hóa tài khoản '$USERNAME'!"
  fi
  ;;
*)
  echo "Error: Hành động không hợp lệ!"
  usage
  ;;
esac
