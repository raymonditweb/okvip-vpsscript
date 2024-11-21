#!/bin/bash

# Kiểm tra xem script có chạy với quyền root hay không
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1  # Thoát nếu không chạy với quyền root
fi

# Gán tham số đầu vào vào các biến tương ứng
DOMAIN=$1
BACKUP_DIR="/backup/$DOMAIN"  # Thư mục lưu trữ backup
GDRIVE_PATH=$2  # Đường dẫn đến thư mục trên Google Drive

# Hàm ghi log với timestamp
log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$BACKUP_DIR/backup.log"  # Ghi log vào file và hiển thị lên màn hình
}

# Kiểm tra và cài đặt rclone nếu chưa được cài đặt
if ! command -v rclone &> /dev/null; then
  echo "rclone chưa được cài đặt. Đang cài đặt..."
  if [[ "$(uname)" == "Linux" ]]; then
    # Cài đặt rclone cho Linux
    curl https://rclone.org/install.sh | sudo bash
  else
    echo "Hệ điều hành không được hỗ trợ!"
    exit 1
  fi
fi

# Hàm sao lưu lên Google Drive
backup_to_gdrive() {
  log_message "Bắt đầu sao lưu lên Google Drive..."

  # Sao lưu mã nguồn
  local source_file="$BACKUP_DIR/source/latest-backup.tar.gz"
  if [ -f "$source_file" ]; then
    rclone copy "$source_file" "$GDRIVE_PATH/source/" --progress
    log_message "Sao lưu thành công mã nguồn lên Google Drive."
  else
    log_message "Error: File backup mã nguồn không tồn tại!"
  fi

  # Sao lưu cơ sở dữ liệu
  local db_file="$BACKUP_DIR/database/latest-backup.sql.gz"
  if [ -f "$db_file" ]; then
    rclone copy "$db_file" "$GDRIVE_PATH/database/" --progress
    log_message "Sao lưu thành công cơ sở dữ liệu lên Google Drive."
  else
    log_message "Error: File backup cơ sở dữ liệu không tồn tại!"
  fi
}

# Gọi hàm sao lưu lên Google Drive
backup_to_gdrive
