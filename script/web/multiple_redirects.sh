#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root"
  exit 1
fi

# Đường dẫn file cấu hình Nginx
NGINX_CONFIG="/etc/nginx/conf.d/multiple_redirects.conf"

# Kiểm tra file cấu hình đã tồn tại chưa
if [ ! -f "$NGINX_CONFIG" ]; then
  echo "Tạo mới file cấu hình Nginx: $NGINX_CONFIG"
  touch "$NGINX_CONFIG"
else
  echo "Sử dụng file cấu hình Nginx hiện tại: $NGINX_CONFIG"
fi

# Kiểm tra tham số đầu vào
if [ "$#" -lt 3 ]; then
  echo "Error: Cách sử dụng: $0 domain source1 source2 ... target"
  exit 1
fi

# Lấy domain đầu tiên
DOMAIN="$1"
# Tách target URL khỏi danh sách tham số
TARGET="${@: -1}"
# Lấy danh sách source (trừ domain và target)
SOURCES=(${@:2:$#-2})

# Kiểm tra tính hợp lệ của domain hoặc path
validate_input() {
  local input=$1
  if [[ $input =~ ^/ ]]; then
    return 0 # Hợp lệ nếu là path
  elif [[ $input =~ ^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)+[a-zA-Z]{2,}$ ]]; then
    return 0 # Hợp lệ nếu là domain
  else
    echo "Error: Domain hoặc path không hợp lệ: $input"
    return 1
  fi
}

# Kiểm tra tính hợp lệ của DOMAIN
validate_input "$DOMAIN"
if [ $? -ne 0 ]; then
  echo "Error: Domain chính không hợp lệ: $DOMAIN"
  exit 1
fi

# Thêm các rule 301 vào file cấu hình
for source in "${SOURCES[@]}"; do
  validate_input "$source"
  if [ $? -ne 0 ]; then
    echo "Error: Bỏ qua source không hợp lệ: $source"
    continue
  fi
  echo "Thêm redirect từ $source đến $TARGET"
  if [[ $source =~ ^/ ]]; then
    # Nếu là path
    cat >>"$NGINX_CONFIG" <<EOL
server {
    listen 80;
    server_name $DOMAIN;
    location $source {
        return 301 $TARGET;
    }
}
EOL
  else
    # Nếu là domain
    cat >>"$NGINX_CONFIG" <<EOL
server {
    listen 80;
    server_name $source;
    return 301 $TARGET;
}
EOL
  fi

done

# Kiểm tra file cấu hình Nginx
nginx -t
if [ $? -eq 0 ]; then
  echo "Cấu hình Nginx hợp lệ. Đang khởi động lại Nginx."
  systemctl reload nginx
else
  echo "Error: Cấu hình Nginx không hợp lệ. Đang khôi phục lại thay đổi."
  # Sao lưu file cấu hình cũ
  cp "$NGINX_CONFIG" "$NGINX_CONFIG.bak"
  # Xóa các thay đổi vừa thêm
  for source in "${SOURCES[@]}"; do
    if [[ $source =~ ^/ ]]; then
      sed -i "/location $source {/,+2d" "$NGINX_CONFIG"
    else
      sed -i "/server_name $source;/,/}/d" "$NGINX_CONFIG"
    fi
  done
  echo "Error: Các thay đổi đã được khôi phục. Vui lòng kiểm tra đầu vào và thử lại."
  exit 1
fi

# Hoàn tất
echo "Các rule redirect đã được thêm vào $NGINX_CONFIG."
