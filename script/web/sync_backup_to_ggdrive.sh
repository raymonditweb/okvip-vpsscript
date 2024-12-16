#!/bin/bash

# Kiểm tra xem script có chạy với quyền root hay không
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1 # Thoát nếu không chạy với quyền root
fi

# Nhận tham số từ dòng lệnh
BACKUP_DIR="$1"            # Đường dẫn thư mục backup
REMOTE_NAME="${2:-gdrive}" # Tên remote của Google Drive (mặc định: gdrive)
REMOTE_DIR="$3"            # Thư mục trên Google Drive để lưu backup
START_TIME="$4"            # Thời gian bắt đầu đồng bộ (HH:MM)
BACKUP_INTERVAL_DAYS="$5"  # Tần suất đồng bộ (số ngày)

if [ -z "$BACKUP_DIR" ] || [ -z "$REMOTE_DIR" ] || [ -z "$START_TIME" ] || [ -z "$BACKUP_INTERVAL_DAYS" ]; then
  echo "Error: Vui lòng cung cấp đủ tham số: thư mục backup, thư mục đích trên Google Drive, thời gian bắt đầu và tần suất đồng bộ (ngày)."
  echo "Tên remote sẽ sử dụng mặc định là: gdrive nếu không được cung cấp."
  exit 1
fi

# Kiểm tra rclone đã được cài đặt chưa
if ! command -v rclone &>/dev/null; then
  echo "Error: Rclone chưa được cài đặt. Vui lòng cài đặt rclone trước khi sử dụng script này."
  exit 1
fi

# Đồng bộ thư mục backup lên Google Drive
echo "Đồng bộ thư mục $BACKUP_DIR lên Google Drive (remote: $REMOTE_NAME)..."
rclone copy "$BACKUP_DIR" "$REMOTE_NAME:$REMOTE_DIR" --progress

if [ $? -eq 0 ]; then
  echo "Đồng bộ thành công!"
else
  echo "Error: Đồng bộ thất bại. Kiểm tra lại cấu hình và thử lại."
  exit 1
fi

# Giữ lại tối đa 7 bản sao lưu mới nhất
echo "Kiểm tra và xóa các bản backup cũ trên Google Drive..."
FILE_LIST=$(rclone lsf "$REMOTE_NAME:$REMOTE_DIR" --format "tp" | sort)
FILE_COUNT=$(echo "$FILE_LIST" | wc -l)

if [ "$FILE_COUNT" -gt 7 ]; then
  FILES_TO_DELETE=$(echo "$FILE_LIST" | head -n $(($FILE_COUNT - 7)))
  while read -r FILE; do
    echo "Đang xóa: $FILE"
    rclone delete "$REMOTE_NAME:$REMOTE_DIR/$FILE"
  done <<<"$FILES_TO_DELETE"
fi

# Thiết lập lịch tự động đồng bộ bằng cron
echo "Cài đặt lịch tự động đồng bộ..."
CRON_COMMAND="/bin/bash $(realpath $0) $BACKUP_DIR $REMOTE_NAME $REMOTE_DIR $START_TIME $BACKUP_INTERVAL_DAYS"

# Tính toán lịch cron từ số ngày và thời gian bắt đầu
MINUTE=$(echo "$START_TIME" | cut -d':' -f2)
HOUR=$(echo "$START_TIME" | cut -d':' -f1)

# Tần suất đồng bộ (dựa trên ngày)
CRON_SCHEDULE="$MINUTE $HOUR */$BACKUP_INTERVAL_DAYS * *"

(
  crontab -l 2>/dev/null | grep -v "$CRON_COMMAND"
  echo "$CRON_SCHEDULE $CRON_COMMAND"
) | crontab -

echo "Hoàn tất cài đặt lịch đồng bộ tự động!"
