#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra trạng thái của fail2ban
if ! systemctl is-active --quiet fail2ban; then
  echo "Fail2Ban không hoạt động. Đang gỡ bỏ và cài đặt lại..."

  # Gỡ bỏ fail2ban
  apt-get remove --purge -y fail2ban

  # Cài đặt lại fail2ban
  apt-get update
  apt-get install -y fail2ban

  # Khởi động lại fail2ban
  systemctl start fail2ban

  echo "Fail2Ban đã được cài đặt lại và khởi động thành công."
else
  echo "Fail2Ban đang hoạt động."
fi
