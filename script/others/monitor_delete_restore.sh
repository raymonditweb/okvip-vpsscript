#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Định nghĩa thư mục recycle bin và file log
RECYCLE_BIN_DIR="/var/www/recycle"
LOG_FILE="/var/www/log/move_activity.log"

# Kiểm tra và tạo thư mục chứa file log nếu chưa tồn tại
if [ ! -d "$(dirname "$LOG_FILE")" ]; then
  mkdir -p "$(dirname "$LOG_FILE")"
fi

# Tạo file log nếu chưa tồn tại
if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
fi

# Kiểm tra nếu thư mục recycle bin tồn tại, nếu không thì tạo mới
if [ ! -d "$RECYCLE_BIN_DIR" ]; then
  mkdir -p "$RECYCLE_BIN_DIR"
  echo "Thư mục '$RECYCLE_BIN_DIR' đã được tạo."
fi

# Hàm ghi log
log_action() {
  local action=$1
  local source=$2
  local target=$3
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$timestamp|$action|$source|$target" >>"$LOG_FILE"
}

# Hàm khôi phục vị trí cũ từ file log
restore_original_path() {
  local item=$1
  grep "|delete|.*/$item|" "$LOG_FILE" | tail -n 1 | awk -F'|' '{print $3}'
}

case $1 in
"delete")
  # Di chuyển file hoặc thư mục vào thư mục recycle bin
  SOURCE_PATH="$2"
  if [ -e "$SOURCE_PATH" ]; then
    ITEM_NAME=$(basename "$SOURCE_PATH")
    mv "$SOURCE_PATH" "$RECYCLE_BIN_DIR/$ITEM_NAME"
    log_action "delete" "$SOURCE_PATH" "$RECYCLE_BIN_DIR/$ITEM_NAME"
    echo "'$SOURCE_PATH' đã được di chuyển vào thư mục recycle bin."
  else
    echo "Error: File hoặc thư mục '$SOURCE_PATH' không tồn tại."
  fi
  ;;
"delete-permanent")
  # Xóa file hoàn toàn khỏi thư mục recycle bin
  DELETE_ITEM="$2"
  if [ -e "$RECYCLE_BIN_DIR/$DELETE_ITEM" ]; then
    rm -rf "$RECYCLE_BIN_DIR/$DELETE_ITEM"
    log_action "delete-permanent" "$RECYCLE_BIN_DIR/$DELETE_ITEM" ""
    echo "'$DELETE_ITEM' đã bị xóa hoàn toàn khỏi thư mục recycle bin."
  else
    echo "Error: File hoặc thư mục '$DELETE_ITEM' không tồn tại trong thư mục recycle bin."
  fi
  ;;
"deleted-all")
  # Xóa tất cả file trong thư mục recycle bin
  if [ "$(ls -A $RECYCLE_BIN_DIR)" ]; then
    rm -rf "$RECYCLE_BIN_DIR/"*
    log_action "deleted-all" "$RECYCLE_BIN_DIR" ""
    echo "Tất cả file trong thư mục recycle bin đã bị xóa hoàn toàn."
  else
    echo "Error: Thư mục recycle bin trống, không có gì để xóa."
  fi
  ;;
"restore")
  # Khôi phục file hoặc thư mục từ thư mục recycle bin
  RESTORE_ITEM="$2"
  if [ -e "$RECYCLE_BIN_DIR/$RESTORE_ITEM" ]; then
    ORIGINAL_PATH=$(restore_original_path "$RESTORE_ITEM")
    if [ -n "$ORIGINAL_PATH" ]; then
      mkdir -p "$(dirname "$ORIGINAL_PATH")"
      mv "$RECYCLE_BIN_DIR/$RESTORE_ITEM" "$ORIGINAL_PATH"
      log_action "restore" "$RECYCLE_BIN_DIR/$RESTORE_ITEM" "$ORIGINAL_PATH"
      echo "'$RESTORE_ITEM' đã được khôi phục về '$ORIGINAL_PATH'."
    else
      echo "Error: Không thể tìm thấy vị trí gốc của '$RESTORE_ITEM'."
    fi
  else
    echo "Error: File hoặc thư mục '$RESTORE_ITEM' không tồn tại trong thư mục recycle bin."
  fi
  ;;
"restore-all")
  # Khôi phục tất cả file trong thư mục recycle bin
  if [ "$(ls -A $RECYCLE_BIN_DIR)" ]; then
    for ITEM in "$RECYCLE_BIN_DIR"/*; do
      ITEM_NAME=$(basename "$ITEM")
      ORIGINAL_PATH=$(restore_original_path "$ITEM_NAME")
      if [ -n "$ORIGINAL_PATH" ]; then
        mkdir -p "$(dirname "$ORIGINAL_PATH")"
        mv "$ITEM" "$ORIGINAL_PATH"
        log_action "restore" "$ITEM" "$ORIGINAL_PATH"
        echo "'$ITEM_NAME' đã được khôi phục về '$ORIGINAL_PATH'."
      else
        echo "Error: Không thể tìm thấy vị trí gốc của '$ITEM_NAME'."
      fi
    done
  else
    echo "Error: Thư mục recycle bin trống, không có gì để khôi phục."
  fi
  ;;
"list")
  # Hiển thị các file và thư mục đã di chuyển (chỉ tên)
  if [ -d "$RECYCLE_BIN_DIR" ] && [ "$(ls -A $RECYCLE_BIN_DIR)" ]; then
    echo "Danh sách file trong thư mục recycle bin:"
    ls "$RECYCLE_BIN_DIR"
  else
    echo "Error: Thư mục recycle bin trống hoặc không tồn tại."
  fi
  ;;
*)
  echo "Sử dụng: $0 {delete|delete-permanent|deleted-all|list|restore|restore-all} <file-hoặc-folder>"
  exit 1
  ;;
esac
