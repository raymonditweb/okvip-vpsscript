#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root."
  exit 1
fi

# Đọc trạng thái và danh sách domain
STATUS=$1
shift
DOMAINS=("$@")

# Kiểm tra tham số hợp lệ
if [[ -z "$STATUS" || ${#DOMAINS[@]} -eq 0 ]]; then
  echo "Cách dùng đúng: $0 <activate|deactivate> domain1.com domain2.com ..."
  exit 1
fi

# Kiểm tra WP-CLI
if ! command -v wp >/dev/null 2>&1; then
  echo "WP-CLI not found. Installing via apt..."
  apt update
  apt install -y wp-cli
  if ! command -v wp >/dev/null 2>&1; then
    echo "Error: WP-CLI installation failed."
    exit 1
  fi
  echo "WP-CLI installed successfully."
fi

# Lặp qua từng domain
for DOMAIN in "${DOMAINS[@]}"; do
  SITE_PATH="/var/www/$DOMAIN"

  echo "Đang xử lý: $DOMAIN ($STATUS mode)"

  if [ ! -d "$SITE_PATH" ]; then
    echo "Lỗi: Không tìm thấy đường dẫn $SITE_PATH"
    continue
  fi
    CURRENT_STATUS=$(wp maintenance-mode status --path="$SITE_PATH" --allow-root )

    if [[ "$CURRENT_STATUS" == *"is active"* && "$STATUS" == "active" ]]; then
     echo "Chế độ $STATUS maintenance mode cho $DOMAIN đã được bật trước đó"
     continue
    elif [[ "$CURRENT_STATUS" == *"is not active"* && "$STATUS" == "deactive" ]]; then
     echo "Chế độ $STATUS maintenance mode cho $DOMAIN đã được bật trước đó"
     continue
    fi

  # Thực thi lệnh maintenance
  if wp maintenance-mode "$STATUS" --path="$SITE_PATH" --allow-root >/dev/null 2>&1; then
    echo "Đã $STATUS chế độ bảo trì cho $DOMAIN"
  else
    echo "Lỗi khi $STATUS chế độ bảo trì cho $DOMAIN"
  fi
done
