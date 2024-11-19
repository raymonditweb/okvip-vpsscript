#!/bin/bash

# Kiểm tra xem người dùng có quyền root không
if [[ $EUID -ne 0 ]]; then
  echo "Error: Vui lòng chạy script này với quyền root." 
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ "$#" -ne 9 ]; then
  echo "Error: Sử dụng: $0 [domain] [URL-301] [URL-301-target] [URL-302] [URL-302-target] [URL-307] [URL-307-target] [URL-308] [URL-308-target]"
  exit 1
fi

# 301 Moved Permanently: This redirect is permanent. It's used when a resource has been permanently moved to a new location. Search engines will update their indexes to the new URL.

# 302 Found (Previously "Moved Temporarily"): This redirect is temporary. It's used when a resource is temporarily located at a different URL. Search engines will continue to index the old URL.

# 307 Temporary Redirect: This is similar to a 302 redirect but enforces the HTTP method used (POST, GET, etc.), meaning that if a user sends a POST request to the original URL, they must use a POST request to the new URL.

# 308 Permanent Redirect: This is similar to a 301 redirect, but like the 307, it also preserves the HTTP method used.

DOMAIN="$1"
OLD_PAGE_301="$2"
NEW_PAGE_301="$3"
TEMPORARY_PAGE_302="$4"
ANOTHER_PAGE_302="$5"
TEMPORARY_PAGE_307="$6"
ANOTHER_PAGE_307="$7"
PERMANENT_PAGE_308="$8"
ANOTHER_PERMANENT_PAGE_308="$9"

# Đường dẫn đến tệp cấu hình Nginx
NGINX_CONF="/etc/nginx/nginx.conf"  # Địa chỉ cho các bản phân phối khác có thể khác nhau

# Thêm redirect vào tệp cấu hình Nginx
{
  echo "server {"
  echo "    listen 80;"
  echo "    server_name $DOMAIN;"  # Sử dụng tên miền từ tham số đầu vào
  echo "    # Redirect 301"
  echo "    location $OLD_PAGE_301 {"
  echo "        return 301 $NEW_PAGE_301;"
  echo "    }"
  echo "    # Redirect 302"
  echo "    location $TEMPORARY_PAGE_302 {"
  echo "        return 302 $ANOTHER_PAGE_302;"
  echo "    }"
  echo "    # Redirect 307"
  echo "    location $TEMPORARY_PAGE_307 {"
  echo "        return 307 $ANOTHER_PAGE_307;"
  echo "    }"
  echo "    # Redirect 308"
  echo "    location $PERMANENT_PAGE_308 {"
  echo "        return 308 $ANOTHER_PERMANENT_PAGE_308;"
  echo "    }"
  echo "}"
} >> "$NGINX_CONF"

# Khởi động lại dịch vụ Nginx để áp dụng thay đổi
systemctl restart nginx

echo "Redirects đã được cấu hình thành công cho Nginx."
