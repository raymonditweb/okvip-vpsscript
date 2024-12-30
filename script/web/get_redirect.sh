#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <domain_or_path>"
  exit 1
fi

DOMAIN_OR_PATH=$1
CONFIG_FILE="/etc/nginx/sites-available/$DOMAIN_OR_PATH.conf"

# Kiểm tra file cấu hình có tồn tại và có quyền đọc không
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Không tìm thấy tệp cấu hình $CONFIG_FILE."
  exit 1
fi

if [ ! -r "$CONFIG_FILE" ]; then
  echo "Error: Không có quyền đọc tệp cấu hình $CONFIG_FILE."
  exit 1
fi

# Tìm các dòng chứa từ khóa 'return' và xử lý
REDIRECT_LINES=$(grep -Eo "return [0-9]{3} https?://[^;]+" "$CONFIG_FILE" || true)

if [ -z "$REDIRECT_LINES" ]; then
  echo "Không tìm thấy redirect nào trong tệp cấu hình."
else
  echo "Thông tin redirect của $DOMAIN_OR_PATH:"
  while IFS= read -r line; do
    # Tách mã HTTP và URL đích
    REDIRECT_STATUS=$(awk '{print $2}' <<< "$line")
    REDIRECT_URL=$(awk '{print $3}' <<< "$line")
    echo "- $REDIRECT_STATUS $REDIRECT_URL"
  done <<< "$REDIRECT_LINES"
fi

echo # Thêm dòng trống cuối cùng
