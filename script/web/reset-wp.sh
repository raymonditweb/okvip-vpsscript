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
# Kiểm tra mật khẩu MySQL
if ! mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "exit" >/dev/null 2>&1; then
  echo "Error: Mật khẩu MySQL không chính xác. Dừng lại."
  exit 1
fi

# Cài đặt các gói cần thiết
if ! command -v unzip >/dev/null; then
  apt install unzip -y
fi
if ! command -v certbot >/dev/null; then
  apt install certbot python3-certbot-nginx -y
fi
# Xóa chứng chỉ SSL
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
  certbot delete --cert-name "$DOMAIN" -n
  echo "Đã xóa chứng chỉ SSL cho $DOMAIN."
else
  echo "Không tìm thấy chứng chỉ SSL cho $DOMAIN."
fi
# Kiểm tra và xóa tham chiếu trong nginx.conf
if grep -q "$DOMAIN" /etc/nginx/nginx.conf; then
  sed -i "/$DOMAIN/d" /etc/nginx/nginx.conf
  echo "Đã xóa tham chiếu đến $DOMAIN trong nginx.conf."
else
  echo "Không tìm thấy tham chiếu đến $DOMAIN trong nginx.conf."
fi
# Tạo database và user MySQL
echo "Drop và tạo lại database $DB_NAME..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\`;"
USER_EXISTS=$(mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$DB_USER');")
if [ "$USER_EXISTS" -eq 1 ]; then
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
else
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
fi
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

# Tải và giải nén template
mkdir -p $WEBROOT
wget -O /tmp/template.zip "$TEMPLATE_URL" --no-check-certificate --quiet
if [ $? -ne 0 ]; then
  echo "Error: Không thể tải template từ URL $TEMPLATE_URL. Dừng lại."
  exit 1
fi
unzip -o /tmp/template.zip -d $WEBROOT

# Import database nếu có file db.sql
if [ -f "$WEBROOT/db.sql" ]; then
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" $DB_NAME < $WEBROOT/db.sql
  # Update option_value
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" $DB_NAME -e "UPDATE wp_options SET option_value = 'https://$DOMAIN' WHERE option_name IN ('siteurl', 'home');"
  # Xóa file db.sql sau khi import
  rm -f "$WEBROOT/db.sql"
  echo "File db.sql đã được xóa sau khi cài đặt thành công."
else
  echo "Error: Không tìm thấy file db.sql trong template. Dừng lại."
  exit 1
fi
REWRITE_FILE="/etc/nginx/rewrite/$DOMAIN.conf"

# Tạo thư mục chứa rewrite nếu chưa có
mkdir -p /etc/nginx/rewrite/

# Ghi nội dung rewrite vào file (ghi đè toàn bộ)
cat > "$REWRITE_FILE" <<EOF
location / {
        try_files \$uri \$uri/ /index.php?\$args;
}

location ~ /\.ht {
        deny all;
}
EOF

echo "Đã tạo file rewrite: $REWRITE_FILE"


rm -f /etc/nginx/sites-available/$DOMAIN
rm -f /etc/nginx/sites-enabled/$DOMAIN
# Cấu hình Nginx
cat > /etc/nginx/sites-available/$DOMAIN <<EOL
server {
    listen 80;
    server_name $DOMAIN;
    root $WEBROOT;

    index index.php index.html index.htm;

    # Include rewrite rules
    include $REWRITE_FILE;

    location ~ /.well-known/acme-challenge/ {
        allow all;
        root $WEBROOT;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    error_log /var/log/nginx/$DOMAIN-error.log;
    access_log /var/log/nginx/$DOMAIN-access.log;
}
EOL
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
# Kiểm tra và cài plugin nginx cho Certbot nếu chưa có
if ! certbot plugins | grep -q 'nginx'; then
  echo "Chưa có plugin nginx cho Certbot. Đang cài đặt..."
  apt update && apt install python3-certbot-nginx -y
fi

# Cài đặt SSL
if ! certbot certificates | grep -q "$DOMAIN"; then
  certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m no-reply@$DOMAIN --redirect
fi

# Cấu hình wp-config.php
if [ ! -f "$WEBROOT/wp-config.php" ]; then
  wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="localhost" --path=$WEBROOT --allow-root
fi
wp config set DB_NAME "$DB_NAME" --path=$WEBROOT --allow-root
wp config set DB_USER "$DB_USER" --path=$WEBROOT --allow-root
wp config set DB_PASSWORD "$DB_PASSWORD" --path=$WEBROOT --allow-root

# Cập nhật mật khẩu admin trực tiếp trong database
ADMIN_PASS_MD5=$(echo -n "$ADMIN_PASS" | md5sum | awk '{print $1}')
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" $DB_NAME -e "UPDATE wp_users SET user_pass = '$ADMIN_PASS_MD5' WHERE user_login = '$ADMIN_USERNAME' OR user_login = 'admin';"

# Thiết lập quyền cho thư mục web
chown -R www-data:www-data $WEBROOT
chmod -R 755 $WEBROOT

SITE_INFO_FILE="/var/www/$DOMAIN/site-info.conf"

cat > "$SITE_INFO_FILE" <<EOF
DOMAIN=$DOMAIN
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
ADMIN_USERNAME=$ADMIN_USERNAME
ADMIN_PASS=$ADMIN_PASS
TEMPLATE_URL=$TEMPLATE_URL
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
EOF

echo "Đã lưu thông tin cấu hình vào $SITE_INFO_FILE"