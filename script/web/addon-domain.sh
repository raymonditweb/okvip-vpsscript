#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra OS có phải là Ubuntu hay không
if ! command -v lsb_release &>/dev/null || [[ $(lsb_release -si) != "Ubuntu" ]]; then
  echo "Error: Script này chỉ hỗ trợ Ubuntu."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ $# -ne 2 ]; then
  echo "Error: Vui lòng cung cấp domain chính và alias domain. Usage: $0 <primary_domain> <alias_domain>"
  exit 1
fi

PRIMARY_DOMAIN=$1
ALIAS_DOMAIN=$2

# Đường dẫn cấu hình Nginx
NGINX_CONF_FILE="/etc/nginx/sites-available/$PRIMARY_DOMAIN"

# Kiểm tra website chính đã tồn tại hay chưa
if [ ! -f "$NGINX_CONF_FILE" ]; then
  echo "Error: Không tìm thấy cấu hình cho website chính $PRIMARY_DOMAIN."
  exit 1
fi

# Kiểm tra alias domain đã tồn tại hay chưa trong cấu hình Nginx
if grep -qw "$ALIAS_DOMAIN" "$NGINX_CONF_FILE"; then
  echo "Alias domain $ALIAS_DOMAIN đã tồn tại trong cấu hình Nginx của $PRIMARY_DOMAIN."
else
  sed -i "/server_name/s/$/ $ALIAS_DOMAIN;/" "$NGINX_CONF_FILE"
  echo "Alias domain $ALIAS_DOMAIN đã được thêm vào cấu hình Nginx của $PRIMARY_DOMAIN."
fi

# Kiểm tra cấu hình Nginx
if nginx -t; then
  echo "Cấu hình Nginx hợp lệ."
  systemctl reload nginx
  echo "Nginx đã được tải lại."
else
  echo "Error: Cấu hình Nginx không hợp lệ, vui lòng kiểm tra lại."
  exit 1
fi

echo "Quá trình thêm alias domain vào website hoàn tất."
