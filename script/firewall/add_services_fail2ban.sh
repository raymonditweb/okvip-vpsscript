#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra xem tham số có được truyền vào hay không
if [ "$#" -ne 1 ]; then
  echo "Error: Sử dụng: $0 [SERVICE_NAME]"
  exit 1
fi

SERVICE_NAME=$1

# Loại bỏ dấu ngoặc vuông nếu có trong tên Service
SERVICE_NAME=$(echo "$SERVICE_NAME" | tr -d '[]')

# Kiểm tra xem Service có đang chạy hay không
if ! systemctl is-active $SERVICE_NAME; then
  echo "Error: Service '$SERVICE_NAME' không chạy. Không thể thêm vào Fail2Ban."
  exit 1
fi

# Tạo file cấu hình cho Service Fail2Ban
JAIL_LOCAL_FILE="/etc/fail2ban/jail.d/$SERVICE_NAME.local"

if [ -f "$JAIL_LOCAL_FILE" ]; then
  echo "Cấu hình cho Service '$SERVICE_NAME' đã tồn tại. Thoát."
  exit 1
fi

cat <<EOL | tee "$JAIL_LOCAL_FILE" > /dev/null
[$SERVICE_NAME]
enabled = true
filter = ${SERVICE_NAME}-auth
logpath = /var/log/$SERVICE_NAME/access.log
maxretry = 5
bantime = 3600
EOL

# Tạo file filter nếu chưa tồn tại
FILTER_CONFIG_FILE="/etc/fail2ban/filter.d/${SERVICE_NAME}-auth.conf"

if [ ! -f "$FILTER_CONFIG_FILE" ]; then
  cat <<EOL | tee "$FILTER_CONFIG_FILE" > /dev/null
[INCLUDES]
[Definition]
failregex = Failed attempt for user: .* from IP: <HOST>
ignoreregex =
EOL
fi

# Khởi động lại Service Fail2Ban
systemctl restart fail2ban

# Kiểm tra trạng thái Fail2Ban
fail2ban-client status

echo "Service '$SERVICE_NAME' đã được thêm vào Fail2Ban."
