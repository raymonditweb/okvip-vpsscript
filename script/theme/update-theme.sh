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

# Cài WP-CLI nếu chưa có
if ! command -v wp >/dev/null 2>&1; then
  echo "WP-CLI chưa được cài. Đang tiến hành cài đặt..."
  apt update
  apt install -y wp-cli
  if ! command -v wp >/dev/null 2>&1; then
    echo "Lỗi: Không thể cài WP-CLI. Cài thủ công."
    exit 1
  fi
  echo "WP-CLI đã được cài."
fi

# Cài jq nếu chưa có
if ! command -v jq >/dev/null 2>&1; then
  echo "jq chưa được cài. Đang tiến hành cài đặt..."
  apt update
  apt install -y jq
  if ! command -v jq >/dev/null 2>&1; then
    echo "Lỗi: Không thể cài jq. Cài thủ công."
    exit 1
  fi
  echo "jq đã được cài."
fi

# Tách thông tin theme
IFS=':' read -ra parts <<< "$THEME_INFO"
THEME_NAME="${parts[0]}"
THEME_STATUS="${parts[1]}"
THEME_UPDATE="${parts[2]}"

echo "Đang xử lý theme: $THEME_NAME"

# Kiểm tra theme hiện tại
CURRENT_THEME=$(wp theme list --status=active --field=name --path="$SITE_PATH" --allow-root)

if [[ "$THEME_STATUS" == "active" ]]; then
    if [[ "$CURRENT_THEME" == "$THEME_NAME" ]]; then
        echo "Theme '$THEME_NAME' đã được kích hoạt."
    else
        echo "Kích hoạt theme '$THEME_NAME'..."
        wp theme activate "$THEME_NAME" --path="$SITE_PATH" --allow-root
    fi
else
    echo "Không thể deactivate theme bằng wp-cli. Vui lòng kích hoạt theme khác thay thế nếu cần."
fi

# Kiểm tra trạng thái auto-update (dùng JSON + jq)
IS_AUTO_UPDATE_ENABLED=$(wp theme list --path="$SITE_PATH" --allow-root --format=csv | grep -i "^$THEME_NAME," | awk -F',' '{print $6}')

if [[ "$THEME_UPDATE" == "enabled" ]]; then
    if [[ "$IS_AUTO_UPDATE_ENABLED" == "on" ]]; then
        echo "Auto-update đã bật cho theme '$THEME_NAME'."
    else
        echo "Bật auto-update cho theme '$THEME_NAME'..."
        wp theme auto-updates enable "$THEME_NAME" --path="$SITE_PATH" --allow-root
    fi
else
    if [[ "$IS_AUTO_UPDATE_ENABLED" == "on" ]]; then
        echo "Tắt auto-update cho theme '$THEME_NAME'..."
        wp theme auto-updates disable "$THEME_NAME" --path="$SITE_PATH" --allow-root
    else
        echo "Auto-update đã bị tắt cho theme '$THEME_NAME'."
    fi
fi
