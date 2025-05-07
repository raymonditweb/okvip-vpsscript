#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root."
  exit 1
fi

# Đọc thông tin đầu vào
MYSQL_ROOT_PASSWORD=$1
DOMAIN=$2
WEBROOT="/var/www/$DOMAIN"
WPCONFIG="$WEBROOT/wp-config.php"

if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$DOMAIN" ]; then
  echo "Error: Sử dụng <mysql_root_password> <domain> "
  exit 1
fi

if [ ! -f "$WPCONFIG" ]; then
  echo "Error: Không tìm thấy wp-config.php tại $WPCONFIG"
  exit 1
fi

# Trích xuất thông tin từ wp-config.php
get_wp_config_value() {
  grep "define( *'${1}'" "$WPCONFIG" | cut -d"'" -f4
}

DB_NAME=$(get_wp_config_value DB_NAME)
DB_USER=$(get_wp_config_value DB_USER)
DB_PASSWORD=$(get_wp_config_value DB_PASSWORD)

cd "$WEBROOT" || exit 1

# Kiểm tra kết nối MySQL
if ! mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "exit" >/dev/null 2>&1; then
  echo "Error:Mật khẩu root MySQL sai hoặc không kết nối được!"
  exit 1
fi

echo "Bắt đầu reset domain $DOMAIN"

# Xoá plugins, themes, uploads
echo "Xoá plugins..."
rm -rf wp-content/plugins/*

echo "Xoá themes..."
rm -rf wp-content/themes/*

echo "Xoá uploads..."
rm -rf wp-content/uploads/*

echo "Xoá file .htaccess nếu có..."
rm -f .htaccess

# Xoá transient options
echo "Xoá transient trong database..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "
  DELETE FROM wp_options WHERE option_name LIKE '%transient%';
"

# Xoá bảng custom không thuộc wp_
echo "Tìm và xoá bảng custom..."
CUSTOM_TABLES=$(mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -Nse "
  SELECT table_name FROM information_schema.tables 
  WHERE table_schema = '$DB_NAME' 
    AND table_name NOT LIKE 'wp_%';
")
for table in $CUSTOM_TABLES; do
  echo "Xoá bảng: $table"
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "DROP TABLE \`$table\`;"
done

# Cài lại theme mặc định + site title
echo "Cài theme mặc định..."
wp theme install twentytwentyfour --activate --allow-root

echo "Cập nhật tiêu đề site..."
wp option update blogname "New Clean Site" --allow-root
