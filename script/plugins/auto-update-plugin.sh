#!/bin/bash

# Tìm tất cả thư mục chứa wp-config.php
echo "🔍 Đang tìm tất cả site WordPress trên VPS..."
WP_SITES=$(find / -type f -name wp-config.php 2>/dev/null | xargs -n1 dirname)

# Kiểm tra nếu không có site nào
if [[ -z "$WP_SITES" ]]; then
    echo "Error: Không tìm thấy site WordPress nào trên hệ thống."
    exit 1
fi

# Thực hiện action: enable hoặc disable
ACTION=$1
if [[ "$ACTION" != "enable" && "$ACTION" != "disable" ]]; then
    echo "Error: Usage: $0 [enable|disable]"
    exit 1
fi

# Lặp qua từng site và bật / tắt auto update
for SITE in $WP_SITES; do
    echo "⚙️ Site: $SITE"

    {
        echo "  - $ACTION auto-update plugins..."
        wp --path="$SITE" plugin list --field=name --allow-root | xargs -n1 -I {} wp --path="$SITE" plugin auto-updates "$ACTION" {} --allow-root

        echo "Cài đặt auto update plugins trên $SITE thành công"
    } || {
        echo "Lỗi xảy ra ở site: $SITE → bỏ qua và tiếp tục site khác."
    }

    echo "------------------------------"
done

echo "🎉 Hoàn tất $ACTION auto-update cho tất cả site!"
