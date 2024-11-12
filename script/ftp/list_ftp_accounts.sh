#!/bin/bash

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"

# Hàm để liệt kê tài khoản FTP
list_accounts() {
  echo "Danh sách tài khoản FTP:"
  if [[ -f $FTP_USER_FILE ]]; then
    cat $FTP_USER_FILE
  else
    echo
  fi
}

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Thực thi hàm liệt kê tài khoản
list_accounts