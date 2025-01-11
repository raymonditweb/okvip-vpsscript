#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

LOCKED_SHELL="/sbin/nologin"
LOCK_FILE="/etc/ftp_users.lock" # Tệp theo dõi tài khoản bị vô hiệu hóa

# Đảm bảo tệp theo dõi tồn tại
if [ ! -f "$LOCK_FILE" ]; then
  touch "$LOCK_FILE"
fi

usage() {
  echo "Error: Sử dụng: $0 <username> <action>"
  echo "  <username>   : Tên người dùng FTP cần quản lý"
  echo "  <action>     : 'enable' để kích hoạt hoặc 'disable' để vô hiệu hóa"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

USERNAME=$1
ACTION=$2

# Kiểm tra người dùng hệ thống
is_system_user() {
  id "$USERNAME" &>/dev/null
}

# Kiểm tra người dùng Pure-FTPd (user ảo)
is_virtual_user() {
  pure-pw show "$USERNAME" &>/dev/null
}

# Kiểm tra trạng thái hiện tại của tài khoản hệ thống
is_system_user_locked() {
  local shell
  shell=$(getent passwd "$USERNAME" | cut -d: -f7)
  [[ "$shell" == "$LOCKED_SHELL" ]]
}

# Kiểm tra trạng thái tài khoản Pure-FTPd
is_virtual_user_locked() {
  grep -q "^$USERNAME$" "$LOCK_FILE"
}

case $ACTION in
enable)
  # Kích hoạt tài khoản hệ thống
  if is_system_user; then
    if is_system_user_locked; then
      if usermod -s /bin/bash "$USERNAME"; then
        echo "Đã kích hoạt tài khoản hệ thống cho '$USERNAME'."
      else
        echo "Error: Không thể kích hoạt tài khoản hệ thống cho '$USERNAME'."
        exit 1
      fi
    else
      echo "Tài khoản hệ thống '$USERNAME' đã được kích hoạt trước đó."
    fi
  fi

  # Kích hoạt tài khoản Pure-FTPd
  if is_virtual_user; then
    if is_virtual_user_locked; then
      sed -i "/^$USERNAME$/d" "$LOCK_FILE" # Xóa khỏi tệp khóa
      if pure-pw unlock "$USERNAME" && pure-pw mkdb; then
        echo "Tài khoản Pure-FTPd '$USERNAME' đã được kích hoạt."
      else
        echo "Error: Không thể kích hoạt tài khoản Pure-FTPd '$USERNAME'."
        exit 1
      fi
    else
      echo "Tài khoản Pure-FTPd '$USERNAME' đã được kích hoạt trước đó."
    fi
  else
    echo "Error: Tài khoản '$USERNAME' không tồn tại trong Pure-FTPd."
  fi
  ;;

disable)
  # Vô hiệu hóa tài khoản hệ thống
  if is_system_user; then
    if ! is_system_user_locked; then
      if usermod -s "$LOCKED_SHELL" "$USERNAME"; then
        echo "Đã vô hiệu hóa tài khoản hệ thống cho '$USERNAME'."
      else
        echo "Error: Không thể vô hiệu hóa tài khoản hệ thống cho '$USERNAME'."
        exit 1
      fi
    else
      echo "Tài khoản hệ thống '$USERNAME' đã bị vô hiệu hóa trước đó."
    fi
  fi

  # Vô hiệu hóa tài khoản Pure-FTPd
  if is_virtual_user; then
    if ! is_virtual_user_locked; then
      echo "$USERNAME" >>"$LOCK_FILE" # Thêm vào tệp khóa
      if pure-pw lock "$USERNAME" && pure-pw mkdb; then
        echo "Tài khoản Pure-FTPd '$USERNAME' đã được vô hiệu hóa."
      else
        echo "Error: Không thể vô hiệu hóa tài khoản Pure-FTPd '$USERNAME'."
        exit 1
      fi
    else
      echo "Tài khoản Pure-FTPd '$USERNAME' đã bị vô hiệu hóa trước đó."
    fi
  else
    echo "Tài khoản '$USERNAME' không tồn tại trong Pure-FTPd."
  fi
  ;;

*)
  echo "Error: Hành động không hợp lệ!"
  usage
  ;;
esac
