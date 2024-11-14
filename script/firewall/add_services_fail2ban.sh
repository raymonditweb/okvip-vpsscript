#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
SERVICE_NAME="$1"

if [ -z "$SERVICE_NAME" ]; then
  echo "Error: Sử dụng: $0 [tên_dịch_vụ]"
  exit 1
fi

# Loại bỏ dấu ngoặc vuông nếu có trong tên dịch vụ
SERVICE_NAME=$(echo "$SERVICE_NAME" | tr -d '[]')

# Đường dẫn file cấu hình jail.local
JAIL_LOCAL_FILE="/etc/fail2ban/jail.local"
FILTER_CONFIG_FILE="/etc/fail2ban/filter.d/${SERVICE_NAME}.conf"

# Thêm cấu hình dịch vụ vào jail.local
echo "Đang thêm dịch vụ '$SERVICE_NAME' vào Fail2Ban..."

# Kiểm tra nếu dịch vụ đã tồn tại trong jail.local
if grep -q "^\[$SERVICE_NAME\]" "$JAIL_LOCAL_FILE"; then
  echo "Error: Dịch vụ $SERVICE_NAME đã tồn tại trong $JAIL_LOCAL_FILE"
else
  # Thêm cấu hình mới cho dịch vụ vào jail.local
  echo -e "\n[$SERVICE_NAME]" >> "$JAIL_LOCAL_FILE"
  echo "enabled = true" >> "$JAIL_LOCAL_FILE"
  echo "filter = $SERVICE_NAME" >> "$JAIL_LOCAL_FILE"
  echo "logpath = /var/log/$SERVICE_NAME.log" >> "$JAIL_LOCAL_FILE"
  echo "maxretry = 5" >> "$JAIL_LOCAL_FILE"
  echo "bantime = 600" >> "$JAIL_LOCAL_FILE"
  echo "Dịch vụ $SERVICE_NAME đã được thêm vào Fail2Ban."

  # Tạo cấu hình filter cho dịch vụ
  echo "Đang tạo filter cho dịch vụ '$SERVICE_NAME'..."
  echo "[INCLUDES]" > "$FILTER_CONFIG_FILE"
  echo "before = common.conf" >> "$FILTER_CONFIG_FILE"
  echo -e "\n[Definition]" >> "$FILTER_CONFIG_FILE"
  echo "failregex = Failed login attempt for user: .* from IP: <HOST>" >> "$FILTER_CONFIG_FILE"
  echo "ignoreregex =" >> "$FILTER_CONFIG_FILE"
  echo "Filter cho dịch vụ $SERVICE_NAME đã được tạo."

  # Khởi động lại Fail2Ban để áp dụng thay đổi
  echo "Đang khởi động lại Fail2Ban..."
  sudo systemctl restart fail2ban
  echo "Fail2Ban đã được khởi động lại."
fi

# Xác nhận kết quả
echo "Dịch vụ $SERVICE_NAME đã được thêm vào danh sách giám sát của Fail2Ban."
