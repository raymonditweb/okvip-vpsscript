#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"
FTP_HOME="/home/ftp_users"

# Hàm để xóa tài khoản FTP
delete_account() {
  local username="$1"

  if [ -z "$username" ]; then
    echo "Error: Vui lòng cung cấp tên tài khoản để xóa."
    return 1
  fi

  # Kiểm tra xem tài khoản có tồn tại trong hệ thống không
  if id "$username" &>/dev/null; then
    # Xóa tài khoản khỏi cơ sở dữ liệu Pure-FTPd
    if pure-pw userdel "$username"; then
      echo "Đã xóa tài khoản FTP từ cơ sở dữ liệu Pure-FTPd."
    else
      echo "Error: Không thể xóa tài khoản FTP $username khỏi Pure-FTPd."
      return 1
    fi

    # Cập nhật cơ sở dữ liệu của Pure-FTPd
    if ! pure-pw mkdb; then
      echo "Error: Không thể cập nhật cơ sở dữ liệu của Pure-FTPd."
      return 1
    fi

    # Xóa tài khoản hệ thống
    if userdel -r "$username"; then
      echo "Đã xóa tài khoản hệ thống và thư mục cá nhân cho $username."
    else
      echo "Error: Không thể xóa tài khoản hệ thống $username."
      return 1
    fi

    # Xóa tài khoản khỏi tệp theo dõi
    if [ -f "$FTP_USER_FILE" ]; then
      sed -i "/^$username:/d" "$FTP_USER_FILE"
      echo "Đã xóa $username khỏi danh sách tài khoản FTP."
    fi

    echo "Tài khoản $username đã được xóa hoàn toàn."
  else
    echo "Error: Tài khoản $username không tồn tại."
  fi
}

# Gọi hàm xóa tài khoản với tham số từ dòng lệnh
delete_account "$1"
