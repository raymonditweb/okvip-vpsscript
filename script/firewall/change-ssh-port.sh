#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra xem có tham số nào được truyền vào không
if [ -z "$1" ]; then
  echo "Error: Vui lòng cung cấp cổng SSH mới."
  echo "Usage: $0 <new_ssh_port>"
  exit 1
fi

NEW_SSH_PORT=$1
SAFE_PORT_RANGE=(1024 49151)
SSH_CONFIG_FILE="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bak"

# Kiểm tra tệp cấu hình SSH
if [ ! -f "$SSH_CONFIG_FILE" ]; then
  echo "Error: Không tìm thấy tệp cấu hình SSH tại $SSH_CONFIG_FILE."
  exit 1
fi

# Kiểm tra xem cổng có hợp lệ không
if ! [[ $NEW_SSH_PORT =~ ^[0-9]+$ ]] || [ "$NEW_SSH_PORT" -lt 1 ] || [ "$NEW_SSH_PORT" -gt 65535 ]; then
  echo "Error: Cổng không hợp lệ. Vui lòng chọn một giá trị từ 1 đến 65535."
  exit 1
elif ([ "$NEW_SSH_PORT" -lt ${SAFE_PORT_RANGE[0]} ] || [ "$NEW_SSH_PORT" -gt ${SAFE_PORT_RANGE[1]} ]) && [ "$NEW_SSH_PORT" -ne 22 ]; then
  echo "Error: Cổng nằm ngoài dải an toàn (${SAFE_PORT_RANGE[0]}-${SAFE_PORT_RANGE[1]}), trừ cổng 22."
  exit 1
fi

# Sao lưu tệp cấu hình SSH
if [ ! -f "$BACKUP_FILE" ]; then
  cp "$SSH_CONFIG_FILE" "$BACKUP_FILE" || {
    echo "Error: Không thể sao lưu tệp cấu hình SSH."
    exit 1
  }
  echo "Đã tạo bản sao lưu của $SSH_CONFIG_FILE thành $BACKUP_FILE."
fi

# Lấy cổng SSH hiện tại
CURRENT_SSH_PORT=$(grep "^Port" "$SSH_CONFIG_FILE" | awk '{print $2}')
CURRENT_SSH_PORT=${CURRENT_SSH_PORT:-22}

# Mở cổng mới trong tường lửa
if ufw status | grep -q "Status: active"; then
  if ! ufw allow "$NEW_SSH_PORT/tcp"; then
    echo "Error: Không thể mở cổng $NEW_SSH_PORT trong tường lửa."
    exit 1
  fi
  echo "Cổng $NEW_SSH_PORT đã được mở trong tường lửa."
fi

# Thay đổi cổng SSH
if grep -q "^#Port" "$SSH_CONFIG_FILE"; then
  sed -i "s/^#Port.*/Port $NEW_SSH_PORT/" "$SSH_CONFIG_FILE"
elif grep -q "^Port" "$SSH_CONFIG_FILE"; then
  sed -i "s/^Port.*/Port $NEW_SSH_PORT/" "$SSH_CONFIG_FILE"
else
  echo "Port $NEW_SSH_PORT" >>"$SSH_CONFIG_FILE"
fi

# Xóa cổng cũ khỏi tường lửa
if [ "$CURRENT_SSH_PORT" -ne "$NEW_SSH_PORT" ] && ufw status | grep -q "Status: active"; then
  ufw delete allow "$CURRENT_SSH_PORT/tcp" || echo "Warning: Không thể xóa cổng $CURRENT_SSH_PORT khỏi tường lửa."
fi

# Khởi động lại SSH
if systemctl restart ssh; then
  echo "Cổng SSH đã được thay đổi thành $NEW_SSH_PORT. Vui lòng kiểm tra kết nối."
else
  echo "Error: Không thể khởi động lại dịch vụ SSH. Khôi phục cấu hình ban đầu..."
  cp "$BACKUP_FILE" "$SSH_CONFIG_FILE"
  ufw delete allow "$NEW_SSH_PORT/tcp"
  ufw allow "$CURRENT_SSH_PORT/tcp"
  systemctl restart ssh
  echo "Đã khôi phục cấu hình ban đầu. Sử dụng cổng $CURRENT_SSH_PORT."
fi
