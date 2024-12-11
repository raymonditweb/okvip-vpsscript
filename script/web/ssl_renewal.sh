#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root"
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ -z "$1" ]; then
  echo "Error: Vui lòng nhập domain hoặc IP. Su dung: $0 <domain_or_ip>"
  exit 1
fi

DOMAIN_OR_IP=$1

# Hàm kiểm tra chứng chỉ SSL của domain hoặc IP
check_ssl() {
  echo "Đang kiểm tra chứng chỉ SSL cho $DOMAIN_OR_IP ..."

  # Kiểm tra chứng chỉ SSL bằng lệnh openssl
  local result=$(echo | openssl s_client -connect "$DOMAIN_OR_IP:443" -servername "$DOMAIN_OR_IP" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)

  if [[ -z "$result" ]]; then
    echo "Error: Không thể lấy chứng chỉ SSL từ $DOMAIN_OR_IP."
    return 1
  else
    echo "Chứng chỉ SSL hoạt động bình thường cho $DOMAIN_OR_IP."
    return 0
  fi
}

# Hàm khởi động lại dịch vụ web (nginx, apache2, hoặc dịch vụ tùy chỉnh)
restart_service() {
  # Kiểm tra và khởi động lại dịch vụ nginx nếu tồn tại
  if systemctl is-active --quiet nginx; then
    echo "Đang khởi động lại nginx..."
    systemctl restart nginx
    if [ $? -eq 0 ]; then
      echo "Dịch vụ nginx đã được khởi động lại thành công."
    else
      echo "Error: Lỗi khi khởi động lại dịch vụ nginx."
    fi
  fi

  # Kiểm tra và khởi động lại dịch vụ apache2 nếu tồn tại
  if systemctl is-active --quiet apache2; then
    echo "Đang khởi động lại apache2..."
    systemctl restart apache2
    if [ $? -eq 0 ]; then
      echo "Dịch vụ apache2 đã được khởi động lại thành công."
    else
      echo "Error: Lỗi khi khởi động lại dịch vụ apache2."
    fi
  fi
}

# Thực hiện kiểm tra SSL
check_ssl

# Nếu SSL bị lỗi, khởi động lại dịch vụ
if [ $? -ne 0 ]; then
  echo "Phát hiện lỗi chứng chỉ SSL. Đang khởi động lại dịch vụ..."
  restart_service

  # Kiểm tra lại chứng chỉ SSL
  check_ssl
  if [ $? -eq 0 ]; then
    echo "Chứng chỉ SSL đã được khắc phục sau khi khởi động lại dịch vụ."
  else
    echo "Error: Vẫn có lỗi với chứng chỉ SSL. Vui lòng kiểm tra thủ công."
  fi
else
  echo "Chứng chỉ SSL vẫn đang hoạt động tốt. Không cần khởi động lại dịch vụ."
fi
