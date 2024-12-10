#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root"
  exit 1
fi

# Kiểm tra iptables có cài đặt không
if ! command -v iptables &>/dev/null; then
  echo "Iptables chưa được cài đặt, vui lòng cài đặt iptables trước."
  exit 1
fi

# Kiểm tra xem có đủ tham số không
if [ "$#" -lt 2 ]; then
  echo "Error: Sử dụng: $0 <MAX_FAILED_ATTEMPTS> <BLOCK_TIME>. Ví dụ: $0 3 300 (giới hạn 3 lần đăng nhập sai, khóa trong 300 giây)"
  exit 1
fi

# Nhận tham số từ dòng lệnh
MAX_FAILED_ATTEMPTS=$1
BLOCK_TIME=$2

# Tên của chain trong iptables
CHAIN_NAME="SSH_LIMIT"

# Xóa chain cũ (nếu tồn tại) và tạo chain mới trong iptables để giới hạn SSH login
iptables -D INPUT -p tcp --dport 22 -j $CHAIN_NAME 2>/dev/null
iptables -F $CHAIN_NAME 2>/dev/null
iptables -X $CHAIN_NAME 2>/dev/null

# Tạo chain mới và thêm quy tắc
iptables -N $CHAIN_NAME
iptables -A INPUT -p tcp --dport 22 -j $CHAIN_NAME

# Thêm quy tắc để giới hạn số lần đăng nhập thất bại
iptables -A $CHAIN_NAME -m recent --set --name SSH --rsource
iptables -A $CHAIN_NAME -m recent --update --seconds $BLOCK_TIME --hitcount $MAX_FAILED_ATTEMPTS -j REJECT --reject-with tcp-reset

echo "Đã thiết lập giới hạn đăng nhập SSH thất bại: $MAX_FAILED_ATTEMPTS lần trong $BLOCK_TIME giây."

# Lưu cấu hình iptables
if command -v iptables-save &>/dev/null; then
  iptables-save >/etc/iptables/rules.v4
  echo "Cấu hình iptables đã được lưu."
else
  echo "Không thể lưu cấu hình iptables. Vui lòng cấu hình lưu iptables thủ công."
fi

# Khởi động lại SSH để áp dụng thay đổi
systemctl restart sshd

echo "Cấu hình SSH đã được cập nhật và SSH đã được khởi động lại."
