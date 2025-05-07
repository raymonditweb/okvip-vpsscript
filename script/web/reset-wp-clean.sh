#!/bin/bash

# ✅ Nhận domain làm tham số
DOMAIN=$1
WEBROOT="/var/www/$DOMAIN"
WPCONFIG="$WEBROOT/wp-config.php"

# ✅ Kiểm tra domain
if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 domain.com"
  exit 1
fi

# ✅ Kiểm tra thư mục web tồn tại
if [ ! -d "$WEBROOT" ]; then
  echo "❌ Webroot directory does not exist: $WEBROOT"
  exit 1
fi

cd "$WEBROOT" || exit 1

echo "========================================="
echo "🚨 DỌN SẠCH WordPress cho domain: $DOMAIN"
echo "Thư mục: $WEBROOT"
echo "========================================="

# Thêm dòng ép dùng 'direct' nếu chưa có
if ! grep -q "FS_METHOD" "$WPCONFIG"; then
    echo "Config: $WPCONFIG"
  echo "🔧 Thêm 'FS_METHOD = direct' vào wp-config.php..."
  sed -i "/^\/\* That.s all, stop editing/i define('FS_METHOD', 'direct');" "$WPCONFIG"
else
  echo "wp-config.php đã có dòng FS_METHOD"
fi

# Kiểm tra WP Reset plugin đã cài chưa
echo "Kiểm tra plugin WP Reset..."
if ! wp plugin is-installed wp-reset --allow-root; then
  echo "Chưa có plugin WP Reset, đang cài đặt..."
  wp plugin install wp-reset --activate --allow-root
else
  echo "Plugin WP Reset đã được cài."
  wp plugin activate wp-reset --allow-root
fi

# Bắt đầu xoá từng phần
echo "Xoá plugin..."
wp reset delete plugins --yes --allow-root

echo "Xoá theme..."
wp reset delete themes --yes --allow-root

echo "Xoá media uploads..."
wp reset delete uploads --yes --allow-root

echo "Xoá transient data..."
wp reset delete transients --yes --allow-root

echo "Xoá file .htaccess..."
wp reset delete htaccess --yes --allow-root

echo "Xoá bảng custom..."
wp reset delete custom-tables --yes --allow-root

# Tùy chọn: Cài lại theme mặc định và reset thông tin
echo "Cài theme mặc định..."
wp theme install twentytwentyfour --activate --allow-root

echo "Đặt lại tiêu đề website..."
wp option update blogname "New Clean Site" --allow-root

echo "Đã dọn sạch WordPress cho $DOMAIN"
