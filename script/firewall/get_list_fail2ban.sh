#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra xem Fail2Ban đã được cài đặt chưa
if ! command -v fail2ban-client &> /dev/null; then
  echo "Fail2Ban chưa được cài đặt. Đang cài đặt Fail2Ban..."

  # Cài đặt Fail2Ban trên hệ điều hành Ubuntu/Debian
  if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y fail2ban
  # Cài đặt Fail2Ban trên hệ điều hành CentOS/RHEL
  elif command -v yum &> /dev/null; then
    yum install -y fail2ban
  else
    echo "Error: Không thể xác định trình quản lý gói. Vui lòng cài đặt Fail2Ban thủ công."
    exit 1
  fi

  echo "Cài đặt Fail2Ban hoàn tất."
else
  echo "Fail2Ban đã được cài đặt."
fi

# Kiểm tra xem dịch vụ fail2ban có đang chạy không
echo "Kiểm tra trạng thái dịch vụ fail2ban..."
if ! systemctl is-active --quiet fail2ban; then
  echo "Fail2Ban chưa được khởi động. Đang khởi động Fail2Ban..."
  systemctl start fail2ban
  systemctl enable fail2ban
  echo "Fail2Ban đã được khởi động."
else
  echo "Fail2Ban đang chạy."
fi

# Liệt kê các jail (quy tắc) của Fail2Ban
echo "Danh sách các jail của Fail2Ban:"
fail2ban-client status | grep "Jail list:" | sed "s/\`- Jail list://g" || { echo "Error: Không thể lấy danh sách các jail."; exit 1; }
