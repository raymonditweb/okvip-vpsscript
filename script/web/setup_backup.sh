#!/bin/bash

# Kiểm tra xem script có chạy với quyền root hay không
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1 # Thoát nếu không chạy với quyền root
fi

# Gán tham số đầu vào vào các biến tương ứng
DOMAIN=$1
BACKUP_TIME=$2
BACKUP_FREQUENCY=$3 # Tần suất sao lưu

# Kiểm tra định dạng tên miền
if ! [[ $DOMAIN =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
  echo "Error: Domain không hợp lệ!"
  echo "Ví dụ đúng: example.com"
  exit 1 # Thoát nếu định dạng tên miền không hợp lệ
fi

# Kiểm tra định dạng thời gian
if ! [[ $BACKUP_TIME =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
  echo "Error: Thời gian không hợp lệ!"
  echo "Vui lòng sử dụng định dạng HH:MM (ví dụ: 23:30)"
  exit 1 # Thoát nếu thời gian không hợp lệ
fi

# Đọc thông tin đăng nhập từ wp-config.php
WP_CONFIG="/var/www/$DOMAIN/wp-config.php"
if [ ! -f "$WP_CONFIG" ]; then
  echo "Error: Không tìm thấy file wp-config.php tại $WP_CONFIG"
  exit 1
fi

DB_USER=$(grep "DB_USER" "$WP_CONFIG" | sed -E "s/define\('DB_USER',\s*'([^']+)'.*/\1/")
echo "$DB_USER"
DB_PASS=$(grep "DB_PASS" "$WP_CONFIG" | sed -E "s/define\('DB_PASS',\s*'([^']+)'.*/\1/")
echo "$DB_PASS"

# Kiểm tra thông tin đăng nhập MySQL
if ! mysql -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1" >/dev/null 2>&1; then
  echo "Error: Không thể kết nối đến MySQL với thông tin đăng nhập đã cung cấp!"
  exit 1 # Thoát nếu không thể kết nối đến MySQL
fi

# Các biến môi trường cần thiết cho backup
DATE=$(date +%Y-%m-%d_%H-%M-%S) # Ngày giờ hiện tại
BACKUP_DIR="/backup/$DOMAIN"    # Thư mục lưu trữ backup
WWW_DIR="/var/www/$DOMAIN"      # Thư mục chứa mã nguồn web
RETENTION_DAYS=7                # Số ngày lưu giữ backup
SCRIPT_PATH=$(readlink -f "$0") # Đường dẫn tuyệt đối của script
DB_NAME="${DOMAIN//./_}"        # Tên cơ sở dữ liệu, thay thế dấu chấm bằng dấu gạch dưới

# Tạo các thư mục con 'database' và 'source' bên trong thư mục backup
# Bằng cách sử dụng 'mkdir' để tạo thư mục
# -p: Tùy chọn này cho phép tạo thư mục cha nếu chưa tồn tại
# "$BACKUP_DIR": Biến chứa đường dẫn đến thư mục backup
# /{database,source}: Sử dụng brace expansion để mở rộng thành hai thư mục:
# - $BACKUP_DIR/database
# - $BACKUP_DIR/source
mkdir -p "$BACKUP_DIR"/{database,source}
chmod 700 "$BACKUP_DIR" # Thiết lập quyền truy cập cho thư mục backup

# Tạo file cấu hình bảo mật
CONFIG_FILE="$BACKUP_DIR/.backup.conf" # Đường dẫn của file cấu hình

# Ghi thông tin vào file cấu hình
# Sử dụng 'cat' kết hợp với here document để ghi nội dung vào file cấu hình
# Lưu tên người dùng cơ sở dữ liệu vào file cấu hình
# Lưu mật khẩu cơ sở dữ liệu vào file cấu hình
# Lưu tên miền vào file cấu hình
# Lưu thời gian backup vào file cấu hình
cat >"$CONFIG_FILE" <<EOF
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DOMAIN="$DOMAIN"
BACKUP_TIME="$BACKUP_TIME"
EOF
chmod 600 "$CONFIG_FILE" # Chỉ cho phép người sở hữu có quyền đọc và ghi

# Hàm ghi log với timestamp
log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$BACKUP_DIR/backup.log" # Ghi log vào file và hiển thị lên màn hình
}

# Hàm thiết lập cronjob cho backup tự động
setup_cron() {
  local hour="${BACKUP_TIME%%:*}"  # Tách giờ từ thời gian backup
  local minute="${BACKUP_TIME#*:}" # Tách phút từ thời gian backup

  # Xóa số 0 đứng đầu
  hour=$(echo "$hour" | sed 's/^0//')
  minute=$(echo "$minute" | sed 's/^0//')

  # Xác định tần suất cho cron
  local cron_schedule=""
  case "$BACKUP_FREQUENCY" in
  daily)
    cron_schedule="$minute $hour * * *" # Hàng ngày
    ;;
  weekly)
    cron_schedule="$minute $hour * * 0" # Hàng tuần (Chủ Nhật)
    ;;
  monthly)
    cron_schedule="$minute $hour 1 * *" # Hàng tháng (Ngày 1)
    ;;
  *)
    echo "Error: Tần suất không hợp lệ! (daily|weekly|monthly)"
    exit 1
    ;;
  esac

  # Tạo mục cron với đường dẫn đến file cấu hình
  local cron_file="/etc/cron.d/backup-$DOMAIN"
  echo "# Backup tự động cho $DOMAIN" >"$cron_file"
  echo "$cron_schedule * * * root $SCRIPT_PATH $DOMAIN \"$CONFIG_FILE\" >> $BACKUP_DIR/backup.log 2>&1" >>"$cron_file"

  chmod 644 "$cron_file"                                                                                # Thiết lập quyền truy cập cho file cron
  log_message "Đã thiết lập cronjob backup cho $DOMAIN với tần suất $BACKUP_FREQUENCY lúc $BACKUP_TIME" # Ghi log thông báo thiết lập cronjob thành công
}

# Hàm backup mã nguồn
backup_source() {
  log_message "Bắt đầu backup source code..."

  if [ ! -d "$WWW_DIR" ]; then
    log_message "Error: Thư mục source $WWW_DIR không tồn tại!" # Kiểm tra xem thư mục có tồn tại không
    return 1                                                    # Trả về Error nếu không tồn tại
  fi

  local source_file="$BACKUP_DIR/source/$DOMAIN-source-$DATE.tar.gz" # Đường dẫn file backup mã nguồn

  # Backup
  tar czf "$source_file" -C "$WWW_DIR" . --warning=no-file-changed 2>/dev/null || {
    log_message "Error: Không thể backup source code!" # Ghi log nếu không thể backup
    return 1                                           # Trả về Error
  }

  # Kiểm tra tính hợp lệ của file backup
  if tar tzf "$source_file" >/dev/null 2>&1; then
    log_message "Backup source code thành công: $(du -h "$source_file" | cut -f1)" # Ghi log nếu backup thành công
    ln -sf "$source_file" "$BACKUP_DIR/source/latest-backup.tar.gz"                # Tạo liên kết đến backup mới nhất
    return 0                                                                       # Trả về thành công
  else
    log_message "Error: File backup source code bị hỏng!" # Ghi log nếu file backup bị hỏng
    rm -f "$source_file"                                  # Xóa file backup bị hỏng
    return 1                                              # Trả về Error
  fi
}

# Hàm backup cơ sở dữ liệu
backup_database() {
  log_message "Bắt đầu backup database..."

  local db_file="$BACKUP_DIR/database/$DOMAIN-db-$DATE.sql.gz" # Đường dẫn file backup cơ sở dữ liệu

  # Kiểm tra xem cơ sở dữ liệu có tồn tại không
  if ! mysql -u"$DB_USER" -p"$DB_PASS" -e "use $DB_NAME" 2>/dev/null; then
    log_message "Error: Database $DB_NAME không tồn tại!" # Ghi log nếu cơ sở dữ liệu không tồn tại
    return 1                                              # Trả về Error
  fi

  # Backup với tiến trình và nén
  mysqldump -u"$DB_USER" -p"$DB_PASS" --single-transaction --quick "$DB_NAME" 2>/dev/null | pv -q -L 10M | gzip >"$db_file" || {
    log_message "Error: Không thể backup database!" # Ghi log nếu không thể backup cơ sở dữ liệu
    return 1                                        # Trả về Error
  }

  # Kiểm tra tính hợp lệ của file backup
  if gzip -t "$db_file" 2>/dev/null; then
    log_message "Backup database thành công: $(du -h "$db_file" | cut -f1)" # Ghi log nếu backup thành công
    ln -sf "$db_file" "$BACKUP_DIR/database/latest-backup.sql.gz"           # Tạo liên kết đến backup mới nhất
    return 0                                                                # Trả về thành công
  else
    log_message "Error: File backup database bị hỏng!" # Ghi log nếu file backup bị hỏng
    rm -f "$db_file"                                   # Xóa file backup bị hỏng
    return 1                                           # Trả về Error
  fi
}

# Hàm xóa các backup cũ
cleanup_old_backups() {
  log_message "Dọn dẹp backup cũ (> $RETENTION_DAYS ngày)..."

  find "$BACKUP_DIR/source" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete   # Xóa các file backup mã nguồn cũ
  find "$BACKUP_DIR/database" -type f -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete # Xóa các file backup cơ sở dữ liệu cũ

  # Tính toán dung lượng còn lại
  local current_size=$(du -sh "$BACKUP_DIR" | cut -f1)
  log_message "Dung lượng hiện tại của thư mục backup: $current_size" # Ghi log dung lượng hiện tại
}

# Hàm kiểm tra dung lượng ổ đĩa
check_disk_space() {
  local disk_space=$(df -h "$BACKUP_DIR" | awk 'NR==2 {print $5}' | sed 's/%//') # Lấy thông tin dung lượng ổ đĩa
  local available_space=$(df -h "$BACKUP_DIR" | awk 'NR==2 {print $4}')          # Lấy dung lượng trống

  log_message "Dung lượng trống: $available_space" # Ghi log dung lượng trống

  if [ "$disk_space" -gt 90 ]; then # Cảnh báo nếu dung lượng ổ đĩa còn lại dưới 10%
    log_message "Warning: Dung lượng ổ đĩa còn lại thấp ($disk_space%)"
    return 1 # Trả về Error
  fi
  return 0 # Trả về thành công
}

# Hàm hiển thị thông tin backup
show_backup_info() {
  echo ">>><<< Thông tin Backup >>><<<"
  echo "Domain: $DOMAIN"
  echo "Database: $DB_NAME"
  echo "Thời gian backup: $BACKUP_TIME"
  echo "Thư mục backup: $BACKUP_DIR"
  echo "Dung lượng backup source: $(du -sh "$BACKUP_DIR/source/latest-backup.tar.gz" 2>/dev/null | cut -f1)"
  echo "Dung lượng backup database: $(du -sh "$BACKUP_DIR/database/latest-backup.sql.gz" 2>/dev/null | cut -f1)"
  echo "Log file: $BACKUP_DIR/backup.log"
}

# Hàm thực hiện quy trình backup chính
do_backup() {
  log_message ">>><<< Bắt đầu quy trình backup cho $DOMAIN >>><<<"

  # Kiểm tra dung lượng ổ đĩa
  check_disk_space

  # Backup mã nguồn và cơ sở dữ liệu
  backup_source
  local source_status=$? # Lưu trạng thái của backup source

  backup_database
  local db_status=$? # Lưu trạng thái của backup database

  # Dọn dẹp backup cũ
  cleanup_old_backups

  # Hiển thị kết quả backup
  if [ $source_status -eq 0 ] && [ $db_status -eq 0 ]; then
    log_message ">>><<< Backup hoàn tất thành công >>><<<"
    show_backup_info # Hiển thị thông tin backup
    return 0         # Trả về thành công
  else
    log_message "Error: Backup thất bại! Vui lòng kiểm tra log >>><<<" # Ghi log Error
    if [ $source_status -ne 0 ]; then
      log_message "Error: Backup source code bị hỏng với mã lỗi: $source_status" # Ghi log nếu backup source bị hỏng
    fi
    if [ $db_status -ne 0 ]; then
      log_message "Error: Backup cơ sở dữ liệu bị hỏng với mã lỗi: $db_status" # Ghi log nếu backup cơ sở dữ liệu bị hỏng
    fi
    return 1 # Trả về Error
  fi
}

# Phần thực thi chính
log_message "Thiết lập backup tự động cho $DOMAIN" # Ghi log thông báo thiết lập cronjob
setup_cron                                         # Gọi hàm thiết lập cronjob
show_backup_info                                   # Hiển thị thông tin backup
do_backup                                          # Gọi hàm backup chính
