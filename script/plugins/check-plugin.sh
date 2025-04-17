#!/bin/bash

# Đường dẫn site WordPress
SITE_PATH="/var/www/linkokvipb4.com"

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
