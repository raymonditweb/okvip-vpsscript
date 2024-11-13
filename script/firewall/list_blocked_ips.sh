#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Xác định hệ điều hành và trình quản lý gói để cài đặt UFW
install_ufw() {
  if command -v apt-get &> /dev/null; then
    echo "Cài đặt UFW bằng apt-get trên hệ thống dựa trên Debian/Ubuntu..."
    apt-get update
    apt-get install -y ufw
  elif command -v yum &> /dev/null; then
    echo "Cài đặt UFW bằng yum trên hệ thống dựa trên CentOS/RHEL..."
    yum install -y epel-release
    yum install -y ufw
  else
    echo "Error: Không thể xác định trình quản lý gói. Vui lòng cài đặt UFW thủ công."
    exit 1
fi
}

# Kiểm tra xem UFW có được cài đặt không, nếu không thì cài đặt
if ! command -v ufw &> /dev/null; then
  echo "UFW không được cài đặt. Đang tiến hành cài đặt UFW..."
  install_ufw
fi

# Kiểm tra lại xem UFW đã cài đặt thành công chưa
if ! command -v ufw &> /dev/null; then
  echo "Error: Cài đặt UFW thất bại. Vui lòng kiểm tra lại."
  exit 1
fi

# Kích hoạt UFW với tùy chọn --force để tự động chọn [y/n] by y khi cài đặt
echo "Kích hoạt UFW..."
ufw --force enable

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
echo "Danh sách IP bị chặn (UFW và iptables):"
for ip in "${unique_blocked_ips[@]}"; do
  echo "$ip"
done

exit 0
