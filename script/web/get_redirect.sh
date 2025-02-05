#!/bin/bash

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

# Gán biến
DOMAIN=$1
NGINX_CONF_DIRS=(
  "/etc/nginx/sites-available"
  "/etc/nginx/sites-enabled"
  "/etc/nginx/conf.d"
)
NGINX_CONF_FILES=(
  "/etc/nginx/nginx.conf"
  "/etc/nginx/conf.d/multiple_redirects.conf"
)

# Biến kiểm tra có tìm thấy redirect không
FOUND=0

# Duyệt qua các thư mục chứa file cấu hình Nginx
for DIR in "${NGINX_CONF_DIRS[@]}"; do
  if [[ -d $DIR ]]; then
    while IFS= read -r conf_file; do
      if grep -qE "server_name.*$DOMAIN" "$conf_file"; then
        FOUND=1
        echo "Domain '$DOMAIN' tìm thấy trong: $conf_file"
        echo

        # Tìm kiếm redirect 301, 302
        if ! grep -E "^[[:space:]]*(rewrite|return).* (301|302)" "$conf_file"; then
          echo "Không tìm thấy redirect nào."
        fi
        echo
      fi
    done < <(find "$DIR" -type f -name "*.conf" 2>/dev/null)
  fi
done

# Kiểm tra các file cấu hình riêng lẻ
for FILE in "${NGINX_CONF_FILES[@]}"; do
  if [[ -f $FILE && $(grep -qE "server_name.*$DOMAIN" "$FILE") ]]; then
    FOUND=1
    echo "Domain '$DOMAIN' được tìm thấy trong: $FILE"
    echo
    if ! grep -E "^[[:space:]]*(rewrite|return).* (301|302)" "$FILE"; then
      echo "Error: Không tìm thấy redirect nào."
    fi
  fi
done

# Thông báo nếu không tìm thấy domain
if [[ $FOUND -eq 0 ]]; then
  echo "Error: Không tìm thấy cấu hình nào liên quan đến domain '$DOMAIN'."
fi
