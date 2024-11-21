#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ $# -lt 2 ]; then
  echo "Error: Sử dụng: $0 <enable|disable> '<cron_job>'"
  echo "Ví dụ: $0 enable '0 2 * * * /path/to/script.sh'"
  exit 1
fi

ACTION="$1"   # enable hoặc disable
CRON_JOB="$2" # Nội dung Cron job cần thêm hoặc chỉnh sửa

# Tệp cron tạm thời
TEMP_CRON=$(mktemp)

# Lấy danh sách cron hiện tại
crontab -l >"$TEMP_CRON" 2>/dev/null

case "$ACTION" in
enable)
  # Kiểm tra nếu Cron job đã được bật
  if grep -Fxq "$CRON_JOB" "$TEMP_CRON"; then
    echo "Error: Cron job đã được bật trước đó."
  else
    # Xóa nếu có dòng #<cron_job>
    sed -i "\|^#.*$CRON_JOB|d" "$TEMP_CRON"
    # Thêm Cron job vào cuối tệp
    echo "$CRON_JOB" >>"$TEMP_CRON"
    echo "Cron job đã được bật."
  fi
  ;;
disable)
  # Kiểm tra nếu Cron job đã tồn tại và chưa bị tắt
  if grep -Fxq "$CRON_JOB" "$TEMP_CRON"; then
    # Tắt Cron job bằng cách thêm ký tự '#' vào đầu dòng
    sed -i "s|^$CRON_JOB|# $CRON_JOB|" "$TEMP_CRON"
    echo "Cron job đã được tắt."
  else
    echo "Error: Cron job không tồn tại hoặc đã bị tắt trước đó."
  fi
  ;;
*)
  echo "Error: Hành động không hợp lệ. Sử dụng 'enable' hoặc 'disable'."
  exit 1
  ;;
esac

# Cập nhật cron
crontab "$TEMP_CRON"
rm -f "$TEMP_CRON"

echo "Cập nhật cron hoàn tất!" 
