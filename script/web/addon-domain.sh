#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra OS có phải là Ubuntu hay không
OS=$(lsb_release -si)
VERSION=$(lsb_release -sr)
if [[ "$OS" != "Ubuntu" ]]; then
  echo "Error: Script này chỉ hỗ trợ Ubuntu."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: Vui lòng cung cấp domain chính và alias domain."
  echo "Usage: $0 <primary_domain*> <alias_domain*>"
  exit 1
fi

PRIMARY_DOMAIN=$1
ALIAS_DOMAIN=$2

# Đường dẫn cấu hình Nginx
NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_CONF_FILE="$NGINX_CONF_DIR/$PRIMARY_DOMAIN"

# Kiểm tra website chính đã tồn tại hay chưa
if [ ! -f "$NGINX_CONF_FILE" ]; then
  echo "Error: Không tìm thấy cấu hình cho website chính $PRIMARY_DOMAIN."
  exit 1
fi

# Thêm alias domain vào cấu hình Nginx
if grep -q "$ALIAS_DOMAIN" "$NGINX_CONF_FILE"; then
  echo "Alias domain $ALIAS_DOMAIN đã tồn tại trong cấu hình Nginx của $PRIMARY_DOMAIN."
else
  sed -i "/server_name/s/$/ $ALIAS_DOMAIN;/" "$NGINX_CONF_FILE"
  echo "Alias domain $ALIAS_DOMAIN đã được thêm vào cấu hình Nginx của $PRIMARY_DOMAIN."
fi

# Kiểm tra cấu hình Nginx
nginx -t
if [ $? -eq 0 ]; then
  echo "Cấu hình Nginx hợp lệ."
  # Tải lại Nginx để áp dụng thay đổi
  systemctl reload nginx
  echo "Nginx đã được tải lại."
else
  echo "Error: Cấu hình Nginx không hợp lệ, vui lòng kiểm tra lại."
  exit 1
fi

echo "Quá trình thêm alias domain vào website hoàn tất."
