#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra cú pháp
if [[ $# -lt 2 ]]; then
  echo "Cách dùng: $0 [active|inactive] domain1 [domain2 ...]"
  echo "Ví dụ: $0 active abc.com demo.org"
  exit 1
fi

# Hành động: active (chặn chỉnh sửa) hoặc inactive (cho phép chỉnh sửa)
ACTION=$1
shift

# Gốc thư mục
BASE_PATH="/var/www"

# Lặp qua từng domain
for DOMAIN in "$@"; do
  SITE="$BASE_PATH/$DOMAIN"
  CONFIG="$SITE/wp-config.php"

  if [[ ! -f "$CONFIG" ]]; then
    echo "Không tìm thấy wp-config.php tại $SITE — bỏ qua $DOMAIN"
    continue
  fi

  case "$ACTION" in
    active)
      if grep -q "DISALLOW_FILE_EDIT" "$CONFIG"; then
        echo "Đã tồn tại DISALLOW_FILE_EDIT tại $DOMAIN"
      else
        echo "Bật chặn chỉnh sửa file cho $DOMAIN thành công"
        echo "define('DISALLOW_FILE_EDIT', true);" >> "$CONFIG"
      fi
      ;;
    inactive)
      if grep -q "DISALLOW_FILE_EDIT" "$CONFIG"; then
        echo "Tắt chặn chỉnh sửa file cho $DOMAIN thành công"
        sed -i "/DISALLOW_FILE_EDIT/d" "$CONFIG"
      else
        echo "Không có dòng DISALLOW_FILE_EDIT tại $DOMAIN"
      fi
      ;;
    *)
      echo "Error: Hành động không hợp lệ: $ACTION (chỉ dùng active|inactive)"
      exit 1
      ;;
  esac
done
