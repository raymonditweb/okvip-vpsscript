#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script này với quyền root."
  exit 1
fi

# Tạo một mảng để lưu trữ các IP bị chặn
blocked_ips=()

# Lấy danh sách UFW
echo "Lấy danh sách IP bị chặn bởi UFW..."
while read -r line; do
  blocked_ips+=("$line")
done < <(ufw status numbered | grep 'DENY' | awk '{print $6}')

# Lấy danh sách iptables
echo "Lấy danh sách IP bị chặn bởi iptables..."
while read -r line; do
    blocked_ips+=("$line")
done < <(iptables -L INPUT -v -n | grep 'DROP' | awk '{print $8}' | awk -F 'bytes)' '{print $1}')

# Sắp xếp và loại bỏ các giá trị trùng lặp
unique_blocked_ips=($(printf "%s\n" "${blocked_ips[@]}" | sort -u))

# Hiển thị danh sách IP bị chặn duy nhất
echo ""
echo "Danh sách IP bị chặn (UFW và iptables):"
for ip in "${unique_blocked_ips[@]}"; do
    echo "$ip"
done

exit 0
