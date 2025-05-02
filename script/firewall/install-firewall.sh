#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra WP-CLI
if ! command -v wp &> /dev/null; then
  echo "Error: WP-CLI chưa được cài. Vui lòng cài trước."
  exit 1
fi

# Kiểm tra đầu vào
if [[ $# -lt 1 ]]; then
  echo "Cách dùng: $0 domain1 [domain2 ...]"
  echo "Ví dụ: $0 abc.com demo.org"
  exit 1
fi

BASE_PATH="/var/www"

# Lặp qua từng domain
for DOMAIN in "$@"; do
  SITE="$BASE_PATH/$DOMAIN"
  CONFIG="$SITE/wp-config.php"

  if [[ ! -f "$CONFIG" ]]; then
    echo "Không tìm thấy wp-config.php tại $SITE — bỏ qua $DOMAIN"
    continue
  fi

  echo "Đang cài đặt Wordfence cho $DOMAIN"

  if wp --path="$SITE" plugin is-installed wordfence --allow-root; then
    echo "Wordfence đã được cài trước đó"
    wp --path="$SITE" plugin activate wordfence --allow-root
  else
    wp --path="$SITE" plugin install wordfence --activate --allow-root
    echo "Cài đặt Wordfence thành công cho $DOMAIN"
  fi
done
