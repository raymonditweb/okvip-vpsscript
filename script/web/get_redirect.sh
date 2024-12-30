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

# Kiểm tra file cấu hình có tồn tại không
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Không tìm thấy tệp cấu hình $CONFIG_FILE."
  exit 1
fi

# Tìm các dòng chứa từ khóa 'return' và in ra
REDIRECT_LINES=$(grep -Eo "return [0-9]{3} https?://[^;]+" "$CONFIG_FILE" || true)

if [ -z "$REDIRECT_LINES" ]; then
  echo "Không tìm thấy redirect nào trong tệp cấu hình."
else
  OUTPUT="Thông tin redirect của $DOMAIN_OR_PATH:"
  while read -r line; do
    REDIRECT_STATUS=$(echo "$line" | awk '{print $2}') # Lấy mã HTTP
    REDIRECT_URL=$(echo "$line" | awk '{print $3}')    # Lấy URL đích
    OUTPUT+="\n- $REDIRECT_STATUS $REDIRECT_URL"
  done <<<"$REDIRECT_LINES"
  echo "$OUTPUT"
fi
echo # Thêm dòng trống cuối cùng
