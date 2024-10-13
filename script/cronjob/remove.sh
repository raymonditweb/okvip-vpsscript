#!/bin/bash

# Kiểm tra quyền root
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
echo "Backup cronjobs hiện tại vào cronjob_backup.txt..."
crontab -l 2>/dev/null > cronjob_backup.txt

# Kiểm tra cronjob có tồn tại không
if ! crontab -l 2>/dev/null | grep -Fxq "$CRONJOB"; then
  echo "Error: Cronjob không tồn tại: $CRONJOB"
  exit 1
fi

# Xóa cronjob
crontab -l 2>/dev/null | grep -Fxv "$CRONJOB" | crontab -

echo "Success: Cronjob đã được xóa: $CRONJOB"
