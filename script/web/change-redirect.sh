#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số
if [ "$#" -ne 4 ]; then
  echo "Error: Sử dụng: $0 <domain> <redirect_type> <target_url> <target_new_url> <new_redirect_type>"
  exit 1
fi

DOMAIN=$1
REDIRECT_TYPE=$2
TARGET_URL=$3
TARGET_NEW_URL=$4
NEW_REDIRECT_TYPE=$5

# Kiểm tra redirect_type hợp lệ không
if [[ "$REDIRECT_TYPE" != "301" && "$REDIRECT_TYPE" != "302" && "$NEW_REDIRECT_TYPE" != "301" && "$NEW_REDIRECT_TYPE" != "302" ]]; then
  echo "Error: Chế độ redirect chỉ có thể là 301 hoặc 302."
  exit 1
fi

# Loại bỏ dấu '/' ở cuối URL nếu có
TARGET_URL=$(echo "$TARGET_URL" | sed 's:/*$::')

# Đường dẫn file cấu hình
CONFIG_FILE="/etc/nginx/sites-available/$DOMAIN"

# Kiểm tra file cấu hình có tồn tại không
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: File cấu hình $CONFIG_FILE không tồn tại."
  exit 1
fi

# Tạo bản sao lưu trước khi sửa
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Xóa dòng redirect cũ tương ứng với loại redirect được chọn
sed -i "s|return $REDIRECT_TYPE $TARGET_URL\$request_uri;|return $NEW_REDIRECT_TYPE $TARGET_NEW_URL\$request_uri;|g" "$CONFIG_FILE"

# Kiểm tra cấu hình Nginx
if ! nginx -t; then
  echo "Error: Lỗi cấu hình Nginx. Khôi phục bản sao lưu."
  mv "$CONFIG_FILE.bak" "$CONFIG_FILE"
  exit 1
fi

# Tải lại Nginx
systemctl reload nginx
echo "Thay đổi cấu hình redirect ($REDIRECT_TYPE) đến $TARGET_URL thành công!"
