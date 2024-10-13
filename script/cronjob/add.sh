#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra nếu đối số (cronjob) được cung cấp
if [ -z "$1" ]; then
  echo "Error: Vui lòng cung cấp cronjob cần thêm."
  echo "Usage: ./add-cronjob.sh '<cronjob_command>'"
  exit 1
fi

CRONJOB=$1

# Kiểm tra xem cron đã được cài đặt chưa
if ! command -v cron >/dev/null; then
  echo "Cron chưa được cài đặt. Đang cài đặt cron..."
  apt update
  apt install cron -y
fi

# Kiểm tra cron đã chạy hay chưa, nếu chưa thì start
if ! systemctl is-active --quiet cron; then
  echo "Khởi động dịch vụ cron..."
  systemctl start cron
fi

# Kiểm tra cronjob đã tồn tại hay chưa
crontab -l 2>/dev/null | grep -F "$CRONJOB" >/dev/null
if [ $? -eq 0 ]; then
  echo "Error: Cronjob đã tồn tại: $CRONJOB"
  exit 0
fi

# Kiểm tra tính hợp lệ của cronjob
if ! echo "$CRONJOB" | grep -Eq '^([0-9\*/,-]+\s+){4}[0-9\*/,-]+\s+\S'; then
  echo "Error: Cronjob không hợp lệ. Định dạng cronjob phải có 5 trường thời gian và lệnh."
  echo "Usage: ./add-cronjob.sh '<minute> <hour> <day_of_month> <month> <day_of_week> <command>'"
  exit 1
fi

# Backup cronjobs hiện tại
echo "Backup cronjobs hiện tại vào cronjob_backup.txt..."
crontab -l 2>/dev/null > cronjob_backup.txt

# Thêm cronjob mới
(crontab -l 2>/dev/null; echo "$CRONJOB") | crontab -

echo "Cronjob mới đã được thêm: $CRONJOB"
