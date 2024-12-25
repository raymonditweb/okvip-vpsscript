#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Đường dẫn thư mục chứa các tệp cấu hình Nginx
NGINX_CONF_DIR="/etc/nginx/sites-enabled"

# Kiểm tra nếu thư mục tồn tại
if [ ! -d "$NGINX_CONF_DIR" ]; then
  echo "Error: Thư mục cấu hình Nginx không tồn tại: $NGINX_CONF_DIR"
  exit 1
fi

# Tìm tất cả các domain trong các tệp cấu hình Nginx
echo "Đang kiểm tra trạng thái SSL cho các domain trong Nginx..."
for CONF_FILE in "$NGINX_CONF_DIR"/*; do
  if [ -f "$CONF_FILE" ]; then
    DOMAINS=$(grep -E "server_name" "$CONF_FILE" | awk '{for (i=2; i<=NF; i++) print $i}' | sed 's/;$//')
    for DOMAIN in $DOMAINS; do
      # Kiểm tra SSL cho từng domain
      echo -n "Kiểm tra domain: $DOMAIN... "
      SSL_INFO=$(echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)

      if [ -z "$SSL_INFO" ]; then
        echo "Không có SSL"
      else
        echo "Có SSL"
      fi
    done
  fi
done
