#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra xem fail2ban đã được cài đặt hay chưa
if ! command -v fail2ban-client &> /dev/null; then
  echo "Error: fail2ban chưa được cài đặt."
  exit 1
fi

# Kiểm tra xem dịch vụ fail2ban có đang chạy hay không
if ! systemctl is-active --quiet fail2ban; then
    echo "Error: Dịch vụ fail2ban không đang chạy."
    exit 1
fi

# Lấy tên dịch vụ và cổng từ tham số dòng lệnh
service_name="$1"
port="$2"

# Kiểm tra xem tên dịch vụ và cổng có được cung cấp hay không
if [ -z "$service_name" ]; then
  echo "Error: Tên dịch vụ không được cung cấp."
  exit 1
fi

if [ -z "$port" ]; then
  echo "Error: Cổng không được cung cấp."
  exit 1
fi

# Tạo cấu hình jail mới
jail_config="/etc/fail2ban/jail.d/${service_name}.conf"

# Kiểm tra xem tệp cấu hình đã tồn tại để tránh ghi đè
if [ -f "$jail_config" ]; then
  echo "Error: Cấu hình jail cho '$service_name' đã tồn tại."
  exit 1
fi

# Tạo cấu hình jail
cat << EOF | tee "$jail_config" > /dev/null
[${service_name}]
enabled = true
port = $port
filter = ${service_name}
logpath = /var/log/${service_name}/${service_name}.log
maxretry = 5
bantime = 600
EOF

# Tạo cấu hình filter
filter_config="/etc/fail2ban/filter.d/${service_name}.conf"

# Kiểm tra xem filter đã tồn tại để tránh ghi đè
if [ -f "$filter_config" ]; then
  echo "Error: Cấu hình filter cho '$service_name' đã tồn tại."
  exit 1
fi

# Tạo cấu hình filter
cat << EOF | tee "$filter_config" > /dev/null
[INCLUDES]
before = common.conf

[Definition]
failregex = ^%(__prefix_line)s<HOST> - (.*)
ignoreregex =
EOF

# Khởi động lại fail2ban để áp dụng các thay đổi
if systemctl restart fail2ban; then
  echo "Dịch vụ mới '$service_name' đã được thêm vào fail2ban thành công!"
else
  echo "Error: Khởi động lại fail2ban không thành công."
fi
