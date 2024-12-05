#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Định nghĩa thư mục recycle bin và file log
RECYCLE_BIN_DIR="/var/www/recycle"
LOG_FILE="/var/www/recycle/log/move_activity.log"

# Kiểm tra nếu thư mục recycle bin tồn tại, nếu không thì tạo mới
if [ ! -d "$RECYCLE_BIN_DIR" ]; then
  mkdir -p "$RECYCLE_BIN_DIR"
  echo "Thư mục '$RECYCLE_BIN_DIR' đã được tạo."
fi

# Hàm ghi log
log_action() {
  local message=$1
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$timestamp - $message" >>"$LOG_FILE"
}

case $1 in
"delete")
  # Di chuyển file hoặc thư mục vào thư mục recycle bin
  SOURCE_PATH="$2"
  if [ -e "$SOURCE_PATH" ]; then
    mv "$SOURCE_PATH" "$RECYCLE_BIN_DIR/"
    log_action "Moved '$SOURCE_PATH' to recycle bin folder '$RECYCLE_BIN_DIR'."
    echo "'$SOURCE_PATH' đã được di chuyển vào thư mục recycle bin."
  else
    log_action "Attempted to move non-existing source '$SOURCE_PATH'."
    echo "Error: File hoặc thư mục '$SOURCE_PATH' không tồn tại."
  fi
  ;;
"delete-permanent")
  # Xóa file hoàn toàn khỏi thư mục recycle bin
  DELETE_ITEM="$2"
  if [ -e "$RECYCLE_BIN_DIR/$DELETE_ITEM" ]; then
    rm -rf "$RECYCLE_BIN_DIR/$DELETE_ITEM"
    log_action "Permanently deleted '$DELETE_ITEM' from recycle bin."
    echo "'$DELETE_ITEM' đã bị xóa hoàn toàn khỏi thư mục recycle bin."
  else
    log_action "Attempted to delete non-existing item '$DELETE_ITEM' from recycle bin."
    echo "Error: File hoặc thư mục '$DELETE_ITEM' không tồn tại trong thư mục recycle bin."
  fi
  ;;
"deleted-all")
  # Xóa tất cả file trong thư mục recycle bin
  if [ "$(ls -A $RECYCLE_BIN_DIR)" ]; then
    rm -rf "$RECYCLE_BIN_DIR/"*
    log_action "Deleted all items in recycle bin folder '$RECYCLE_BIN_DIR'."
    echo "Tất cả file trong thư mục recycle bin đã bị xóa hoàn toàn."
  else
    echo "Thư mục recycle bin trống, không có gì để xóa."
  fi
  ;;
"restore")
  # Khôi phục file hoặc thư mục từ thư mục recycle bin
  RESTORE_ITEM="$2"
  if [ -e "$RECYCLE_BIN_DIR/$RESTORE_ITEM" ]; then
    mv "$RECYCLE_BIN_DIR/$RESTORE_ITEM" "/var/www/$RESTORE_ITEM"
    log_action "Restored '$RESTORE_ITEM' from recycle bin folder '$RECYCLE_BIN_DIR'."
    echo "'$RESTORE_ITEM' đã được khôi phục từ thư mục recycle bin."
  else
    log_action "Attempted to restore non-existing item '$RESTORE_ITEM' from recycle bin."
    echo "Error: File hoặc thư mục '$RESTORE_ITEM' không tồn tại trong thư mục recycle bin."
  fi
  ;;
"restore-all")
  # Khôi phục tất cả file trong thư mục recycle bin
  if [ "$(ls -A $RECYCLE_BIN_DIR)" ]; then
    mv "$RECYCLE_BIN_DIR/"* "/var/www/"
    log_action "Restored all items from recycle bin folder '$RECYCLE_BIN_DIR'."
    echo "Tất cả file đã được khôi phục từ thư mục recycle bin."
  else
    echo "Thư mục recycle bin trống, không có gì để khôi phục."
  fi
  ;;
"list")
  # Hiển thị các file và thư mục đã di chuyển
  if [ -d "$RECYCLE_BIN_DIR" ]; then
    echo "Danh sách file trong thư mục recycle bin '$RECYCLE_BIN_DIR':"
    ls -l "$RECYCLE_BIN_DIR"
  else
    echo "Error: Thư mục recycle bin '$RECYCLE_BIN_DIR' không tồn tại."
  fi
  ;;
*)
  echo "Sử dụng: $0 {delete|delete-permanent|deleted-all|list|restore|restore-all} <file-hoặc-folder>"
  exit 1
  ;;
esac
