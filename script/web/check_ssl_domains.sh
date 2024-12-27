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
    # Trích xuất danh sách domain từ tệp cấu hình
    DOMAINS=$(grep -E "server_name" "$CONF_FILE" | awk '{for (i=2; i<=NF; i++) print $i}' | sed 's/;$//' | grep -Ev "^_|^localhost$|^server_name$")

    for DOMAIN in $DOMAINS; do
      echo -n "Kiểm tra domain: $DOMAIN... "

      # Kiểm tra ngày hết hạn của SSL từ certbot
      CERTBOT_EXPIRY=$(certbot certificates 2>/dev/null | grep -A2 "Domains: $DOMAIN" | grep "Expiry Date" | awk -F': ' '{print $2}')

      if [ -n "$CERTBOT_EXPIRY" ]; then
        echo "Có SSL - Hết hạn: $CERTBOT_EXPIRY"
      else
        # Nếu không có thông tin từ certbot, kiểm tra trực tiếp bằng openssl
        SSL_INFO=$(timeout 10 bash -c "echo | openssl s_client -connect \"$DOMAIN:443\" -servername \"$DOMAIN\" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null")
        if [ -n "$SSL_INFO" ]; then
          END_DATE=$(echo "$SSL_INFO" | grep "notAfter=" | cut -d= -f2)
          echo "Có SSL (openssl) - Ngày hết hạn: $END_DATE"
        else
          echo "Không tìm thấy SSL"
        fi
      fi
    done
  fi
done
