#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra và gán các đối số
MYSQL_ROOT_PASSWORD=$1
SOURCE_SITE=$2
TARGET_SITE=$3

if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$SOURCE_SITE" ] || [ -z "$TARGET_SITE" ]; then
  echo "Error: Vui lòng truyền vào MySQL root password, site cần clone và site mới."
  echo "Usage: $0 <mysql_root_password> <source_site> <target_site>"
  exit 1
fi

# Đường dẫn thư mục web
WEB_ROOT="/var/www"

# Kiểm tra nếu site gốc đã tồn tại
SOURCE_DIR="$WEB_ROOT/$SOURCE_SITE"
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Site gốc $SOURCE_SITE không tồn tại."
  exit 1
fi

# Tạo thư mục cho site mới
TARGET_DIR="$WEB_ROOT/$TARGET_SITE"
if [ -d "$TARGET_DIR" ]; then
  echo "Error: Thư mục $TARGET_DIR đã tồn tại."
  exit 1
fi
mkdir "$TARGET_DIR"

# Clone source code
cp -r "$SOURCE_DIR/" "$TARGET_DIR"
echo "Đã clone source code từ $SOURCE_DIR sang $TARGET_DIR."

# Tạo database và user cho site mới
TARGET_DB="${TARGET_SITE//./_}"
TARGET_USER="${TARGET_DB}_user"
TARGET_PASSWORD=$(openssl rand -base64 12)

# Kiểm tra nếu database và user đã tồn tại
DB_EXISTS=$(mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES LIKE '$TARGET_DB';" | grep "$TARGET_DB")
USER_EXISTS=$(mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT User FROM mysql.user WHERE User = '$TARGET_USER';" | grep "$TARGET_USER")

if [ -z "$DB_EXISTS" ]; then
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $TARGET_DB;"
  echo "Đã tạo database $TARGET_DB."
else
  echo "Database $TARGET_DB đã tồn tại."
fi

if [ -z "$USER_EXISTS" ]; then
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$TARGET_USER'@'localhost' IDENTIFIED BY '$TARGET_PASSWORD';"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $TARGET_DB.* TO '$TARGET_USER'@'localhost';"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
  echo "Đã tạo user $TARGET_USER với quyền truy cập vào database $TARGET_DB."
else
  echo "User $TARGET_USER đã tồn tại."
fi

# Export database của site gốc và import vào site mới
SOURCE_DB="${SOURCE_SITE//./_}"
mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" "$SOURCE_DB" > "/tmp/${SOURCE_DB}.sql"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$TARGET_DB" < "/tmp/${SOURCE_DB}.sql"
rm "/tmp/${SOURCE_DB}.sql"
echo "Đã clone database từ $SOURCE_DB sang $TARGET_DB."

# Cấu hình database trong site mới (ví dụ, nếu dùng WordPress)
CONFIG_FILE="$TARGET_DIR/wp-config.php"
if [ -f "$CONFIG_FILE" ]; then
  sed -i "s/define('DB_NAME', '.*');/define('DB_NAME', '$TARGET_DB');/" "$CONFIG_FILE"
  sed -i "s/define('DB_USER', '.*');/define('DB_USER', '$TARGET_USER');/" "$CONFIG_FILE"
  sed -i "s/define('DB_PASSWORD', '.*');/define('DB_PASSWORD', '$TARGET_PASSWORD');/" "$CONFIG_FILE"
  echo "Đã cấu hình database cho $TARGET_SITE."
fi

# Đổi URL trong database
OLD_URL="http://$SOURCE_SITE"
NEW_URL="http://$TARGET_SITE"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -D "$TARGET_DB" -e "
UPDATE wp_options SET option_value = '$NEW_URL' WHERE option_name = 'siteurl' OR option_name = 'home';
UPDATE wp_posts SET guid = REPLACE(guid, '$OLD_URL', '$NEW_URL');
UPDATE wp_posts SET post_content = REPLACE(post_content, '$OLD_URL', '$NEW_URL');
UPDATE wp_postmeta SET meta_value = REPLACE(meta_value, '$OLD_URL', '$NEW_URL');"
echo "Đã thay đổi URL từ $OLD_URL sang $NEW_URL trong database $TARGET_DB."

echo "Quá trình clone website hoàn tất. Bạn có thể truy cập $TARGET_SITE."
