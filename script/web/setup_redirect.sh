#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra xem có đủ tham số hay không
if [ "$#" -ne 3 ]; then
  echo "Error: Su dung: $0 <domain_or_path> <redirect_type> <target>"
  exit 1
fi

DOMAIN_OR_PATH=$1
REDIRECT_TYPE=$2
TARGET=$3

# Kiểm tra quyền ghi tệp
CONFIG_FILE="/etc/nginx/sites-available/$DOMAIN_OR_PATH.conf"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Tạo tệp cấu hình: $CONFIG_FILE"
  touch "$CONFIG_FILE"
fi

# Tạo bản sao lưu của tệp cấu hình
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Kiểm tra và ghi tệp
if ! grep -q "server_name" "$CONFIG_FILE"; then
  cat <<EOL >> "$CONFIG_FILE"

server {
  listen 80;
  server_name $DOMAIN_OR_PATH;

  location / {
    return $REDIRECT_TYPE $TARGET;
  }
}
EOL
else
  if ! grep -q "location / {" "$CONFIG_FILE"; then
    sed -i "/server_name/a \    location / {
        return $REDIRECT_TYPE $TARGET;
    }" "$CONFIG_FILE"
  else
    sed -i "/location \/ {/!b;n;s/return [0-9]* .*/return $REDIRECT_TYPE $TARGET;/" "$CONFIG_FILE"
  fi
fi

# Kiểm tra lỗi cấu hình Nginx
if ! nginx -t; then
  echo "Error: Lỗi cấu hình Nginx. Khôi phục bản sao lưu."
  mv "$CONFIG_FILE.bak" "$CONFIG_FILE"
  exit 1
fi

# Tải lại Nginx
systemctl reload nginx
