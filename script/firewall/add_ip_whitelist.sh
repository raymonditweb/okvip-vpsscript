#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra xem có đủ tham số được truyền vào không
if [ "$#" -lt 2 ]; then
  echo "Cú pháp: $0 [jail_name] [ip1] [ip2] ..."
  echo "Ví dụ: $0 sshd 192.168.1.10 192.168.1.20"
  exit 1
fi

# Lấy tên jail từ tham số đầu tiên
jail_name="$1"

# File cấu hình jail.local
jail_local="/etc/fail2ban/jail.local"

# Kiểm tra nếu jail.local không tồn tại
if [ ! -f "$jail_local" ]; then
  echo "Tệp cấu hình $jail_local không tồn tại. Đang tạo mới..."
  sudo touch "$jail_local"
fi

# Kiểm tra xem jail đã tồn tại trong cấu hình chưa
if ! grep -q "^\[$jail_name\]" "$jail_local"; then
  echo "Jail $jail_name chưa tồn tại. Đang tạo mới..."
  # Thêm cấu hình cơ bản cho jail
  sudo bash -c "cat >> $jail_local" <<EOL

[$jail_name]
enabled = true
filter = $jail_name
logpath = /var/log/auth.log
bantime = 3600
findtime = 600
maxretry = 3
EOL
  echo "Đã tạo jail $jail_name với cấu hình mặc định trong $jail_local."
else
  echo "Jail $jail_name đã tồn tại."
fi

# Loại bỏ tham số đầu tiên (jail_name)
shift

# Vòng lặp qua các địa chỉ IP bắt đầu từ tham số thứ 2
for ip in "$@"; do
  # Kiểm tra định dạng IP hợp lệ (IPv4 và IPv6)
  if [[ ! $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ && ! $ip =~ ^([a-fA-F0-9:]+:+)+[a-fA-F0-9]+$ ]]; then
    echo "Địa chỉ IP không hợp lệ: $ip"
    continue
  fi

  # Thêm IP vào whitelist cho jail
  echo "Đang thêm IP $ip vào whitelist cho jail: $jail_name..."
  if fail2ban-client set "$jail_name" addignoreip "$ip"; then
    echo "Thêm IP $ip thành công."
  else
    echo "Error: Thêm IP $ip thất bại. Kiểm tra cấu hình và thử lại."
  fi
done

# Khởi động lại dịch vụ Fail2ban để áp dụng thay đổi
echo "Khởi động lại Fail2ban để áp dụng cấu hình..."
sudo systemctl restart fail2ban

echo "Đã hoàn tất thêm các IP vào whitelist cho jail: $jail_name."
