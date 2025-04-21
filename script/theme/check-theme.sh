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

# Kiểm tra WP-CLI
if ! command -v wp >/dev/null 2>&1; then
  echo "WP-CLI not found. Installing via apt..."

  apt update
  apt install -y wp-cli

  # Kiểm tra lại sau khi cài
  if ! command -v wp >/dev/null 2>&1; then
    echo "Error: WP-CLI installation failed. Please install manually."
    exit 1
  fi

  echo "WP-CLI installed successfully via apt."
fi


# Lấy JSON và in ra
THEME_JSON=$(wp theme list --allow-root --path="$SITE_PATH" --format=json)

# Kiểm tra lệnh có chạy thành công không
if [[ $? -ne 0 ]]; then
    echo "Error: Lỗi khi lấy danh sách theme từ: $SITE_PATH"
    exit 1
else
    echo "$THEME_JSON"
fi
