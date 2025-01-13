#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ -z "$1" ]; then
  echo "Error: Vui lòng nhập domain hoặc IP. Sử dụng: $0 <domain_or_ip>"
  exit 1
fi

DOMAIN_OR_IP=$1
TIMEOUT_DURATION=60 # Thời gian timeout (giây)

# Hàm kiểm tra và cài đặt certbot nếu chưa có
install_certbot() {
  if ! command -v certbot &>/dev/null; then
    echo "Certbot chưa được cài đặt. Đang cài đặt certbot..."
    if [ -x "$(command -v apt)" ]; then
      apt update && apt install -y certbot
    elif [ -x "$(command -v yum)" ]; then
      yum install -y certbot
    else
      echo "Error: Không thể xác định trình quản lý gói để cài đặt certbot. Vui lòng cài đặt thủ công."
      return 1
    fi
    echo "Certbot đã được cài đặt thành công."
  else
    echo "Certbot đã được cài đặt."
  fi
}

# Hàm kiểm tra proxy
check_proxy() {
  local cf_ip=$(dig +short "$DOMAIN_OR_IP" | head -n 1)
  local cf_proxy_subnet="104.16.0.0/12"

  if [[ $(ipcalc -c "$cf_ip" "$cf_proxy_subnet") == "true" ]]; then
    echo "Error: Không thể đăng ký SSL vì proxy. Vui lòng tắt proxy để đăng ký SSL."
    exit 1
  fi
}

# Hàm kiểm tra chứng chỉ SSL
check_ssl() {
  echo "Đang kiểm tra chứng chỉ SSL cho $DOMAIN_OR_IP ..."
  SSL_INFO=$(timeout $TIMEOUT_DURATION bash -c "echo | openssl s_client -connect \"$DOMAIN_OR_IP:443\" -servername \"$DOMAIN_OR_IP\" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null")

  if [ $? -ne 0 ]; then
    echo "Timeout hoặc không tìm thấy chứng chỉ SSL cho $DOMAIN_OR_IP."
    return 1
  else
    echo "Chứng chỉ SSL hoạt động bình thường cho $DOMAIN_OR_IP."
    END_DATE=$(echo "$SSL_INFO" | grep 'notAfter' | cut -d= -f2)
    echo "Ngày hết hạn chứng chỉ SSL: $END_DATE"
    return 1
  fi
}

# Hàm tạo chứng chỉ SSL mới bằng certbot
create_ssl() {
  echo "Đang tạo chứng chỉ SSL mới cho $DOMAIN_OR_IP ..."
  echo "Tạm thời dừng nginx để sử dụng certbot ở chế độ standalone..."
  systemctl stop nginx || {
    echo "Error: Không thể dừng nginx."
    exit 1
  }

  timeout $TIMEOUT_DURATION certbot certonly --standalone -d "$DOMAIN_OR_IP" --non-interactive --agree-tos -m admin@$DOMAIN_OR_IP
  if [ $? -eq 0 ]; then
    echo "Chứng chỉ SSL đã được tạo thành công."
  else
    echo "Error: Timeout hoặc không thể tạo chứng chỉ SSL."
    exit 1
  fi
}

# Hàm làm mới chứng chỉ SSL
renew_ssl() {
  echo "Đang làm mới chứng chỉ SSL cho $DOMAIN_OR_IP ..."
  timeout $TIMEOUT_DURATION certbot renew --non-interactive
  if [ $? -eq 0 ]; then
    echo "Chứng chỉ SSL đã được làm mới thành công."
  else
    echo "Error: Timeout hoặc không thể làm mới chứng chỉ SSL."
    return 1
  fi
}

# Hàm khởi động lại dịch vụ nginx
restart_service() {
  echo "Đang khởi động lại nginx..."
  systemctl restart nginx || {
    echo "Error: Lỗi khi khởi động lại nginx."
    exit 1
  }
  echo "Dịch vụ nginx đã được khởi động lại thành công."
}

# Đảm bảo nginx luôn được khởi động lại dù có lỗi
trap 'restart_service' EXIT

# Cài đặt certbot nếu cần
install_certbot

# Kiểm tra proxy
check_proxy

# Kiểm tra SSL
check_ssl
if [ $? -ne 0 ]; then
  create_ssl
else
  renew_ssl
fi
