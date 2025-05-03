#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

PLUGIN=$1
ACTION=$2

if [[ -z "$PLUGIN" ]]; then
    echo "Error: Bạn phải chỉ định tên plugin (slug)."
    echo "Ví dụ: $0 woocommerce enable"
    exit 1
fi

if [[ "$ACTION" != "enable" && "$ACTION" != "disable" ]]; then
    echo "Error: Cú pháp đúng: $0 [plugin-slug] [enable|disable]"
    echo "Ví dụ: $0 woocommerce enable"
    exit 1
fi

# Tìm tất cả site WordPress
echo "Đang tìm tất cả site WordPress trên VPS..."
WP_SITES=$(find / -type f -name wp-config.php 2>/dev/null | xargs -n1 dirname)

if [[ -z "$WP_SITES" ]]; then
    echo "Không tìm thấy site WordPress nào trên hệ thống."
    exit 1
fi

# Áp dụng hành động cho từng site
for SITE in $WP_SITES; do
    echo "Kiểm tra plugin '$PLUGIN' tại $SITE"

    if wp --path="$SITE" plugin is-installed "$PLUGIN" --allow-root > /dev/null 2>&1; then
        # Lấy trạng thái auto-update
        AUTO_UPDATE_STATUS=$(wp plugin list --path="$SITE" --allow-root --format=csv | grep -i "^$PLUGIN," | awk -F',' '{print $6}')

        if [[ "$ACTION" == "enable" ]]; then
            if [[ "$AUTO_UPDATE_STATUS" == "on" ]]; then
                echo "Auto-update đã bật tại $SITE"
            else
                echo "Bật auto-update cho plugin '$PLUGIN' tại $SITE..."
                wp plugin auto-updates enable "$PLUGIN" --path="$SITE" --allow-root
            fi
        else
            if [[ "$AUTO_UPDATE_STATUS" == "on" ]]; then
                echo "Tắt auto-update cho plugin '$PLUGIN' tại $SITE..."
                wp plugin auto-updates disable "$PLUGIN" --path="$SITE" --allow-root
            else
                echo "Auto-update đã tắt tại $SITE"
            fi
        fi
    else
        echo "Plugin '$PLUGIN' không tồn tại tại $SITE, bỏ qua."
    fi

done
