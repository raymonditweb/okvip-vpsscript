#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ -z "$1" ]; then
  echo "Error: Vui lòng cung cấp cronjob can thực thi: $0 'cronjob_command'"
  exit 1
fi

CRONJOB_COMMAND="$1"

# Lấy danh sách cronjobs hiện tại
CRONTAB_TEMP=$(mktemp)
crontab -l >"$CRONTAB_TEMP"

# Kiểm tra xem cronjob có tồn tại trong crontab
if ! grep -Fq "$CRONJOB_COMMAND" "$CRONTAB_TEMP"; then
  echo "Error: Cronjob khong ton tai: $CRONJOB_COMMAND. Khong the thuc thi!"
  rm -f "$CRONTAB_TEMP"
  exit 2
fi

# Thực thi cronjob ngay lập tức
echo "Executing cronjob: $CRONJOB_COMMAND"
eval "$CRONJOB_COMMAND"

# Dọn dẹp
rm -f "$CRONTAB_TEMP"
