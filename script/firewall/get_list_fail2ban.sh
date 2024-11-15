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

# Tạo file cấu hình mặc định để bảo vệ SSH
JAIL_LOCAL_FILE="/etc/fail2ban/jail.local"
if [ ! -f "$JAIL_LOCAL_FILE" ]; then
  echo "Tạo file cấu hình Fail2Ban mặc định tại $JAIL_LOCAL_FILE..."
  {
    echo "[DEFAULT]"
    echo "bantime = 3600"
    echo "findtime = 600"
    echo "maxretry = 5"
    echo ""
    echo "[sshd]"
    echo "enabled = true"
    echo "port = ssh"
    echo "filter = sshd"
    echo "logpath = /var/log/auth.log"
    echo "maxretry = 5"
  } > "$JAIL_LOCAL_FILE"
  echo "Cấu hình Fail2Ban mặc định đã được tạo."
else
  echo "Cấu hình Fail2Ban mặc định đã tồn tại."
fi

# Bảo vệ SSH
echo "Đảm bảo bảo vệ kết nối SSH đang hoạt động..."
if ! fail2ban-client status sshd &> /dev/null; then
  echo "Jail 'sshd' không hoạt động. Đang kích hoạt..."
  systemctl restart fail2ban
else
  echo "Jail 'sshd' đang hoạt động."
fi

# Kiểm tra trạng thái Fail2Ban và danh sách jail
echo "Kiểm tra trạng thái Fail2Ban và danh sách jail..."
fail2ban-client reload
fail2ban-client status | grep "Jail list:" | sed "s/\`- Jail list://g"
