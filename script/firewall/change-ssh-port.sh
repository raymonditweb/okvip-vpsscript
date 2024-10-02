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

# Kiểm tra xem cổng có hợp lệ không (trong khoảng từ 1 đến 65535)
if ! [[ $NEW_SSH_PORT =~ ^[0-9]+$ ]] || [ "$NEW_SSH_PORT" -lt 1 ] || [ "$NEW_SSH_PORT" -gt 65535 ]; then
  echo "Error: Cổng không hợp lệ. Vui lòng chọn một giá trị từ 1 đến 65535."
  exit 1
fi

# Backup file cấu hình SSH trước khi thay đổi
SSH_CONFIG_FILE="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bak"
if [ ! -f "$BACKUP_FILE" ]; then
  cp $SSH_CONFIG_FILE $BACKUP_FILE
  echo "Đã tạo bản sao lưu của $SSH_CONFIG_FILE thành $BACKUP_FILE"
fi

# Thay đổi cổng SSH trong file cấu hình
if grep -q "^#Port" $SSH_CONFIG_FILE; then
  sed -i "s/^#Port.*/Port $NEW_SSH_PORT/" $SSH_CONFIG_FILE
elif grep -q "^Port" $SSH_CONFIG_FILE; then
  sed -i "s/^Port.*/Port $NEW_SSH_PORT/" $SSH_CONFIG_FILE
else
  echo "Port $NEW_SSH_PORT" >> $SSH_CONFIG_FILE
fi
echo "Cổng SSH đã được thay đổi thành $NEW_SSH_PORT trong $SSH_CONFIG_FILE"

# Cập nhật tường lửa để cho phép cổng SSH mới
echo "Cập nhật tường lửa để cho phép cổng SSH mới..."
ufw allow $NEW_SSH_PORT/tcp
echo "Cổng $NEW_SSH_PORT đã được mở trong tường lửa."

# Xóa quy tắc cũ (mặc định là cổng 22) khỏi tường lửa
echo "Xóa cổng SSH cũ khỏi tường lửa..."
ufw delete allow 22/tcp

# Khởi động lại dịch vụ SSH để áp dụng thay đổi
echo "Khởi động lại dịch vụ SSH..."
systemctl restart ssh

# Kiểm tra trạng thái dịch vụ SSH
systemctl status ssh

echo "Cổng SSH đã được thay đổi thành công. Vui lòng sử dụng cổng $NEW_SSH_PORT để kết nối SSH từ lần sau."
