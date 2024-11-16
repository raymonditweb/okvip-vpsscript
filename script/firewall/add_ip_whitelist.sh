#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra xem có tham số truyền vào hay không
if [ "$#" -lt 1 ]; then
  echo "Error: Không có IP được cung cấp. Vui lòng cung cấp ít nhất một địa chỉ IP để thêm vào whitelist."
  exit 1
fi

# File cấu hình của Fail2ban (thường là fail2ban.local hoặc jail.local)
CONFIG_FILE="/etc/fail2ban/jail.local"

# Duyệt qua tất cả các tham số (các địa chỉ IP)
for ip in "$@"; do
  # Kiểm tra xem IP đã có trong ignoreip hay chưa
  if grep -q "ignoreip" "$CONFIG_FILE"; then
    # Nếu ignoreip đã có, kiểm tra xem IP đã có trong danh sách chưa
    if ! grep -q "$ip" "$CONFIG_FILE"; then
      # Thêm IP vào danh sách ignoreip trong file cấu hình
      sudo sed -i "/ignoreip/s/$/ $ip/" "$CONFIG_FILE"
      echo "Địa chỉ IP $ip đã được thêm vào whitelist."
    else
      echo "Error: Địa chỉ IP $ip đã có trong whitelist."
    fi
  else
    # Nếu ignoreip chưa có trong file, thêm mới và rồi thêm IP
    echo "ignoreip = $ip" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo "Địa chỉ IP $ip đã được thêm vào whitelist."
  fi
done

# Khởi động lại Fail2ban để áp dụng thay đổi
sudo systemctl restart fail2ban

echo "Các thay đổi đã được áp dụng thành công!"
