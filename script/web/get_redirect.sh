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
NGINX_CONF_DIRS=("/etc/nginx/sites-available" "/etc/nginx/sites-enabled" "/etc/nginx/conf.d" "/etc/nginx/nginx.conf" "/etc/nginx/conf.d/multiple_redirects.conf")

# Biến kiểm tra có tìm thấy redirect không
FOUND=0

# Duyệt qua các thư mục cấu hình Nginx
for DIR in "${NGINX_CONF_DIRS[@]}"; do
  if [ -d "$DIR" ]; then
    while read -r conf_file; do
      if grep -qE "server_name.*$DOMAIN" "$conf_file"; then
        FOUND=1
        echo "Domain '$DOMAIN' tìm thấy trong: $conf_file"
        echo

        # Tìm kiếm các dòng liên quan đến redirect 301, 302
        grep -E "^[[:space:]]*(rewrite|return).*(301|302)" "$conf_file" || echo "Không tìm thấy redirect nào."

        echo
      fi
    done < <(find "$DIR" -type f -name "*.conf" 2>/dev/null)
  fi

  # Kiểm tra file cấu hình cụ thể cho multiple redirects
  if [ -f "$DIR" ]; then
    if grep -qE "server_name.*$DOMAIN" "$DIR"; then
      FOUND=1
      echo "Domain '$DOMAIN' được tìm thấy trong: $DIR"
      echo
      grep -E "^[[:space:]]*(rewrite|return).*(301|302)" "$DIR" || echo "Error: Không tìm thấy redirect nào."
    fi
  fi

done

if [ "$FOUND" -eq 0 ]; then
  echo "Error: Không tìm thấy cấu hình nào liên quan đến domain '$DOMAIN'."
fi
