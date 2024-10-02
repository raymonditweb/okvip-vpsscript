#!/bin/bash

# Kiểm tra xem người dùng có quyền root hay không
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Liệt kê các cronjob của user root
echo "Danh sách các cronjob của user root:"
crontab -l