#!/bin/bash

# Kiểm tra xem người dùng có quyền root hay không
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra nếu đối số (cronjob) được cung cấp
if [ -z "$1" ]; then
  echo "Error: Vui lòng cung cấp cronjob cần xóa."
  echo "Usage: ./delete-cronjob.sh '<cronjob_command>'"
  exit 1
fi

CRONJOB=$1

# Backup cronjobs hiện tại
crontab -l > cronjob_backup.txt

# Xóa cronjob
crontab -l | grep -v "$CRONJOB" | crontab -

echo "Cronjob đã được xóa: $CRONJOB"
