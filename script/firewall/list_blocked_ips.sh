#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script với quyền root."
  exit 1
fi

# Khởi tạo một mảng để lưu các IP bị chặn
blocked_ips=()

# Lấy danh sách IP bị chặn bởi UFW và thêm vào mảng
while IFS= read -r ip; do
  blocked_ips+=("$ip")
done < <(sudo ufw status verbose | grep -i "deny" | awk '{print $3}')

# Lấy danh sách IP bị chặn bởi iptables và thêm vào mảng
while IFS= read -r ip; do
  blocked_ips+=("$ip")
done < <(sudo iptables -L INPUT -v -n | grep "DROP\|REJECT" | awk '{print $8}')

# Loại bỏ các IP trùng lặp và hiển thị danh sách cuối cùng
echo "Danh sách IP bị chặn:"
printf "%s\n" "${blocked_ips[@]}" | sort -u
