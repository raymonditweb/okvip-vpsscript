#!/bin/bash

# ✅ Nhận domain làm tham số
DOMAIN=$1
WEBROOT="/var/www/$DOMAIN"

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

# ✅ Kiểm tra WP Reset plugin đã cài chưa
echo "🔍 Kiểm tra plugin WP Reset..."
if ! wp plugin is-installed wp-reset --allow-root; then
  echo "📦 Chưa có plugin WP Reset, đang cài đặt..."
  wp plugin install wp-reset --activate --allow-root
else
  echo "✅ Plugin WP Reset đã được cài."
  wp plugin activate wp-reset --allow-root
fi

# Bắt đầu xoá từng phần
echo "🧹 Xoá plugin..."
wp reset delete plugins --yes --allow-root

echo "🧹 Xoá theme..."
wp reset delete themes --yes --allow-root

echo "🧹 Xoá media uploads..."
wp reset delete uploads --yes --allow-root

echo "🧹 Xoá transient data..."
wp reset delete transients --yes --allow-root

echo "🧹 Xoá file .htaccess..."
wp reset delete htaccess --yes --allow-root

echo "🧹 Xoá bảng custom..."
wp reset delete custom-tables --yes --allow-root

# Tùy chọn: Cài lại theme mặc định và reset thông tin
echo "🎨 Cài theme mặc định..."
wp theme install twentytwentyfour --activate --allow-root

echo "📝 Đặt lại tiêu đề website..."
wp option update blogname "New Clean Site" --allow-root

echo "✅ Đã dọn sạch WordPress cho $DOMAIN"
