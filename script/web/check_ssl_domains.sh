#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root"
  exit 1
fi

# Hàm kiểm tra trạng thái SSL
check_ssl() {
  local domain=$1
  echo "Đang kiểm tra SSL cho $domain..."

  # Sử dụng openssl để kiểm tra chứng chỉ
  local output=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -dates)

  if [[ -z "$output" ]]; then
    echo "Kiểm tra SSL thất bại cho $domain: Không thể kết nối hoặc không có chứng chỉ SSL."
  else
    local start_date=$(echo "$output" | grep "notBefore" | cut -d= -f2)
    local end_date=$(echo "$output" | grep "notAfter" | cut -d= -f2)
    echo "Tên miền: $domain"
    echo "  Ngày bắt đầu SSL: $start_date"
    echo "  Ngày hết hạn SSL: $end_date"
  fi
  echo "-----------------------------"
}

# Lấy danh sách tên miền từ các tệp cấu hình Nginx
nginx_conf_dir="/etc/nginx/sites-enabled"

if [[ ! -d $nginx_conf_dir ]]; then
  echo "Không tìm thấy thư mục cấu hình Nginx: $nginx_conf_dir"
  exit 1
fi

domains=$(grep -rE "server_name" $nginx_conf_dir | awk '{print $2}' | sed 's/;//' | sort | uniq)

if [[ -z "$domains" ]]; then
  echo "Không tìm thấy tên miền nào trong cấu hình Nginx."
  exit 1
fi

# Lặp qua tất cả các tên miền và kiểm tra trạng thái SSL
for domain in $domains; do
  check_ssl "$domain"
done
