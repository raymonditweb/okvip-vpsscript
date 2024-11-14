#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
SERVICE_NAME="$1"
PORT="$2"

if [ -z "$SERVICE_NAME" ] || [ -z "$PORT" ]; then
  echo "Error: Vui lòng cung cấp tên dịch vụ va port: $0 [tên_dịch_vụ] [port]"
  exit 1
fi

# Đường dẫn file cấu hình jail.local
JAIL_LOCAL_FILE="/etc/fail2ban/jail.local"
# Đường dẫn file filter
FILTER_FILE="/etc/fail2ban/filter.d/$SERVICE_NAME.conf"

# Thêm cấu hình dịch vụ vào jail.local
echo "Đang thêm dịch vụ '$SERVICE_NAME' vào Fail2Ban..."

# Kiểm tra nếu dịch vụ đã tồn tại trong jail.local
if grep -q "^\[$SERVICE_NAME\]" "$JAIL_LOCAL_FILE"; then
    echo "Dịch vụ $SERVICE_NAME đã tồn tại trong $JAIL_LOCAL_FILE"
else
    # Thêm cấu hình mới cho dịch vụ vào jail.local
    echo -e "\n$SERVICE_NAME" >> "$JAIL_LOCAL_FILE"
    echo "enabled = true" >> "$JAIL_LOCAL_FILE"
    echo "filter = $SERVICE_NAME" >> "$JAIL_LOCAL_FILE"
    echo "logpath = /var/log/$SERVICE_NAME.log" >> "$JAIL_LOCAL_FILE"
    echo "maxretry = 5" >> "$JAIL_LOCAL_FILE"
    echo "bantime = 600" >> "$JAIL_LOCAL_FILE"
    echo "Dịch vụ $SERVICE_NAME đã được thêm vào Fail2Ban."
fi

# Tạo file filter nếu chưa tồn tại
if [ ! -f "$FILTER_FILE" ]; then
    echo "Tạo file filter cho dịch vụ '$SERVICE_NAME'..."

    # Thêm cấu hình mẫu cho filter
    cat <<EOL > "$FILTER_FILE"
[Definition]

# Mô tả mẫu log để phát hiện hành vi đáng ngờ cho $SERVICE_NAME
failregex = ^.*Failed login attempt for .* from <HOST>.*$
  ^.*Unusual access from <HOST>.*$
  ^.*Invalid access from <HOST>.*$

ignoreregex =
EOL

  echo "File filter $FILTER_FILE đã được tạo."
else
  echo "Error: File filter $FILTER_FILE đã tồn tại."
fi

# Khởi động lại Fail2Ban để áp dụng thay đổi
echo "Đang khởi động lại Fail2Ban..."
sudo systemctl restart fail2ban
echo "Fail2Ban đã được khởi động lại."

# Xác nhận kết quả
echo "Dịch vụ $SERVICE_NAME đã được thêm vào danh sách giám sát của Fail2Ban với port $PORT."
