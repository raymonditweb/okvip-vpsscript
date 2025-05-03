#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

DOMAIN="$1"
THEME_INFO="$2"
SITE_PATH="/var/www/$DOMAIN"

if [ -z "$DOMAIN" ] || [ -z "$THEME_INFO" ]; then
    echo "Cách dùng: $0 <domain> \"theme:status:update\""
    echo "Ví dụ: $0 linkokvipb5.com \"astra:active:enabled\""
    exit 1
fi

# Kiểm tra WP-CLI
if ! command -v wp >/dev/null 2>&1; then
  echo "WP-CLI not found. Installing via apt..."

  apt update
  apt install -y wp-cli

  if ! command -v wp >/dev/null 2>&1; then
    echo "Error: WP-CLI installation failed. Please install manually."
    exit 1
  fi

  echo "WP-CLI installed successfully via apt."
fi

# Tách theme info
IFS=':' read -ra parts <<< "$THEME_INFO"
THEME_NAME="${parts[0]}"
THEME_STATUS="${parts[1]}"
THEME_UPDATE="${parts[2]}"

echo "Đang xử lý theme: $THEME_NAME"

# Kích hoạt theme
if [[ "$THEME_STATUS" == "active" ]]; then
    wp theme activate "$THEME_NAME" --path="$SITE_PATH" --allow-root
else
    echo "Không thể deactivate theme trong wp-cli. Cần activate theme khác thay thế nếu muốn vô hiệu hóa."
fi
# Cấu hình auto-update
if [[ "$THEME_UPDATE" == "enabled" ]]; then
    wp theme auto-updates enable "$THEME_NAME" --path="$SITE_PATH" --allow-root
else
    wp theme auto-updates disable "$THEME_NAME" --path="$SITE_PATH" --allow-root
fi
