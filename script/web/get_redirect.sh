#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

# Gán biến
DOMAIN=$1
NGINX_SITE_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"

# Kiểm tra thư mục sites-available hoặc sites-enabled
if [ ! -d "$NGINX_SITE_DIR" ] && [ ! -d "$NGINX_ENABLED_DIR" ]; then
  echo "Error: Không tìm thấy thư mục cấu hình site của Nginx."
  exit 1
fi

# Tìm các tệp cấu hình liên quan đến domain
FOUND=0
for DIR in "$NGINX_SITE_DIR" "$NGINX_ENABLED_DIR"; do
  if [ -d "$DIR" ]; then
    while read -r conf_file; do
      if grep -q "$DOMAIN" "$conf_file"; then
        FOUND=1
        echo "Domain '$DOMAIN' tìm thấy trong: $conf_file"
        echo "--------------------------------------"
        # Tìm các redirect (rewrite, return, hoặc mã 301/302)
        grep -E "^[[:space:]]*(rewrite|return|301|302)" "$conf_file" || echo "Error: Không tìm thấy redirect nào."
        echo
      fi
    done < <(find "$DIR" -type f -name "*.conf")
  fi
done

# Kiểm tra nếu không tìm thấy kết quả
if [ "$FOUND" -eq 0 ]; then
  echo "Error: Không tìm thấy cấu hình nào liên quan đến domain '$DOMAIN'."
fi
