#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Lấy domain
DOMAIN="$1"

# Đường dẫn site WordPress
SITE_PATH="/var/www/$DOMAIN"

# Kiểm tra thư mục tồn tại
if [ ! -d "$SITE_PATH" ]; then
    echo "Error: Không tìm thấy thư mục: $SITE_PATH"
    exit 1
fi

# Lấy JSON và in ra
PLUGIN_JSON=$(wp plugin list --allow-root --path="$SITE_PATH" --format=json)

# Kiểm tra lệnh có chạy thành công không
if [[ $? -ne 0 ]]; then
    echo "Error: Lỗi khi lấy danh sách plugin từ: $SITE_PATH"
    exit 1
else
    echo "$PLUGIN_JSON"
fi
