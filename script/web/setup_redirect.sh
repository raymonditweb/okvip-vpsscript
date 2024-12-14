#!/bin/bash

# Kiểm tra xem người dùng có quyền root không
if [[ $EUID -ne 0 ]]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  echo "Error: Sử dụng: $0 [domain] [path] [redirect-type] [target]"
  echo "  - domain: Tên miền (vd: domain.com) (có thể bỏ trống)"
  echo "  - path: Đường dẫn path (định dạng /path/*) (có thể bỏ trống)"
  echo "  - redirect-type: Loại redirect (301, 302, 307, 308)"
  echo "  - target: URL đích tới (vd: https://domain-dich.com/$1)"
  exit 1
fi

DOMAIN="$1"
PATH="$2"
REDIRECT_TYPE="$3"
TARGET="$4"

# Kiểm tra redirect type hợp lệ
if ! [[ "$REDIRECT_TYPE" =~ ^(301|302|307|308)$ ]]; then
  echo "Error: Loại redirect không hợp lệ. Vui lòng chọn một trong: 301, 302, 307, 308."
  exit 1
fi

# Đểm bảo rằng tên miền hoặc đường dẫn phải được cung cấp
if [ -z "$DOMAIN" ] && [ -z "$PATH" ]; then
  echo "Error: Phải có tối thiểu tên miền hoặc đường dẫn."
  exit 1
fi

# Đường dẫn tệp cấu hình Nginx (tạo cấu hình riêng cho từng domain)
NGINX_CONF="/etc/nginx/conf.d/${DOMAIN:-default}.conf"

# Sao lưu tệp củ (nếu có)
if [ -f "$NGINX_CONF" ]; then
  cp "$NGINX_CONF" "${NGINX_CONF}.bak_$(date +%F_%T)"
fi

# Thêm cấu hình vào tệp cấu hình Nginx
{
  echo "server {"
  echo "    listen 80;"
  if [ -n "$DOMAIN" ]; then
    echo "    server_name $DOMAIN;"
  fi
  if [ -n "$PATH" ]; then
    echo "    location $PATH {"
    echo "        return $REDIRECT_TYPE $TARGET;"
    echo "    }"
  fi
  echo "}"
} >"$NGINX_CONF"

# Kiểm tra cấu hình Nginx
if nginx -t; then
  systemctl restart nginx
  echo "Redirect đã được cấu hình thành công cho Nginx và Nginx đã khởi động lại thành công."
else
  echo "Error: Cấu hình Nginx không hợp lệ. Khôi phục bản sao lưu."
  cp "${NGINX_CONF}.bak_$(date +%F_%T)" "$NGINX_CONF"
fi
