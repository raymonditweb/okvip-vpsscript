#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
PHP_VERSION="$1"
if [ -z "$PHP_VERSION" ]; then
  echo "Error: Sử dụng: $0 [phiên_bản_php] (ví dụ: 7.0)"

# Nhận tham số phiên bản PHP cần chuyển
PHP_VERSION=$1
PHP_CLI_PATH="/usr/bin/php$PHP_VERSION"

# Kiểm tra hệ điều hành
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  echo "Error: OS không được phát hiện."
  exit 1
fi

# Hàm cài đặt PHP nếu chưa có
install_php() {
  echo "Đang kiểm tra và cài đặt PHP $php_version.."
  if command -v apt-get &> /dev/null; then
    sudo apt update
    sudo apt install -y php$PHP_VERSION php$PHP_VERSION-cli php$PHP_VERSION-fpm libapache2-mod-php$PHP_VERSION
  elif command -v yum &> /dev/null; then
    sudo yum install -y epel-release
    sudo yum install -y https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E %rhel).rpm
    sudo yum module reset php -y
    sudo yum module enable php:remi-$PHP_VERSION -y
    sudo yum install -y php php-cli php-fpm
  else
    echo "Error: Không xác định được trình quản lý gói. Vui lòng cài đặt PHP $php_version thủ công."
    exit 1
  fi
}

# Kiểm tra và cài đặt nếu PHP chưa được cài đặt
if ! [ -f "$PHP_CLI_PATH" ]; then
  echo "PHP $PHP_VERSION chưa được cài đặt. Tiến hành cài đặt..."
  install_php

  # Kiểm tra lại sau khi cài đặt
  if ! [ -f "$PHP_CLI_PATH" ]; then
    echo "Error: Không thể cài đặt PHP $PHP_VERSION. Vui lòng kiểm tra lại."
    exit 1
  fi
else
  echo "PHP $PHP_VERSION đã có sẵn trên hệ thống."
fi

# Cấu hình cho Apache (nếu có)
if command -v apache2ctl &> /dev/null; then
  echo "Configuring Apache de su dung $PHP_VERSION..."
  # Disable hiện tại và kích hoạt phiên bản mới
  sudo a2dismod php*
  sudo a2enmod php$PHP_VERSION
  sudo systemctl restart apache2
  echo "Apache configured to use PHP $PHP_VERSION."
fi

# Cấu hình cho Nginx (nếu có)
if command -v nginx &> /dev/null; then
  echo "Configuring Nginx de su dung PHP $PHP_VERSION..."
  # Dừng các dịch vụ PHP hiện tại
  sudo systemctl stop php*-fpm
  sudo systemctl disable php*-fpm

  # Bật và khởi động dịch vụ PHP mới
  sudo systemctl enable php$PHP_VERSION-fpm
  sudo systemctl start php$PHP_VERSION-fpm
  sudo systemctl restart nginx
  echo "Nginx configured to use PHP $PHP_VERSION."
fi

# Đăng ký PHP CLI mặc định
echo "Registering PHP $PHP_VERSION as default PHP CLI..."
sudo update-alternatives --install /usr/bin/php php $PHP_CLI_PATH 1
sudo update-alternatives --set php $PHP_CLI_PATH

# Hiển thị phiên bản PHP hiện tại
echo "Phiên bản PHP hiện tại:"
php -v

# Hoàn tất
echo "Thay đổi PHP sang $PHP_VERSION hoàn tất!"
