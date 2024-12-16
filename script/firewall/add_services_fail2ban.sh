#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Biến lưu lỗi
ERROR_LOG=""

# Kiểm tra tham số đầu vào
SERVICE_NAME="$1"

if [ -z "$SERVICE_NAME" ]; then
  ERROR_LOG+="Error: Sử dụng: $0 [tên_dịch_vụ]\n"
fi

# Loại bỏ dấu ngoặc vuông nếu có trong tên dịch vụ
SERVICE_NAME=$(echo "$SERVICE_NAME" | tr -d '[]')

# Đường dẫn file cấu hình jail.local
JAIL_LOCAL_FILE="/etc/fail2ban/jail.local"
FILTER_CONFIG_FILE="/etc/fail2ban/filter.d/${SERVICE_NAME}.conf"

# Hàm kiểm tra logpath
check_logpath() {
  case "$SERVICE_NAME" in
    sshd) echo "/var/log/auth.log" ;;
    atd) echo "/var/log/syslog" ;;
    nginx) echo "/var/log/nginx/error.log" ;;
    vsftpd|proftpd) echo "/var/log/vsftpd.log" ;;
    dovecot) echo "/var/log/dovecot.log" ;;
    postfix) echo "/var/log/mail.log" ;;
    mysql) echo "/var/log/mysql/error.log" ;;
    pure-ftpd) echo "/var/log/syslog" ;;
    sudo) echo "/var/log/auth.log" ;;
    redis) echo "/var/log/redis/redis-server.log" ;;
    vnc) echo "/var/log/vnc.log" ;;
    rsync) echo "/var/log/rsyncd.log" ;;
    cifs|samba) echo "/var/log/samba/log.smbd" ;;
    *) echo "/var/log/$SERVICE_NAME.log" ;;
  esac
}

# Lấy logpath và kiểm tra tồn tại
LOGPATH=$(check_logpath)
if [ ! -f "$LOGPATH" ]; then
  ERROR_LOG+="Error: File logpath '$LOGPATH' không tồn tại. Vui lòng kiểm tra cấu hình dịch vụ $SERVICE_NAME.\n"
fi

# Kiểm tra trạng thái service
if ! systemctl is-active --quiet "$SERVICE_NAME"; then
  ERROR_LOG+="Error: Dịch vụ $SERVICE_NAME không đang chạy. Không thể thêm vào Fail2Ban.\n"
fi

# Thêm cấu hình dịch vụ vào jail.local
if [ -z "$ERROR_LOG" ]; then
  echo "Đang thêm dịch vụ '$SERVICE_NAME' vào Fail2Ban..."

  # Kiểm tra và thêm phần [DEFAULT] nếu chưa có
  if ! grep -q "\[DEFAULT\]" "$JAIL_LOCAL_FILE"; then
    echo -e "\n[DEFAULT]\n" >>"$JAIL_LOCAL_FILE"
    echo "Phần [DEFAULT] đã được thêm vào $JAIL_LOCAL_FILE."
  fi

  # Kiểm tra nếu dịch vụ đã tồn tại trong jail.local
  if grep -q "^\[$SERVICE_NAME\]" "$JAIL_LOCAL_FILE"; then
    ERROR_LOG+="Error: Dịch vụ $SERVICE_NAME đã tồn tại trong $JAIL_LOCAL_FILE\n"
  else
    # Thêm cấu hình mới cho dịch vụ vào jail.local
    echo -e "\n[$SERVICE_NAME]" >>"$JAIL_LOCAL_FILE"
    echo "enabled = true" >>"$JAIL_LOCAL_FILE"
    echo "filter = $SERVICE_NAME" >>"$JAIL_LOCAL_FILE"
    echo "logpath = $LOGPATH" >>"$JAIL_LOCAL_FILE"
    echo "maxretry = 5" >>"$JAIL_LOCAL_FILE"
    echo "bantime = 3600" >>"$JAIL_LOCAL_FILE"
    echo "Dịch vụ $SERVICE_NAME đã được thêm vào Fail2Ban."

    # Tạo cấu hình filter cho dịch vụ
    echo "Đang tạo filter cho dịch vụ '$SERVICE_NAME'..."
    echo "[INCLUDES]" >"$FILTER_CONFIG_FILE"
    echo "before = common.conf" >>"$FILTER_CONFIG_FILE"
    echo -e "\n[Definition]" >>"$FILTER_CONFIG_FILE"
    echo "failregex = Failed attempt for user: .* from IP: <HOST>" >>"$FILTER_CONFIG_FILE"
    echo "ignoreregex =" >>"$FILTER_CONFIG_FILE"
    echo "Filter cho dịch vụ $SERVICE_NAME đã được tạo."

    # Khởi động lại Fail2Ban để áp dụng thay đổi
    echo "Đang khởi động lại Fail2Ban..."
    sudo systemctl restart fail2ban
    echo "Fail2Ban đã được khởi động lại."
  fi
fi

# Kiểm tra lỗi và in ra thông báo lỗi nếu có
if [ -n "$ERROR_LOG" ]; then
  echo -e "$ERROR_LOG"
else
  # Hoàn tất nếu không có lỗi
  echo "Dịch vụ $SERVICE_NAME đã được thêm vào danh sách giám sát của Fail2Ban."
fi
