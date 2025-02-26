#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Script này cần chạy với quyền root"
  exit 1
fi

# Kiểm tra xem người dùng có nhập domain không
if [ -z "$1" ]; then
  echo "Cách sử dụng: $0 <domain>"
  exit 1
fi

# Lấy domain từ tham số đầu vào
DOMAIN="$1"
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
NGINX_LINK="/etc/nginx/sites-enabled/$DOMAIN"
WEB_ROOT="/var/www/$DOMAIN"

# Cài đặt Nginx nếu chưa có
if ! command -v nginx &>/dev/null; then
  echo "Nginx chưa được cài đặt. Đang tiến hành cài đặt..."
  apt update
  apt install -y nginx
fi

# Tạo thư mục web nếu chưa tồn tại
if [ ! -d "$WEB_ROOT" ]; then
  mkdir -p "$WEB_ROOT"
  chown -R www-data:www-data "$WEB_ROOT"
fi

# Nếu file cấu hình đã tồn tại, chỉ cập nhật phần URL Rewrite
if [ -f "$NGINX_CONF" ]; then
  echo "File cấu hình Nginx đã tồn tại. Kiểm tra và cập nhật..."

  # Kiểm tra và thêm URL Rewrite nếu chưa có
  if ! grep -q "try_files \$uri \$uri/ /index.php?\$args;" "$NGINX_CONF"; then
    echo "Thêm cấu hình URL Rewrite..."
    sed -i '/location \/ {/a \        try_files \$uri \$uri/ /index.php?\$args;' "$NGINX_CONF"
  else
    echo "URL Rewrite đã có sẵn, không cần cập nhật."
  fi

  # Kiểm tra và thêm redirect wp-admin nếu chưa có
  if ! grep -q "rewrite /wp-admin$ \$scheme://\$host\$uri/ permanent;" "$NGINX_CONF"; then
    echo "Thêm redirect /wp-admin..."
    echo -e "\n    rewrite /wp-admin$ \$scheme://\$host\$uri/ permanent;" >>"$NGINX_CONF"
  else
    echo "Redirect /wp-admin đã có sẵn."
  fi

else
  echo "Tạo file cấu hình Nginx mới tại: $NGINX_CONF"

  cat >"$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    root $WEB_ROOT;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock; # Kiểm tra phiên bản PHP của bạn
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|otf|ttc|font.css)$ {
        expires max;
        log_not_found off;
    }

    location = /robots.txt { allow all; log_not_found off; access_log off; }
    location = /favicon.ico { log_not_found off; access_log off; }

    error_page 404 /index.php;

    location ~ /\.ht {
        deny all;
    }

    # Redirect wp-admin
    rewrite /wp-admin$ \$scheme://\$host\$uri/ permanent;
}
EOF
fi

# Kiểm tra nếu symbolic link đã tồn tại, nếu không thì tạo mới
if [ ! -L "$NGINX_LINK" ]; then
  ln -sf "$NGINX_CONF" "$NGINX_LINK"
fi

# Kiểm tra lỗi và khởi động lại Nginx
nginx -t && systemctl restart nginx

echo "Cấu hình Nginx đã được cập nhật"
