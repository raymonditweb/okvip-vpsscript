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
    echo "Cách dùng: $0 <domain> \"plugin:status:update\" [\"plugin2:status:update\"] ..."
    echo "Ví dụ: $0 linkokvipb5.com \"plugin-a:active:enabled\" \"plugin-b:inactive:disabled\""
    exit 1
fi

for plugin_info in "${PLUGINS[@]}"; do
    IFS=':' read -ra parts <<< "$plugin_info"
    PLUGIN_NAME="${parts[0]}"
    PLUGIN_STATUS="${parts[1]}"
    PLUGIN_UPDATE="${parts[2]}"

    echo "Đang xử lý plugin: $PLUGIN_NAME"

    # Kiểm tra plugin đã active hay chưa
    CURRENT_PLUGIN_STATUS=$(wp plugin list --path="$SITE_PATH" --allow-root --status=active --field=name | grep -w "$PLUGIN_NAME")

    if [[ "$PLUGIN_STATUS" == "active" ]]; then
        if [[ "$CURRENT_PLUGIN_STATUS" == "$PLUGIN_NAME" ]]; then
            echo "Plugin '$PLUGIN_NAME' đã được kích hoạt."
        else
            echo "Kích hoạt plugin '$PLUGIN_NAME'..."
            wp plugin activate "$PLUGIN_NAME" --path="$SITE_PATH" --allow-root
        fi
    else
        if [[ "$CURRENT_PLUGIN_STATUS" == "$PLUGIN_NAME" ]]; then
            echo "Vô hiệu hóa plugin '$PLUGIN_NAME'..."
            wp plugin deactivate "$PLUGIN_NAME" --path="$SITE_PATH" --allow-root
        else
            echo "Plugin '$PLUGIN_NAME' đã bị vô hiệu hóa."
        fi
    fi

    # Kiểm tra trạng thái auto-update từ CSV
    AUTO_UPDATE_STATUS=$(wp plugin list --path="$SITE_PATH" --allow-root --format=csv | grep -i "^$PLUGIN_NAME," | awk -F',' '{print $6}')

    if [[ "$PLUGIN_UPDATE" == "enabled" ]]; then
        if [[ "$AUTO_UPDATE_STATUS" == "yes" ]]; then
            echo "Auto-update đã bật cho plugin '$PLUGIN_NAME'."
        else
            echo "Bật auto-update cho plugin '$PLUGIN_NAME'..."
            wp plugin auto-updates enable "$PLUGIN_NAME" --path="$SITE_PATH" --allow-root
        fi
    else
        if [[ "$AUTO_UPDATE_STATUS" == "yes" ]]; then
            echo "Tắt auto-update cho plugin '$PLUGIN_NAME'..."
            wp plugin auto-updates disable "$PLUGIN_NAME" --path="$SITE_PATH" --allow-root
        else
            echo "Auto-update đã bị tắt cho plugin '$PLUGIN_NAME'."
        fi
    fi

done
