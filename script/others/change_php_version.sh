#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
PHP_VERSION="$1"
if [ -z "$PHP_VERSION" ]; then
  echo "Error: Sử dụng: $0 [phiên_bản_php] (ví dụ: php7.4, php8.1)"
  exit 1
fi

# Hàm cài đặt PHP
install_php() {
  local php_version="$1"
  echo "Đang kiểm tra và cài đặt PHP $php_version..."
  
  if command -v apt-get &> /dev/null; then
    # Với hệ thống Debian/Ubuntu
    add-apt-repository -y ppa:ondrej/php
    apt-get update
    apt-get install -y "$php_version" "${php_version}-cli" "${php_version}-fpm" "${php_version}-common"
  elif command -v yum &> /dev/null; then
    # Với hệ thống CentOS/RHEL
    yum install -y epel-release
    yum install -y "php-$php_version" "php-$php_version-cli" "php-$php_version-fpm" "php-$php_version-common"
  else
    echo "Error: Không xác định được trình quản lý gói. Vui lòng cài đặt PHP $php_version thủ công."
    exit 1
  fi
}

# Hiển thị các phiên bản PHP hiện có
echo "Các phiên bản PHP có sẵn trên hệ thống:"
available_php=$(update-alternatives --list php | awk -F'/' '{print $NF}')
if [ -z "$available_php" ]; then
  echo "Error: Không tìm thấy bất kỳ phiên bản PHP nào trên hệ thống."
else
  echo "$available_php"
fi

# Kiểm tra phiên bản PHP yêu cầu
PHP_PATH=$(update-alternatives --list php | grep "$PHP_VERSION")
if [ -z "$PHP_PATH" ]; then
  echo "PHP $PHP_VERSION chưa được cài đặt. Tiến hành cài đặt..."
  install_php "$PHP_VERSION"
  PHP_PATH=$(update-alternatives --list php | grep "$PHP_VERSION")
  
  if [ -z "$PHP_PATH" ]; then
    echo "Error: Không thể cài đặt PHP $PHP_VERSION. Vui lòng kiểm tra lại."
    exit 1
  fi
else
  echo "PHP $PHP_VERSION đã có sẵn trên hệ thống."
fi

# Chuyển đổi phiên bản PHP
echo "Đang thay đổi phiên bản PHP sang $PHP_VERSION..."
update-alternatives --set php "$PHP_PATH"

# Kiểm tra và thay đổi phiên bản cho Apache (nếu có)
if command -v apache2ctl &> /dev/null; then
  echo "Đang kiểm tra Apache..."
  a2dismod $(ls /etc/apache2/mods-enabled/ | grep php | sed 's/\.conf//') &> /dev/null
  a2enmod "$PHP_VERSION" &> /dev/null
  systemctl restart apache2
  echo "Đã chuyển đổi PHP cho Apache sang $PHP_VERSION."
fi

# Kiểm tra và thay đổi phiên bản cho Nginx (nếu có)
if command -v nginx &> /dev/null; then
  echo "Đang kiểm tra Nginx..."
  systemctl restart php"${PHP_VERSION#php}"-fpm
  echo "Đã cấu hình PHP $PHP_VERSION cho Nginx."
fi

# Hiển thị phiên bản PHP hiện tại
echo "Phiên bản PHP hiện tại:"
php -v

# Hoàn tất
echo "Thay đổi PHP sang $PHP_VERSION hoàn tất!"
