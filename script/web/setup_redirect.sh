#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số
if [ "$#" -ne 3 ]; then
  echo "Error: Sử dụng: $0 <domain> <target_url> <redirect_type>"
  exit 1
fi

DOMAIN=$1
TARGET_URL=$2
REDIRECT_TYPE=$3

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

# Xóa dòng redirect cũ (nếu có)
sed -i '/return 301/d' "$CONFIG_FILE"
sed -i '/return 302/d' "$CONFIG_FILE"

# Thêm redirect mới sau "listen 443 ssl;"
sed -i '/listen 443 ssl;/a \    return '"$REDIRECT_TYPE"' '"$TARGET_URL"'$request_uri;' "$CONFIG_FILE"

# Thêm redirect mới sau "listen 80;"
sed -i '/listen 80;/a \    return '"$REDIRECT_TYPE"' '"$TARGET_URL"'$request_uri;' "$CONFIG_FILE"

# Kiểm tra cấu hình Nginx
if ! nginx -t; then
  echo "Error: Lỗi cấu hình Nginx. Khôi phục bản sao lưu."
  mv "$CONFIG_FILE.bak" "$CONFIG_FILE"
  exit 1
fi

# Tải lại Nginx
systemctl reload nginx
echo "Cấu hình redirect ($REDIRECT_TYPE) đến $TARGET_URL thành công!"
