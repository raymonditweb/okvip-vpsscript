#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra số lượng tham số đầu vào
if [ "$#" -ne 2 ]; then
  echo "Sử dụng: $0 old_domain new_domain"
  echo "Ví dụ: $0 example.com newexample.com"
  exit 1
fi

OLD_DOMAIN=$1
NEW_DOMAIN=$2
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
WEB_ROOT_DIR="/var/www"
WP_CONFIG_PATH="$WEB_ROOT_DIR/$NEW_DOMAIN/wp-config.php"

# Tạo thư mục backup
mkdir -p "$BACKUP_DIR"

# Hàm khôi phục từ backup nếu có lỗi
restore_from_backup() {
  echo "Đang khôi phục từ backup..."
  find "$BACKUP_DIR" -type f | while IFS= read -r backup_file; do
    original_file="${backup_file#$BACKUP_DIR/}"
    if [ -f "$backup_file" ]; then
      cp "$backup_file" "$original_file"
      echo "Đã khôi phục: $original_file"
    fi
  done
  echo "Quá trình khôi phục hoàn tất!"
  exit 1
}

# Bẫy lỗi để tự động khôi phục khi có lỗi
trap 'echo "Error: xảy ra! Tiến hành khôi phục..."; restore_from_backup' ERR INT TERM

# 1. Cập nhật cấu hình Nginx
echo "Cập nhật cấu hình Nginx..."
NGINX_CONF="$NGINX_CONF_DIR/$OLD_DOMAIN"
NEW_NGINX_CONF="$NGINX_CONF_DIR/$NEW_DOMAIN"

if [ -f "$NGINX_CONF" ]; then
  cp "$NGINX_CONF" "$BACKUP_DIR/$OLD_DOMAIN"
  sed -i "s/$OLD_DOMAIN/$NEW_DOMAIN/g" "$NGINX_CONF"
  mv "$NGINX_CONF" "$NEW_NGINX_CONF"
  ln -sf "$NEW_NGINX_CONF" "$NGINX_ENABLED_DIR/$NEW_DOMAIN"
  rm -f "$NGINX_ENABLED_DIR/$OLD_DOMAIN"
  echo "Đã cập nhật Nginx config!"
else
  echo "Error: Không tìm thấy file cấu hình Nginx cho $OLD_DOMAIN"
fi

systemctl restart nginx

# 2. Đổi thư mục website
echo "Đổi thư mục website..."
if [ -d "$WEB_ROOT_DIR/$OLD_DOMAIN" ]; then
  mv "$WEB_ROOT_DIR/$OLD_DOMAIN" "$WEB_ROOT_DIR/$NEW_DOMAIN"
  echo "Đã chuyển thư mục website!"
else
  echo "Error: Không tìm thấy thư mục $WEB_ROOT_DIR/$OLD_DOMAIN"
fi

# 3. Cập nhật file wp-config.php
echo "Cập nhật file wp-config.php..."
if [ -f "$WP_CONFIG_PATH" ]; then
  cp "$WP_CONFIG_PATH" "$BACKUP_DIR/wp-config.php"
  sed -i "s/$OLD_DOMAIN/$NEW_DOMAIN/g" "$WP_CONFIG_PATH"
  echo "Đã cập nhật wp-config.php!"
else
  echo "Error: Không tìm thấy file wp-config.php tại $WP_CONFIG_PATH"
fi

# 4. Cập nhật domain trong database WordPress
echo "Cập nhật domain trong database WordPress..."
DB_NAME=$(grep DB_NAME "$WP_CONFIG_PATH" | cut -d "'" -f 4)
DB_USER=$(grep DB_USER "$WP_CONFIG_PATH" | cut -d "'" -f 4)
DB_PASS=$(grep DB_PASSWORD "$WP_CONFIG_PATH" | cut -d "'" -f 4)

if [[ -n "$DB_NAME" && -n "$DB_USER" && -n "$DB_PASS" ]]; then
  mysql -u"$DB_USER" -p"$DB_PASS" -e "
    UPDATE $DB_NAME.wp_options SET option_value = '$NEW_DOMAIN' WHERE option_name IN ('siteurl', 'home');
  "
  echo "Đã cập nhật domain trong database!"
else
  echo "Error: Không thể trích xuất thông tin database từ wp-config.php"
  restore_from_backup
fi

echo "Backup đã được lưu tại: $BACKUP_DIR"
echo "Quá trình thay đổi domain từ $OLD_DOMAIN sang $NEW_DOMAIN đã hoàn tất!"
