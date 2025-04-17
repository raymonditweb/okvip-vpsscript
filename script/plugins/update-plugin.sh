#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

DOMAIN="$1"
SITE_PATH="/var/www/$DOMAIN"
PLUGINS=("${@:2}")

if [ -z "$SITE_PATH" ] || [ "$#" -lt 2 ]; then
    echo "Cách dùng: $0 <site_path> \"plugin:status:update\" [\"plugin2:status:update\"] ..."
    echo "Ví dụ: $0 /var/www/html \"plugin-a:active:enabled\" \"plugin-b:inactive:disabled\""
    exit 1
fi

for plugin_info in "${PLUGINS[@]}"; do
    IFS=':' read -ra parts <<< "$plugin_info"
    name="${parts[0]}"
    desired_status="${parts[1]}"
    desired_update="${parts[2]}"

    echo "Đang xử lý plugin: $name"

    # Kích hoạt hoặc vô hiệu hóa plugin
    if [[ "$desired_status" == "active" ]]; then
        wp plugin activate "$name" --path="$SITE_PATH" --allow-root 
    else
        wp plugin deactivate "$name" --path="$SITE_PATH" --allow-root 
    fi

    # Bật hoặc tắt auto-update
    if [[ "$desired_update" == "enabled" ]]; then
        wp plugin auto-updates enable "$name" --path="$SITE_PATH" --allow-root 
    else
        wp plugin auto-updates disable "$name" --path="$SITE_PATH" --allow-root 
    fi
done
