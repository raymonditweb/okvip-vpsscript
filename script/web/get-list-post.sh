#!/bin/bash
# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

DOMAIN=$1
FIELDS="ID,post_title,post_status,post_date"
WP_PATH="/var/www/$DOMAIN"
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
if [ ! -d "$WP_PATH" ]; then
  echo "Error: Đường dẫn WordPress không tồn tại: $WP_PATH"
  exit 1
fi
echo "Danh sách bài viết của $DOMAIN :"

wp post list \
  --post_type=post \
  --fields="$FIELDS" \
  --format=json \
  --path="$WP_PATH" \
  --allow-root
