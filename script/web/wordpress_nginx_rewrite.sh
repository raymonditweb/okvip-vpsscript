#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Script này cần chạy với quyền root"
  exit 1
fi

# Kiểm tra xem người dùng có nhập đủ tham số không
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Cách sử dụng: $0 <domain> <đoạn cấu hình cần thêm>"
  exit 1
fi

DOMAIN="$1"
EXTRA_CONFIG="$2"
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
NGINX_LINK="/etc/nginx/sites-enabled/$DOMAIN"
WEB_ROOT="/var/www/$DOMAIN"

# Cài đặt nginx nếu chưa có
if ! command -v nginx &>/dev/null; then
  echo "Nginx chưa được cài đặt. Đang tiến hành cài đặt..."
  apt update
  apt install -y nginx
fi

# Tạo thư mục web nếu chưa có
if [ ! -d "$WEB_ROOT" ]; then
  mkdir -p "$WEB_ROOT"
  chown -R www-data:www-data "$WEB_ROOT"
fi

# Backup nếu file conf đã tồn tại
if [ -f "$NGINX_CONF" ]; then
  cp "$NGINX_CONF" "$NGINX_CONF.bak"
  echo "Đã backup cấu hình Nginx tại: $NGINX_CONF.bak"
fi

# Nếu file cấu hình đã tồn tại, chỉ cập nhật thêm rewrite
if [ -f "$NGINX_CONF" ]; then
  echo "File cấu hình Nginx đã tồn tại. Kiểm tra và cập nhật..."

  if ! grep -qE "location / ?\{|\blocation /typecho/|\brewrite\b" "$NGINX_CONF"; then
    echo "Thêm đoạn cấu hình vào file..."
    awk -v config="$EXTRA_CONFIG" '
      BEGIN { added=0 }
      /error_log/ && added==0 {
        print "# AUTO CONFIG START"
        print config
        print "# AUTO CONFIG END"
        added=1
      }
      { print }
    ' "$NGINX_CONF" > "${NGINX_CONF}.tmp" && mv "${NGINX_CONF}.tmp" "$NGINX_CONF"
  else
    echo "Error: Đoạn cấu hình đã tồn tại, không cần thêm."
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
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
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

    rewrite /wp-admin$ \$scheme://\$host\$uri/ permanent;

    # AUTO CONFIG START
    $EXTRA_CONFIG
    # AUTO CONFIG END
}
EOF
fi

# Tạo symlink nếu chưa có
if [ ! -L "$NGINX_LINK" ]; then
  ln -sf "$NGINX_CONF" "$NGINX_LINK"
fi

# Kiểm tra cấu hình nginx
if ! nginx -t; then
  echo "Error: Cấu hình Nginx lỗi! Khôi phục lại từ backup..."
  if [ -f "$NGINX_CONF.bak" ]; then
    mv "$NGINX_CONF.bak" "$NGINX_CONF"
    echo "Đã khôi phục file cấu hình từ bản backup."
  fi
  exit 1
else
  # Nếu OK, xóa backup
  rm -f "$NGINX_CONF.bak"
fi

# Khởi động lại nginx
systemctl restart nginx
echo "Cấu hình Nginx đã được cập nhật và áp dụng!"
