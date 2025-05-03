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

# Kiểm tra theme hiện tại đang active hay không
CURRENT_THEME=$(wp theme list --status=active --field=name --path="$SITE_PATH" --allow-root)

# Kích hoạt nếu chưa active
if [[ "$THEME_STATUS" == "active" ]]; then
    if [[ "$CURRENT_THEME" == "$THEME_NAME" ]]; then
        echo "Theme '$THEME_NAME' đã được kích hoạt."
    else
        echo "Kích hoạt theme '$THEME_NAME'..."
        wp theme activate "$THEME_NAME" --path="$SITE_PATH" --allow-root
    fi
else
    echo "Không thể deactivate theme trực tiếp bằng wp-cli. Vui lòng kích hoạt theme khác để thay thế nếu cần."
fi

# Kiểm tra trạng thái auto-update hiện tại
AUTO_UPDATE_STATUS=$(wp theme list --update=auto --path="$SITE_PATH" --allow-root --format=csv | grep -w "$THEME_NAME")

if [[ "$THEME_UPDATE" == "enabled" ]]; then
    if [[ -n "$AUTO_UPDATE_STATUS" ]]; then
        echo "Auto-update đã được bật cho theme '$THEME_NAME'."
    else
        echo "Bật auto-update cho theme '$THEME_NAME'..."
        wp theme auto-updates enable "$THEME_NAME" --path="$SITE_PATH" --allow-root
    fi
else
    if [[ -n "$AUTO_UPDATE_STATUS" ]]; then
        echo "Tắt auto-update cho theme '$THEME_NAME'..."
        wp theme auto-updates disable "$THEME_NAME" --path="$SITE_PATH" --allow-root
    else
        echo "Auto-update đã bị tắt cho theme '$THEME_NAME'."
    fi
fi
