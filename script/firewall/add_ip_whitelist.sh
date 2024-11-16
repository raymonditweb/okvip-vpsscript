#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra xem có ít nhất một địa chỉ IP được truyền vào hay không
if [ "$#" -lt 2 ]; then
  echo "Error: Sử dụng Cú pháp: $0 [ip1] [ip2] ..."
  echo "Ví dụ: $0 [192.168.1.10] [192.168.1.20]"
  exit 1
  exit 1
fi

# File cấu hình của Fail2ban (thường là fail2ban.local hoặc jail.local)
CONFIG_FILE="/etc/fail2ban/jail.local"

# Duyệt qua tất cả các tham số (các địa chỉ IP)
for ip in "$@"; do
  # Loại bỏ dấu ngoặc vuông []
  ip=$(echo "$ip" | tr -d '[]')

  # Kiểm tra xem phần [DEFAULT] đã có trong file hay chưa
  if ! grep -q "\[DEFAULT\]" "$CONFIG_FILE"; then
    # Nếu chưa có [DEFAULT], thêm nó vào file
    echo -e "\n[DEFAULT]\n" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo "Phần [DEFAULT] đã được thêm vào $CONFIG_FILE."
  fi

  # Kiểm tra xem ignoreip đã có trong file hay chưa
  if grep -q "ignoreip" "$CONFIG_FILE"; then
    # Nếu ignoreip đã có, kiểm tra xem IP đã có trong danh sách chưa
    if ! grep -q "$ip" "$CONFIG_FILE"; then
        # Thêm IP vào danh sách ignoreip trong file cấu hình mà không tạo thêm dòng mới
        sudo sed -i "/ignoreip/s/\$/ $ip/" "$CONFIG_FILE"
        echo "Địa chỉ IP $ip đã được thêm vào whitelist."
    else
        echo "Error: Địa chỉ IP $ip đã có trong whitelist."
    fi
  else
    # Nếu ignoreip chưa có trong file, thêm mới
    echo -n "ignoreip = $ip" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo "Địa chỉ IP $ip đã được thêm vào whitelist."
  fi
done

# Khởi động lại Fail2ban để áp dụng thay đổi
sudo systemctl restart fail2ban

echo "Các thay đổi đã được áp dụng thành công!"
