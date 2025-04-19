#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

DOMAIN="$1"
SITE_PATH="/var/www/$DOMAIN"
THEMES=("${@:2}")

if [ -z "$SITE_PATH" ] || [ "$#" -lt 2 ]; then
    echo "Cách dùng: $0 <site_path> \"theme:status:update\" [\"theme2:status:update\"] ..."
    echo "Ví dụ: $0 /var/www/html \"theme-a:active:enabled\" \"theme-b:inactive:disabled\""
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


for theme_info in "${THEMES[@]}"; do
    IFS=':' read -ra parts <<< "$theme_info"
    name="${parts[0]}"
    desired_status="${parts[1]}"
    desired_update="${parts[2]}"

    echo "Đang xử lý theme: $name"

    # Kích hoạt hoặc vô hiệu hóa theme
    if [[ "$desired_status" == "active" ]]; then
        wp theme activate "$name" --path="$SITE_PATH" --allow-root 
    else
        wp theme deactivate "$name" --path="$SITE_PATH" --allow-root 
    fi

    # Bật hoặc tắt auto-update
    if [[ "$desired_update" == "enabled" ]]; then
        wp theme auto-updates enable "$name" --path="$SITE_PATH" --allow-root 
    else
        wp theme auto-updates disable "$name" --path="$SITE_PATH" --allow-root 
    fi
done
