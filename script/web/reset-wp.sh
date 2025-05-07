#!/bin/bash

DOMAIN=$1
WEBROOT="/var/www/$DOMAIN"

if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 domain.com"
  exit 1
fi

cd "$WEBROOT" || exit

# Cài WP Reset nếu chưa có
echo "Installing WP Reset plugin..."
wp plugin install wp-reset --activate --allow-root

# Reset database (xóa tất cả nội dung và option)
echo "Resetting WordPress site via WP Reset..."
wp reset site --yes --allow-root

# (Tuỳ chọn) Cài lại theme mặc định
echo "Installing default theme..."
wp theme install twentytwentyfour --activate --allow-root

# (Tuỳ chọn) Đổi lại site title, admin user
wp option update blogname "New Blog" --allow-root

echo "✅ Đã reset WordPress cho $DOMAIN"
