#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Script này cần chạy với quyền root"
  exit 1
fi

# Kiểm tra số lượng tham số
if [ $# -eq 0 ]; then
  echo "Sử dụng: $0 property1:value1 property2:value2 ..."
  exit 1
fi

# Tìm file php.ini
PHP_INI=$(php -i | grep "Loaded Configuration File" | awk '{print $4}')

# Hàm restore backup và thoát
restore_and_exit() {
  local exit_code=$1
  local error_message=$2

  echo "Error: $error_message"

  if [ -f "$BACKUP_FILE" ]; then
    echo "Đang khôi phục backup..."
    cp "$BACKUP_FILE" "$PHP_INI"

    # Khởi động lại các dịch vụ sau khi restore
    if systemctl is-active --quiet php-fpm; then
      systemctl restart php-fpm
    elif systemctl is-active --quiet php7.4-fpm; then
      systemctl restart php7.4-fpm
    fi

    if systemctl is-active --quiet nginx; then
      systemctl restart nginx
    fi

    echo "Đã khôi phục thành công từ backup"
  fi

  exit $exit_code
}

# Tạo backup
BACKUP_FILE="/var/backups/${PHP_INI##*/}_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p /var/backups
cp "$PHP_INI" "$BACKUP_FILE" || restore_and_exit 1 "Không thể tạo backup"
echo "Đã tạo backup tại: $BACKUP_FILE"

# Kiểm tra file php.ini có tồn tại không
if [ ! -f "$PHP_INI" ]; then
  restore_and_exit 1 "Không tìm thấy file php.ini"
fi

# Hàm cập nhật giá trị trong php.ini
update_php_ini() {
  local property=$1
  local value=$2

  # Kiểm tra xem property đã tồn tại chưa
  if grep -q "^${property}\s*=" "$PHP_INI"; then
    # Thay thế giá trị nếu property đã tồn tại
    sed -i "s|^${property}\s*=.*|${property} = ${value}|" "$PHP_INI" ||
      restore_and_exit 1 "Không thể cập nhật property ${property}"
  else
    # Thêm property mới nếu chưa tồn tại
    echo "${property} = ${value}" >>"$PHP_INI" ||
      restore_and_exit 1 "Không thể thêm property ${property}"
  fi

  echo "Đã cập nhật: ${property} = ${value}"
}

# Xử lý từng cặp property:value
for pair in "$@"; do
  # Tách property và value
  property=$(echo $pair | cut -d: -f1)
  value=$(echo $pair | cut -d: -f2)

  if [ -z "$property" ] || [ -z "$value" ]; then
    restore_and_exit 1 "Định dạng không hợp lệ cho '$pair'. Sử dụng format 'property:value'"
  fi

  update_php_ini "$property" "$value"
done

# Kiểm tra cú pháp của file php.ini
php -l "$PHP_INI" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  restore_and_exit 1 "File php.ini có lỗi cú pháp"
fi
echo "Kiểm tra cú pháp php.ini thành công"

# Khởi động lại PHP-FPM
PHP_FPM_RESTARTED=false
if systemctl is-active --quiet php-fpm; then
  systemctl restart php-fpm || restore_and_exit 1 "Không thể khởi động lại PHP-FPM"
  PHP_FPM_RESTARTED=true
  echo "Đã khởi động lại PHP-FPM"
elif systemctl is-active --quiet php7.4-fpm; then
  systemctl restart php7.4-fpm || restore_and_exit 1 "Không thể khởi động lại PHP7.4-FPM"
  PHP_FPM_RESTARTED=true
  echo "Đã khởi động lại PHP7.4-FPM"
fi

if [ "$PHP_FPM_RESTARTED" = false ]; then
  restore_and_exit 1 "Không tìm thấy dịch vụ PHP-FPM"
fi

# Khởi động lại Nginx
if systemctl is-active --quiet nginx; then
  systemctl restart nginx || restore_and_exit 1 "Không thể khởi động lại Nginx"
  echo "Đã khởi động lại Nginx"
else
  restore_and_exit 1 "Không tìm thấy dịch vụ Nginx"
fi

echo "Cập nhật thành công!"
