#!/bin/bash

# Đường dẫn file cấu hình jail.local
JAIL_LOCAL_FILE="/etc/fail2ban/jail.local"
# Tham số đầu vào
SERVICE_NAME="$1"

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ -z "$SERVICE_NAME" ]; then
  echo "Sử dụng: $0 [tên_dịch_vụ]"
  exit 1
fi

# Thêm cấu hình dịch vụ vào jail.local
echo "Đang thêm dịch vụ '$SERVICE_NAME' vào Fail2Ban..."

# Kiểm tra xem tên dịch vụ có sẵn trong tệp cấu hình jail.local không
if grep -q "^\[$SERVICE_NAME\]" "$JAIL_LOCAL_FILE"; then
  echo "Dịch vụ $SERVICE_NAME đã tồn tại trong $JAIL_LOCAL_FILE"
else
  # Nếu dịch vụ chưa tồn tại, thêm cấu hình mới cho dịch vụ vào jail.local
  # Thêm dòng mới bắt đầu với tên dịch vụ trong dấu ngoặc vuông (e.g., [service_name])
  echo -e "\n[$SERVICE_NAME]" >> "$JAIL_LOCAL_FILE"

  # Bật giám sát dịch vụ trong Fail2Ban
  echo "enabled = true" >> "$JAIL_LOCAL_FILE"

  # Đặt bộ lọc (filter) có tên theo biến $SERVICE_NAME
  # Bộ lọc này cần có trong /etc/fail2ban/filter.d/$SERVICE_NAME.conf
  echo "filter = $SERVICE_NAME" >> "$JAIL_LOCAL_FILE"

  # Đường dẫn đến tệp log của dịch vụ, nơi Fail2Ban sẽ kiểm tra các lần truy cập đáng ngờ
  echo "logpath = /var/log/$SERVICE_NAME.log" >> "$JAIL_LOCAL_FILE"

  # Thiết lập số lần đăng nhập thất bại tối đa trước khi chặn IP (ở đây là 5 lần)
  echo "maxretry = 5" >> "$JAIL_LOCAL_FILE"

  # Thời gian chặn IP tính bằng giây, ở đây là 600 giây (10 phút)
  echo "bantime = 600" >> "$JAIL_LOCAL_FILE"

  # Thông báo rằng cấu hình cho dịch vụ đã được thêm vào jail.local thành công
  echo "Dịch vụ $SERVICE_NAME đã được thêm vào Fail2Ban."
fi

# Khởi động lại Fail2Ban để áp dụng thay đổi
echo "Đang khởi động lại Fail2Ban..."
systemctl restart fail2ban
echo "Fail2Ban đã được khởi động lại."

# Xác nhận kết quả
echo "Dịch vụ $SERVICE_NAME đã được thêm vào danh sách giám sát của Fail2Ban."
