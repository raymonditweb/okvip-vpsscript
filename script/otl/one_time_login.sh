#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root."
  exit 1
fi

# Kiểm tra và lấy tham số domain từ dòng lệnh
if [ "$#" -ne 3 ]; then
  echo "Cách dùng: $0 <DOMAIN> <WP_USERNAME> <WP_PASSWORD>"
  exit 1
fi

DOMAIN="$1"
WP_USERNAME="$2"
WP_PASSWORD="$3"

# Kiểm tra và cài đặt các package cần thiết
install_required_packages() {
  echo "Đang kiểm tra và cài đặt các package cần thiết..."

  # Cài đặt wp-cli nếu chưa có
  if ! command -v wp &>/dev/null; then
    echo "wp-cli chưa được cài đặt. Đang cài đặt wp-cli..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    echo "wp-cli đã được cài đặt thành công."
  fi

  # Cài đặt jq nếu chưa có
  if ! command -v jq &>/dev/null; then
    echo "jq chưa được cài đặt. Đang cài đặt jq..."
    sudo apt-get update
    sudo apt-get install -y jq
    echo "jq đã được cài đặt thành công."
  fi

  # Cài đặt PHP và các extension cần thiết nếu chưa có
  if ! php -m | grep -q mysqli; then
    echo "PHP hoặc extension mysqli chưa được cài đặt. Đang cài đặt..."
    sudo apt-get update
    sudo apt-get install -y php-cli php-mysql

    # Khởi động lại dịch vụ web sau khi cài đặt extension
    echo "Khởi động lại dịch vụ web để áp dụng thay đổi..."
    if command -v systemctl &>/dev/null; then
      sudo systemctl restart nginx || sudo systemctl restart apache2
    else
      sudo service nginx restart || sudo service apache2 restart
    fi

    echo "PHP và extension mysqli đã được cài đặt và kích hoạt."
  fi

  # Kiểm tra và cài đặt curl nếu chưa có
  if ! command -v curl &>/dev/null; then
    echo "curl chưa được cài đặt. Đang cài đặt curl..."
    sudo apt-get install -y curl
    echo "curl đã được cài đặt thành công."
  fi

  echo "Hoàn thành kiểm tra và cài đặt các package cần thiết."
}

# Tự động phát hiện WP_URL và WP_PATH
get_wp_info() {
  echo "Đang dò tìm cài đặt WordPress cho domain: $DOMAIN"

  # Kiểm tra cấu hình Nginx
  NGINX_CONFIG=$(grep -rl "$DOMAIN" /etc/nginx/sites-available/ 2>/dev/null)
  if [ -z "$NGINX_CONFIG" ]; then
    echo "Error: Không tìm thấy cấu hình Nginx cho domain $DOMAIN" >&2
    exit 1
  fi

  echo "Tìm thấy cấu hình Nginx: $NGINX_CONFIG"

  # Lấy giá trị root từ cấu hình Nginx
  WP_PATH=$(grep -E "root[[:space:]]+" "$NGINX_CONFIG" | awk '{print $2}' | tr -d ';')
  if [ -z "$WP_PATH" ]; then
    echo "Error: Không tìm thấy đường dẫn gốc trong cấu hình Nginx." >&2
    exit 1
  fi

  # Xác định WP_URL
  WP_URL="https://$DOMAIN"

  echo "Đã dò thấy WP_PATH: $WP_PATH"
  echo "Đã dò thấy WP_URL: $WP_URL"
}

# Tự động tạo JWT_SECRET_KEY nếu chưa có
JWT_SECRET_KEY=$(openssl rand -base64 32)
echo "Đã tạo JWT Secret Key: $JWT_SECRET_KEY"

# Cài đặt plugin JWT Authentication
install_jwt_plugin() {
  echo "Đang kiểm tra plugin JWT Authentication..."

  # Kiểm tra nếu plugin đã được cài đặt
  if wp plugin is-installed jwt-authentication-for-wp-rest-api --path="$WP_PATH" --allow-root; then
    echo "Plugin đã được cài đặt."
  else
    echo "Cài đặt plugin JWT Authentication..."
    wp plugin install jwt-authentication-for-wp-rest-api --path="$WP_PATH" --allow-root || {
      echo "Error: Không thể cài đặt plugin." >&2
      exit 1
    }
  fi

  # Kích hoạt plugin nếu chưa kích hoạt
  if ! wp plugin is-active jwt-authentication-for-wp-rest-api --path="$WP_PATH" --allow-root; then
    echo "Kích hoạt plugin JWT Authentication..."
    wp plugin activate jwt-authentication-for-wp-rest-api --path="$WP_PATH" --allow-root || {
      echo "Error: Không thể kích hoạt plugin." >&2
      exit 1
    }
  else
    echo "Plugin đã được kích hoạt."
  fi

  echo "Cài đặt plugin thành công."
}

# Cấu hình JWT trong file wp-config.php
configure_jwt() {
  echo "Đang cấu hình JWT Authentication trong wp-config.php..."
  CONFIG_FILE="$WP_PATH/wp-config.php"

  # Kiểm tra xem file wp-config.php có tồn tại không
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Không tìm thấy file wp-config.php tại $CONFIG_FILE." >&2
    exit 1
  fi

  # Thêm JWT_SECRET_KEY vào trước dòng "/* That's all, stop editing! Happy publishing. */"
  if ! grep -q "JWT_AUTH_SECRET_KEY" "$CONFIG_FILE"; then
    sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i \\
// Cấu hình JWT Authentication\ndefine('JWT_AUTH_SECRET_KEY', '$JWT_SECRET_KEY');\ndefine('JWT_AUTH_CORS_ENABLE', true);" "$CONFIG_FILE"
    echo "Đã thêm cấu hình JWT vào wp-config.php."
  else
    echo "Cấu hình JWT đã tồn tại trong wp-config.php."
  fi

  # Kiểm tra lỗi cú pháp trong wp-config.php
  if ! php -l "$CONFIG_FILE" &>/dev/null; then
    echo "Error: Cú pháp file wp-config.php không hợp lệ." >&2
    exit 1
  fi
}

# Tạo token
generate_token() {
  echo "Đang kiểm tra kết nối tới máy chủ..."
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$WP_URL/wp-json")

  if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "Error: Máy chủ không phản hồi đúng. HTTP status: $HTTP_STATUS" >&2
    exit 1
  fi

  echo "Kết nối tới máy chủ thành công. Đang tạo JWT token..."

  RESPONSE=$(curl -s -L -X POST -H "Content-Type: application/json" \
    -d "{\"username\": \"$WP_USERNAME\", \"password\": \"$WP_PASSWORD\"}" \
    "$WP_URL/wp-json/jwt-auth/v1/token")

  if echo "$RESPONSE" | grep -q "token"; then
    TOKEN=$(echo "$RESPONSE" | jq -r '.token')
    echo "Đã tạo token thành công: $TOKEN"
  else
    echo "Error: Không thể tạo token: $RESPONSE" >&2
    exit 1
  fi
}

# Thực thi các bước
install_required_packages
get_wp_info
install_jwt_plugin
configure_jwt
generate_token
