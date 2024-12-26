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
        
        # Thiết lập thời gian chờ tối đa 1 phút (60 giây)
        SSL_INFO=$(timeout 60 bash -c "echo | openssl s_client -connect \"$DOMAIN:443\" -servername \"$DOMAIN\" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null")

        if [ -z "$SSL_INFO" ]; then
            echo "Không có SSL"
        else
            EXPIRY_DATE=$(echo "$SSL_INFO" | grep 'notAfter' | cut -d= -f2)
            echo "Có SSL (Hết hạn: $EXPIRY_DATE)"
        fi
    done
  fi
done
