#!/bin/bash

DOMAIN=$1
WEBROOT="/var/www/$DOMAIN"
INFO_FILE="$WEBROOT/site-info.conf"
WPCONFIG="$WEBROOT/wp-config.php"
TEMPLATE_ZIP="/tmp/template-$DOMAIN.zip"

if [ -z "$DOMAIN" ]; then
  echo "Sử dụng: $0 domain.com"
  exit 1
fi

if [ ! -f "$INFO_FILE" ]; then
  echo "Error:Không tìm thấy file cấu hình: $INFO_FILE"
  exit 1
fi

# Load biến từ site-info.conf
source "$INFO_FILE"

# Kiểm tra có MYSQL_ROOT_PASSWORD không
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "Error:Trong file site-info.conf thiếu MYSQL_ROOT_PASSWORD"
  exit 1
fi

echo "Đang reset lại site $DOMAIN về trạng thái ban đầu..."

# Xoá toàn bộ mã nguồn cũ
rm -rf "$WEBROOT"/*
mkdir -p "$WEBROOT"

# Tải lại template từ URL
echo "Tải lại template từ $TEMPLATE_URL"
wget -O "$TEMPLATE_ZIP" "$TEMPLATE_URL" --no-check-certificate --quiet
if [ $? -ne 0 ]; then
  echo "Error:Không tải được template"
  exit 1
fi
unzip -o "$TEMPLATE_ZIP" -d "$WEBROOT"
rm -f "$TEMPLATE_ZIP"

# Import lại database từ db.sql
if [ -f "$WEB_ROOT/db.sql" ]; then
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" $DB_NAME < $WEB_ROOT/db.sql
  # Update option_value
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" $DB_NAME -e "UPDATE wp_options SET option_value = 'https://$DOMAIN' WHERE option_name IN ('siteurl', 'home');"
  # Xóa file db.sql sau khi import
  rm -f "$WEB_ROOT/db.sql"
  echo "File db.sql đã được xóa sau khi cài đặt thành công."
else
  echo "Error: Không tìm thấy file db.sql trong template. Dừng lại."
  exit 1
fi

if ! certbot plugins | grep -q 'nginx'; then
  echo "Chưa có plugin nginx cho Certbot. Đang cài đặt..."
  apt update && apt install python3-certbot-nginx -y
fi

# Cài đặt SSL
if ! certbot certificates | grep -q "$DOMAIN"; then
  certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m no-reply@$DOMAIN --redirect
fi

# Cấu hình wp-config.php
if [ ! -f "$WEB_ROOT/wp-config.php" ]; then
  wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="localhost" --path=$WEB_ROOT --allow-root
fi
wp config set DB_NAME "$DB_NAME" --path=$WEB_ROOT --allow-root
wp config set DB_USER "$DB_USER" --path=$WEB_ROOT --allow-root
wp config set DB_PASSWORD "$DB_PASSWORD" --path=$WEB_ROOT --allow-root

# Cập nhật mật khẩu admin trực tiếp trong database
ADMIN_PASS_MD5=$(echo -n "$ADMIN_PASS" | md5sum | awk '{print $1}')
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" $DB_NAME -e "UPDATE wp_users SET user_pass = '$ADMIN_PASS_MD5' WHERE user_login = '$ADMIN_USERNAME' OR user_login = 'admin';"

# Thiết lập quyền cho thư mục web
chown -R www-data:www-data $WEB_ROOT
chmod -R 755 $WEB_ROOT

# Thêm FS_METHOD nếu chưa có
if ! grep -q "FS_METHOD" "$WPCONFIG"; then
  echo "Thêm define('FS_METHOD', 'direct'); vào wp-config.php"
  sed -i "/^\/\* That.s all, stop editing/i define('FS_METHOD', 'direct');" "$WPCONFIG"
fi

cd "$WEBROOT" || exit 1

# Cài hoặc kích hoạt lại WP Reset
if ! wp plugin is-installed wp-reset --allow-root; then
  echo "Cài plugin WP Reset..."
  wp plugin install wp-reset --activate --allow-root
else
  wp plugin activate wp-reset --allow-root
fi

# Dọn sạch lại site qua plugin
echo "Xoá plugin..."
wp reset delete plugins --yes --allow-root
echo "Xoá theme..."
wp reset delete themes --yes --allow-root
echo "Xoá uploads..."
wp reset delete uploads --yes --allow-root
echo "Xoá transient..."
wp reset delete transients --yes --allow-root
echo "Xoá .htaccess..."
wp reset delete htaccess --yes --allow-root
echo "Xoá bảng custom..."
wp reset delete custom-tables --yes --allow-root

# Cài lại theme mặc định và reset site title
echo "Cài theme mặc định..."
wp theme install twentytwentyfour --activate --allow-root
wp option update blogname "New Clean Site" --allow-root

echo "Hoàn tất reset site $DOMAIN về trạng thái ban đầu!"
