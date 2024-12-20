#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root."
  exit 1
fi

# Nhận tham số từ dòng lệnh
BACKUP_FILE="$1"                       # Đường dẫn file backup cần khôi phục
RESTORE_DIR="$2"                       # Thư mục khôi phục source code (ví dụ: /var/www/domain.com)
LOG_FILE="/var/log/restore_script.log" # File log

# Hàm ghi log
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Kiểm tra tham số
if [ -z "$BACKUP_FILE" ] || [ -z "$RESTORE_DIR" ]; then
  log "Error: Sử dụng: $0 <file_backup> <thư_mục_khôi_phục>"
  exit 1
fi

# Kiểm tra file backup có tồn tại hay không
if [ ! -f "$BACKUP_FILE" ]; then
  log "Error: File backup '$BACKUP_FILE' không tồn tại!"
  exit 1
fi

# Tạo thư mục khôi phục nếu chưa tồn tại
mkdir -p "$RESTORE_DIR"

# Thông báo bắt đầu khôi phục
log "Bắt đầu khôi phục từ file backup: $BACKUP_FILE"

# Giải nén file backup
log "Đang giải nén source code vào thư mục: $RESTORE_DIR"
unzip -o "$BACKUP_FILE" -d "$RESTORE_DIR" >/dev/null 2>&1

# Lấy tên domain từ RESTORE_DIR
DOMAIN=$(basename "$RESTORE_DIR")
log "Tên domain được xác định: $DOMAIN"
WWW_DIR="var/www/$DOMAIN" # Thư mục chứa mã nguồn web

# Lấy tên database từ tên domain
DB_NAME=$(echo "$DOMAIN" | sed -E 's/\./_/g')
log "Tên database được xác định: $DB_NAME"

# Đọc thông tin đăng nhập từ wp-config.php
WP_CONFIG="$RESTORE_DIR/$WWW_DIR/wp-config.php"
log "Tên tệp wp-config.php được xác định: $WP_CONFIG"
if [ ! -f "$WP_CONFIG" ]; then
  log "Error: Không tìm thấy tệp wp-config.php trong $RESTORE_DIR!"
  exit 1
fi

DB_USER=$(grep "define(\"DB_USER" $WP_CONFIG | awk -F"'" '{print $2}')
DB_PASS=$(grep "define(\"DB_PASSWORD" $WP_CONFIG | awk -F"'" '{print $2}')

if [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
  log "Error: Không thể đọc thông tin đăng nhập từ wp-config.php!"
  exit 1
fi

log "Thông tin đăng nhập được lấy từ wp-config.php:"
log "  DB_USER: $DB_USER"
log "  DB_PASS: $DB_PASS"

# Tìm file .sql trong file backup
SQL_FILE=$(find "$RESTORE_DIR" -maxdepth 1 -type f -name '*.sql' | head -n 1)

if [ -z "$SQL_FILE" ]; then
  log "Error: Không tìm thấy file database .sql trong backup!"
  exit 1
fi

log "Tên file SQL được tìm thấy: $SQL_FILE"

# Giải nén file SQL ra thư mục tạm
TMP_SQL_FILE="/tmp/$(basename "$SQL_FILE")"
cp "$SQL_FILE" "$TMP_SQL_FILE"

# Khôi phục database
log "Đang khôi phục database $DB_NAME..."
if mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <"$TMP_SQL_FILE"; then
  log "Khôi phục database $DB_NAME thành công."
else
  log "Error: Khôi phục database $DB_NAME thất bại!"
  exit 1
fi

# Xóa file SQL tạm
rm -f "$TMP_SQL_FILE"

# Hoàn tất khôi phục
log "Khôi phục hoàn tất! Source code đã giải nén vào: $RESTORE_DIR"
log "Database '$DB_NAME' đã được khôi phục thành công."
