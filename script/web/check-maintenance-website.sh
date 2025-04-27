#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [[ $# -eq 0 ]]; then
  echo "Cách dùng đúng: $0 domain1.com domain2.com ..."
  exit 1
fi

# Kiểm tra WP-CLI
if ! command -v wp >/dev/null 2>&1; then
  echo "Error: Chưa cài WP-CLI. Cài bằng apt..."
  apt update
  apt install -y wp-cli
  if ! command -v wp >/dev/null 2>&1; then
    echo "Error: WP-CLI cài đặt thất bại."
    exit 1
  fi
  echo "WP-CLI cài đặt thành công."
fi

# Lặp từng domain
for DOMAIN in "$@"; do
  SITE_PATH="/var/www/$DOMAIN"

  echo "Đang kiểm tra: $DOMAIN"

  if [ ! -d "$SITE_PATH" ]; then
    echo "Error: Không tìm thấy đường dẫn $SITE_PATH"
    continue
  fi

  STATUS_OUTPUT=$(wp maintenance-mode status --path="$SITE_PATH" --allow-root 2>&1)

  if echo "$STATUS_OUTPUT" | grep -q "is active"; then
    echo "🛠️  $DOMAIN đang ở chế độ bảo trì"
  elif echo "$STATUS_OUTPUT" | grep -q "is not active"; then
    echo "$DOMAIN đang hoạt động bình thường"
  else
    echo "$DOMAIN lỗi không xác định: $STATUS_OUTPUT"
  fi

done
