#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra xem tham số domain đã được cung cấp hay chưa
if [ -z "$1" ]; then
  echo "Error: Domain không hợp lệ!"
  echo "Ví dụ đúng: example.com"
  exit 1
fi

# Lấy domain từ tham số
DOMAIN=$1

# Đường dẫn tới file wp-config.php (theo domain)
WP_CONFIG="/var/www/$DOMAIN/wp-config.php"

# Kiểm tra xem file wp-config.php có tồn tại hay không
if [ ! -f "$WP_CONFIG" ]; then
  echo "Error: Không tìm thấy file wp-config.php tại $WP_CONFIG"
  exit 1
fi

# Lấy MySQL username và password từ wp-config.php
DB_USER=$(grep -oP "define\('DB_USER', '\K(.*?)(?='\))" $WP_CONFIG)
echo "$DB_USER"

DB_PASS=$(grep -oP "define\('DB_PASSWORD', '\K(.*?)(?='\))" $WP_CONFIG)
echo "$DB_PASS"

# Xác định tên cơ sở dữ liệu từ domain (thay dấu . bằng _)
DB_NAME="${DOMAIN//./_}"

# Cấu hình MySQL host
DB_HOST="localhost"

# File xuất dữ liệu
OUTPUT_FILE="backup_${DB_NAME}.sql"

# Thực hiện dump cơ sở dữ liệu MySQL
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME >$OUTPUT_FILE

# Kiểm tra kết quả
if [ $? -eq 0 ]; then
  echo "Export database $DB_NAME thành công! File: $OUTPUT_FILE"
else
  echo "Error: Co lỗi khi xuất dữ liệu từ $DB_NAME."
fi
