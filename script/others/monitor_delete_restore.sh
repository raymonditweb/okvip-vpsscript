#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Định nghĩa thư mục backup và file log
BACKUP_DIR="/var/www/recycle"
LOG_FILE="/var/www/recycle/log/move_activity.log"

# Kiểm tra nếu thư mục backup tồn tại, nếu không thì tạo mới
if [ ! -d "$BACKUP_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
  echo "Thư mục '$BACKUP_DIR' đã được tạo."
fi

# Hàm ghi log
log_action() {
  local message=$1
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$timestamp - $message" >>"$LOG_FILE"
}

case $1 in
"delete")
  # Di chuyển thư mục hoặc file vào thư mục backup
  SOURCE_PATH="$2"
  if [ -e "$SOURCE_PATH" ]; then
    mv "$SOURCE_PATH" "$BACKUP_DIR/"
    log_action "Moved '$SOURCE_PATH' to backup folder '$BACKUP_DIR'."
    echo "'$SOURCE_PATH' đã được xóa."
  else
    log_action "Attempted to move non-existing source '$SOURCE_PATH'."
    echo "Error: Source '$SOURCE_PATH' không tốn tại."
  fi
  ;;
"list")
  # Hiển thị các file và thư mục đã di chuyển
  if [ -d "$BACKUP_DIR" ]; then
    echo "Listing files in backup directory '$BACKUP_DIR':"
    ls -l "$BACKUP_DIR"
  else
    echo "Error: Backup directory '$BACKUP_DIR' does not exist."
  fi
  ;;
"restore")
  # Phục hồi thư mục hoặc file từ thư mục backup
  RESTORE_ITEM="$2"
  if [ -e "$BACKUP_DIR/$RESTORE_ITEM" ]; then
    mv "$BACKUP_DIR/$RESTORE_ITEM" "/var/www/$RESTORE_ITEM"
    log_action "Restored '$RESTORE_ITEM' from backup folder '$BACKUP_DIR'."
    echo "'$RESTORE_ITEM' has been restored from '$BACKUP_DIR'."
  else
    log_action "Attempted to restore non-existing item '$RESTORE_ITEM' from backup."
    echo "Error: Item '$RESTORE_ITEM' does not exist in backup."
  fi
  ;;
*)
  echo "Error: Sử dụng: $0 {delete|list|restore} <folder-or-file-path>"
  exit 1
  ;;
esac
