#!/bin/bash

# Nhận tham số từ dòng lệnh
BACKUP_FILE="$1"  # Đường dẫn file backup cần khôi phục
RESTORE_DIR="$2"  # Thư mục khôi phục source code (ví dụ: /var/www/domain.com)

# Kiểm tra tham số
if [ -z "$BACKUP_FILE" ] || [ -z "$RESTORE_DIR" ]; then
  echo "Error: Sử dụng: $0 <file_backup> <thư_mục_khôi_phục>"
  exit 1
fi

# Kiểm tra file backup có tồn tại hay không
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: File backup '$BACKUP_FILE' không tồn tại!"
  exit 1
fi

# Tạo thư mục khôi phục nếu chưa tồn tại
mkdir -p "$RESTORE_DIR"

# Thông báo bắt đầu khôi phục
echo "Bắt đầu khôi phục từ file backup: $BACKUP_FILE"

# Giải nén file backup
echo "Đang giải nén source code vào thư mục: $RESTORE_DIR"
unzip -o "$BACKUP_FILE" -d "$RESTORE_DIR" >/dev/null 2>&1

# Tìm file .sql trong file backup
SQL_FILE=$(unzip -l "$BACKUP_FILE" | grep '\.sql$' | awk '{print $4}')

if [ -z "$SQL_FILE" ]; then
  echo "Error: Không tìm thấy file database .sql trong backup!"
  exit 1
fi

# Giải nén file SQL ra thư mục tạm
TMP_SQL_FILE="/tmp/$(basename "$SQL_FILE")"
unzip -j "$BACKUP_FILE" "$SQL_FILE" -d /tmp >/dev/null 2>&1

# Yêu cầu thông tin database để khôi phục
read -p "Nhập tên database cần khôi phục: " DB_NAME
read -p "Nhập username database: " DB_USER
read -s -p "Nhập mật khẩu database: " DB_PASS
echo ""

# Khôi phục database
echo "Đang khôi phục database $DB_NAME..."
mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$TMP_SQL_FILE"

# Xóa file SQL tạm
rm -f "$TMP_SQL_FILE"

# Hoàn tất khôi phục
echo "Khôi phục hoàn tất! Source code đã giải nén vào: $RESTORE_DIR"
echo "Database '$DB_NAME' đã được khôi phục thành công."
