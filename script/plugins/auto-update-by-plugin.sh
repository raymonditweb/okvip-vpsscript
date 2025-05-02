#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Lấy plugin và action từ đối số
PLUGIN=$1
ACTION=$2

# Kiểm tra đầu vào hợp lệ
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

# Kiểm tra nếu không có site nào
if [[ -z "$WP_SITES" ]]; then
    echo "Error: Không tìm thấy site WordPress nào trên hệ thống."
    exit 1
fi

# Áp dụng auto-update cho plugin chỉ định
for SITE in $WP_SITES; do
    {
        echo "$ACTION auto-update cho plugin '$PLUGIN' tại $SITE"
        wp --path="$SITE" plugin is-installed "$PLUGIN" --allow-root > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            wp --path="$SITE" plugin auto-updates "$ACTION" "$PLUGIN" --allow-root
        else
            echo "Plugin '$PLUGIN' không tồn tại tại $SITE, bỏ qua."
        fi
    }
done
