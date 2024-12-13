#!/bin/bash

# Kiểm tra xem người dùng có quyền root không
if [[ $EUID -ne 0 ]]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra tên miền hợp lệ
DOMAIN="$1"
if [[ ! "$DOMAIN" =~ ^[a-zA-Z0-9.-]+$ ]]; then
  echo "Error: DOMAIN không hợp lệ. Tên miền chỉ có thể chứa chữ, số, dấu gạch ngang và dấu chấm."
  exit 1
fi

OLD_PAGE_301="$2"
NEW_PAGE_301="$3"
TEMPORARY_PAGE_302="$4"
ANOTHER_PAGE_302="$5"
TEMPORARY_PAGE_307="$6"
ANOTHER_PAGE_307="$7"
PERMANENT_PAGE_308="$8"
ANOTHER_PERMANENT_PAGE_308="$9"

# Đường dẫn tệp cấu hình riêng (thay vì ghi vào /etc/nginx/nginx.conf)
NGINX_CONF="/etc/nginx/conf.d/${DOMAIN}.conf"

# Sao lưu tệp cũ (nếu có) và lưu tên tệp sao lưu
if [ -f "$NGINX_CONF" ]; then
  BACKUP_FILE="${NGINX_CONF}.bak_$(date +%F_%T)"
  cp "$NGINX_CONF" "$BACKUP_FILE"
  echo "Đã tạo bản sao lưu của tệp cấu hình Nginx: $BACKUP_FILE"
fi

# Thêm cấu hình vào tệp cấu hình Nginx
{
  echo "server {"
  echo "    listen 80;"
  echo "    server_name $DOMAIN;"
  
  # Redirect 301
  if [ -n "$OLD_PAGE_301" ] && [ -n "$NEW_PAGE_301" ]; then
    echo "    # Redirect 301"
    echo "    location $OLD_PAGE_301 {"
    echo "        return 301 $NEW_PAGE_301;"
    echo "    }"
  fi
  
  # Redirect 302
  if [ -n "$TEMPORARY_PAGE_302" ] && [ -n "$ANOTHER_PAGE_302" ]; then
    echo "    # Redirect 302"
    echo "    location $TEMPORARY_PAGE_302 {"
    echo "        return 302 $ANOTHER_PAGE_302;"
    echo "    }"
  fi
  
  # Redirect 307
  if [ -n "$TEMPORARY_PAGE_307" ] && [ -n "$ANOTHER_PAGE_307" ]; then
    echo "    # Redirect 307"
    echo "    location $TEMPORARY_PAGE_307 {"
    echo "        return 307 $ANOTHER_PAGE_307;"
    echo "    }"
  fi
  
  # Redirect 308
  if [ -n "$PERMANENT_PAGE_308" ] && [ -n "$ANOTHER_PERMANENT_PAGE_308" ]; then
    echo "    # Redirect 308"
    echo "    location $PERMANENT_PAGE_308 {"
    echo "        return 308 $ANOTHER_PERMANENT_PAGE_308;"
    echo "    }"
  fi
  
  echo "}"
} > "$NGINX_CONF"

# Kiểm tra cấu hình Nginx
if nginx -t; then
  systemctl restart nginx
  echo "Redirects đã được cấu hình thành công cho Nginx và Nginx đã khởi động lại thành công."
else
  echo "Error: Cấu hình Nginx không hợp lệ. Khôi phục bản sao lưu."
  cp "$BACKUP_FILE" "$NGINX_CONF" && echo "Khôi phục thành công cấu hình Nginx từ bản sao lưu."
fi
