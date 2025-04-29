#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số
if [ "$#" -lt 1 ]; then
  echo "Cách dùng: $0 domain1.com domain2.com domain3.com ..."
  exit 1
fi

# Kiểm tra wp-cli
if ! command -v wp &>/dev/null; then
  echo "Error: wp-cli chưa cài, hãy cài trước!"
  exit 1
fi

# Lặp qua từng domain
for DOMAIN in "$@"; do
  WEB_ROOT="/var/www/$DOMAIN"

  echo "==============================="
  echo "🔍 Xử lý domain: $DOMAIN"

  # Kiểm tra thư mục web
  if [ ! -d "$WEB_ROOT" ]; then
    echo "Error: Không tìm thấy web root: $WEB_ROOT, bỏ qua."
    continue
  fi

  # Cài plugin WPS Hide Login
  if wp --path="$WEB_ROOT" plugin is-installed wps-hide-login --allow-root; then
    echo "Plugin WPS Hide Login đã cài."
    wp --path="$WEB_ROOT" plugin activate wps-hide-login --allow-root
  else
    echo "🛠 Cài mới plugin WPS Hide Login..."
    wp --path="$WEB_ROOT" plugin install wps-hide-login --activate --allow-root
  fi

  # Tạo slug login dựa theo domain
  SLUG=$(echo "$DOMAIN" | awk -F. '{print $1}') # ví dụ abc.com -> abc

  # Cập nhật URL login
  echo "Đặt đường login mới thành: /$SLUG"
  wp --path="$WEB_ROOT" option update whl_page "$SLUG" --allow-root


  echo "Domain $DOMAIN đã set login URL: https://$DOMAIN/$SLUG"
done