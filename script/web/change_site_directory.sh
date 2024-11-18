#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra đầu vào
if [ "$#" -ne 2 ]; then
  echo "Error: Sử dụng cú pháp: $0 [tên_site] [new_directory]"
  echo "Ví dụ: $0 example.com /var/www/example_new"
  exit 1
fi

# Thay đổi biến
SITE_NAME="$1"
NEW_DIRECTORY="$2"
NGINX_CONF="/etc/nginx/sites-available/$SITE_NAME"
NEW_DIRECTORY_PATH="$NEW_DIRECTORY"

# Kiểm tra cấu hình Nginx có tồn tại không
if [ ! -f "$NGINX_CONF" ]; then
  echo "Error: Cấu hình Nginx cho site '$SITE_NAME' không tồn tại."
  exit 1
fi

# Tạo thư mục mới nếu chưa tồn tại
if [ ! -d "$NEW_DIRECTORY" ]; then
  echo "Thư mục mới không tồn tại. Tạo mới thư mục: $NEW_DIRECTORY"
  mkdir -p "$NEW_DIRECTORY"
  if [ $? -ne 0 ]; then
    echo "Error: Không thể tạo thư mục mới."
    exit 1
  fi
fi

# Cập nhật cấu hình Nginx với thư mục mới
echo "Cập nhật cấu hình Nginx để sử dụng thư mục mới: $NEW_DIRECTORY"
sed -i "s|root .*;|root $NEW_DIRECTORY;|" "$NGINX_CONF"

# Kiểm tra cú pháp cấu hình Nginx
nginx -t
if [ $? -ne 0 ]; then
  echo "Error: Cú pháp cấu hình Nginx không hợp lệ, không thể áp dụng thay đổi."
  exit 1
fi

# Khởi động lại Nginx để áp dụng thay đổi
systemctl restart nginx

echo "Thành công! Thư mục của site '$SITE_NAME' đã được thay đổi thành: $NEW_DIRECTORY"
