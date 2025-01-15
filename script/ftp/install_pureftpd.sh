#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Hàm cài đặt Pure-FTPd từ mã nguồn
install_pureftpd_from_source() {
  echo "Đang tải và cài đặt phiên bản mới nhất của Pure-FTPd từ mã nguồn..."
  local temp_dir="/tmp/pure-ftpd"
  mkdir -p "$temp_dir"
  cd "$temp_dir" || exit 1

  # Tải mã nguồn Pure-FTPd mới nhất
  curl -LO https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-latest.tar.gz
  if [ $? -ne 0 ]; then
    echo "Error: Không thể tải mã nguồn Pure-FTPd."
    exit 1
  fi

  # Giải nén và cài đặt
  tar -xzf pure-ftpd-latest.tar.gz
  cd pure-ftpd-* || exit 1
  ./configure --prefix=/usr --sysconfdir=/etc --with-puredb --with-tls
  make && make install
  if [ $? -ne 0 ]; then
    echo "Error: Không thể cài đặt Pure-FTPd từ mã nguồn."
    exit 1
  fi

  echo "Pure-FTPd đã được cài đặt thành công từ mã nguồn."
  cd / || exit 1
  rm -rf "$temp_dir"
}

# Kiểm tra xem Pure-FTPd đã được cài đặt hay chưa
if command -v pure-ftpd >/dev/null 2>&1; then
  echo "Pure-FTPd đã được cài đặt."
else
  echo "Pure-FTPd chưa được cài đặt. Đang tiến hành cài đặt..."

  # Cài đặt Pure-FTPd
  if [ -f /etc/debian_version ]; then
    # Hệ điều hành Debian/Ubuntu
    apt update
    apt install -y pure-ftpd || install_pureftpd_from_source
  elif [ -f /etc/redhat-release ]; then
    # Hệ điều hành CentOS/RHEL
    yum install -y pure-ftpd || install_pureftpd_from_source
  else
    echo "Error: Hệ điều hành không được hỗ trợ. Sẽ cài đặt từ mã nguồn."
    install_pureftpd_from_source
    exit 1
  fi

  echo "Pure-FTPd đã được cài đặt thành công."
fi
