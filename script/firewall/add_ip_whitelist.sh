#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra xem có đủ tham số được truyền vào không
if [ "$#" -lt 2 ]; then
  echo "Error: Sử dụng Cú pháp: $0 [jail_name] [ip1] [ip2] ..."
  echo "Ví dụ: $0 sshd 192.168.1.10 192.168.1.20"
  exit 1
fi

# Lấy tên jail từ tham số đầu tiên
jail_name="$1"

# Kiểm tra xem jail có tồn tại không
if ! fail2ban-client status "$jail_name" &>/dev/null; then
  echo "Jail không tồn tại: $jail_name"
  exit 1
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

echo "Đã hoàn tất thêm các IP vào whitelist cho jail: $jail_name."
