#!/bin/bash

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
  echo "Error: Vui liệu chạy script với quyền root."
  exit 1
fi

# Đường dẫn file log
LOG_FILE="/var/log/rclone_setup.log"

# Hàm ghi log
log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >>$LOG_FILE
}

# Kiểm tra xem rclone đã được cài chưa
if ! command -v rclone &>/dev/null; then
  log_message "Rclone chưa được cài, bắt đầu cài đặt."
  echo "Rclone chưa được cài, đang cài đặt..."
  
  # Cài đặt rclone
  curl https://rclone.org/install.sh | sudo bash

  if [[ $? -eq 0 ]]; then
    log_message "Rclone cài đặt thành công."
    echo "Rclone cài đặt thành công!"
  else
    log_message "Lỗi khi cài đặt rclone."
    echo "Error: Có lỗi trong quá trình cài đặt rclone. Vui lòng kiểm tra lại."
    exit 1
  fi
else
  log_message "Rclone đã được cài đặt."
  echo "Rclone đã được cài đặt."
fi

# Tên remote cho Google Drive
REMOTE_NAME="gdrive"

# Tạo cấu hình cho rclone với Google Drive (không cần client_id, client_secret)
log_message "Bắt đầu tạo cấu hình rclone cho Google Drive."
rclone config create $REMOTE_NAME drive \
  scope drive \
  root_folder_id root \
  --auto-confirm

if [[ $? -eq 0 ]]; then
  log_message "Cấu hình rclone cho Google Drive đã hoàn tất!"
  echo "Cấu hình rclone cho Google Drive đã hoàn tất!"
else
  log_message "Lỗi khi tạo cấu hình rclone cho Google Drive."
  echo "Error: Có lỗi trong quá trình tạo cấu hình rclone cho Google Drive."
  exit 1
fi
