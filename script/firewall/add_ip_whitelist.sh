#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra xem có đủ tham số được truyền vào không
if [ "$#" -lt 2 ]; then
  echo "Error: Vui lòng cung cấp tham số. Cú pháp: $0 [jail_name] [ip1] [ip2] ..."
  echo "Ví dụ: $0 [sshd] [192.168.1.10] [192.168.1.20"]
  exit 1
fi

# Lấy tên jail từ tham số đầu tiên
jail_name="$1"

# Vòng lặp qua các địa chỉ IP bắt đầu từ tham số thứ 2
shift # loại bỏ tham số đầu tiên
for ip in "$@"; do
  # Kiểm tra định dạng IP hợp lệ
  if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Địa chỉ IP không hợp lệ: $ip"
    continue
  fi
  
  # Thêm IP vào whitelist
  echo "Đang thêm IP $ip vào whitelist cho jail: $jail_name..."
  fail2ban-client set "$jail_name" addignoreip "$ip"
done

echo "Đã hoàn tất thêm các IP vào whitelist cho jail: $jail_name."
