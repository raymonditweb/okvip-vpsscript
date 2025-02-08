#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra số lượng tham số đầu vào
if [ "$#" -ne 3 ]; then
  echo "Sử dụng: $0 old_domain new_domain mysql_root_password"
  echo "Ví dụ: $0 example.com newexample.com MyRootPass123"
  exit 1
fi

# Hàm rollback để khôi phục khi có lỗi
rollback() {
  echo "Error: Có lỗi xảy ra. Đang khôi phục lại trạng thái cũ..."

  # Khôi phục nginx config
  if [ -f "$BACKUP_DIR/$OLD_DOMAIN" ]; then
    cp "$BACKUP_DIR/$OLD_DOMAIN" "$NGINX_CONF_DIR/$OLD_DOMAIN"
    ln -sf "$NGINX_CONF_DIR/$OLD_DOMAIN" "$NGINX_ENABLED_DIR/$OLD_DOMAIN"
    rm -f "$NGINX_ENABLED_DIR/$NEW_DOMAIN" "$NGINX_CONF_DIR/$NEW_DOMAIN"
    systemctl restart nginx
  fi

  # Khôi phục thư mục website
  if [ -d "$WEB_ROOT_DIR/$NEW_DOMAIN" ]; then
    mv "$WEB_ROOT_DIR/$NEW_DOMAIN" "$WEB_ROOT_DIR/$OLD_DOMAIN"
  fi

  # Khôi phục wp-config
  if [ -f "$BACKUP_DIR/wp-config.php" ]; then
    cp "$BACKUP_DIR/wp-config.php" "$WEB_ROOT_DIR/$OLD_DOMAIN/wp-config.php"
  fi

  # Xóa database và user mới
  mysql -u root -p"$DB_ROOT_PASS" 2>/dev/null <<EOF
DROP DATABASE IF EXISTS $NEW_DB_NAME;
DROP USER IF EXISTS '$NEW_DB_USER'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

  echo "Đã khôi phục về trạng thái ban đầu!"
  exit 1
}

OLD_DOMAIN=$1
NEW_DOMAIN=$2
DB_ROOT_PASS=$3
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
WEB_ROOT_DIR="/var/www"

# Định dạng tên database và user
format_db_name() {
  echo "$1" | sed 's/\./_/g'
}

OLD_DB_NAME=$(format_db_name "$OLD_DOMAIN")
NEW_DB_NAME=$(format_db_name "$NEW_DOMAIN")
OLD_DB_USER="${OLD_DB_NAME}_user"
NEW_DB_USER="${NEW_DB_NAME}_user"
WP_CONFIG_PATH="$WEB_ROOT_DIR/$NEW_DOMAIN/wp-config.php"

# Tạo thư mục backup
mkdir -p "$BACKUP_DIR" || { echo "Không thể tạo thư mục backup"; exit 1; }

echo "Bắt đầu quá trình thay đổi domain từ $OLD_DOMAIN sang $NEW_DOMAIN..."

# 1️ Cập nhật cấu hình Nginx
echo "Cập nhật cấu hình Nginx..."
NGINX_CONF="$NGINX_CONF_DIR/$OLD_DOMAIN"
NEW_NGINX_CONF="$NGINX_CONF_DIR/$NEW_DOMAIN"

if [ -f "$NGINX_CONF" ]; then
  cp "$NGINX_CONF" "$BACKUP_DIR/$OLD_DOMAIN" || rollback
  sed -i "s/$OLD_DOMAIN/$NEW_DOMAIN/g" "$NGINX_CONF" || rollback
  mv "$NGINX_CONF" "$NEW_NGINX_CONF" || rollback
  ln -sf "$NEW_NGINX_CONF" "$NGINX_ENABLED_DIR/$NEW_DOMAIN" || rollback
  rm -f "$NGINX_ENABLED_DIR/$OLD_DOMAIN"
  systemctl restart nginx || rollback
  echo "Đã cập nhật Nginx config!"
else
  echo "Error: Không tìm thấy file cấu hình Nginx cho $OLD_DOMAIN"
  rollback
fi

# 2️ Đổi thư mục website
echo "Đổi thư mục website..."
if [ -d "$WEB_ROOT_DIR/$OLD_DOMAIN" ]; then
  mv "$WEB_ROOT_DIR/$OLD_DOMAIN" "$WEB_ROOT_DIR/$NEW_DOMAIN" || rollback
  echo "Đã chuyển thư mục website!"
else
  echo "Error: Không tìm thấy thư mục $WEB_ROOT_DIR/$OLD_DOMAIN"
  rollback
fi

# 3️ Cập nhật file wp-config.php
echo "Cập nhật file wp-config.php..."
if [ -f "$WP_CONFIG_PATH" ]; then
  cp "$WP_CONFIG_PATH" "$BACKUP_DIR/wp-config.php" || rollback
  sed -i "s/$OLD_DOMAIN/$NEW_DOMAIN/g" "$WP_CONFIG_PATH" || rollback
  sed -i "s/$OLD_DB_NAME/$NEW_DB_NAME/g" "$WP_CONFIG_PATH" || rollback
  sed -i "s/$OLD_DB_USER/$NEW_DB_USER/g" "$WP_CONFIG_PATH" || rollback
  echo "Đã cập nhật wp-config.php!"
else
  echo "Error: Không tìm thấy file wp-config.php tại $WP_CONFIG_PATH"
  rollback
fi

# 4️ Cập nhật MySQL user và database WordPress
echo "Cập nhật database WordPress..."

# Sao lưu database cũ
echo "Sao lưu database $OLD_DB_NAME..."
mysqldump -u root -p"$DB_ROOT_PASS" $OLD_DB_NAME 2>/dev/null >"$BACKUP_DIR/$OLD_DB_NAME.sql" || rollback
echo "Đã sao lưu database!"

# Tạo database mới
mysql -u root -p"$DB_ROOT_PASS" 2>/dev/null <<EOF || rollback
CREATE DATABASE IF NOT EXISTS $NEW_DB_NAME;
CREATE USER IF NOT EXISTS '$NEW_DB_USER'@'127.0.0.1' IDENTIFIED BY 'new_password';
GRANT ALL PRIVILEGES ON $NEW_DB_NAME.* TO '$NEW_DB_USER'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

# Sao chép dữ liệu từ database cũ sang database mới
echo "Sao chép dữ liệu từ $OLD_DB_NAME sang $NEW_DB_NAME..."
mysql -u root -p"$DB_ROOT_PASS" $NEW_DB_NAME 2>/dev/null <"$BACKUP_DIR/$OLD_DB_NAME.sql" || rollback
echo "Đã sao chép dữ liệu thành công!"

echo "Backup đã được lưu tại: $BACKUP_DIR"
echo "Quá trình thay đổi domain từ $OLD_DOMAIN sang $NEW_DOMAIN đã hoàn tất!"
