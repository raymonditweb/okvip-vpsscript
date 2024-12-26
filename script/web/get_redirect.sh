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

echo "Redirect information for $DOMAIN_OR_PATH:"
echo "----------------------------------------"

# Tìm các dòng chứa từ khóa 'return' và in ra
REDIRECT_LINES=$(grep -E "return [0-9]{3} .*;" "$CONFIG_FILE")

if [ -z "$REDIRECT_LINES" ]; then
  echo "Không tìm thấy redirect nào trong tệp cấu hình."
else
  echo "$REDIRECT_LINES"
  echo "Lấy thông tin redirect thành công."
fi

echo "----------------------------------------"
