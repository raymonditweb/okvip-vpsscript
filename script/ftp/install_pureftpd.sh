#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra xem Pure-FTPd đã được cài đặt hay chưa
if command -v pure-ftpd > /dev/null 2>&1; then
  echo "Error: Pure-FTPd đã được cài đặt."
else
  echo "Pure-FTPd chưa được cài đặt. Đang tiến hành cài đặt..."

  # Cài đặt Pure-FTPd
  if [ -f /etc/debian_version ]; then
    # Hệ điều hành Debian/Ubuntu
    apt update
    apt install -y pure-ftpd
  elif [ -f /etc/redhat-release ]; then
    # Hệ điều hành CentOS/RHEL
    yum install -y pure-ftpd
  else
    echo "Error: Hệ điều hành không được hỗ trợ."
    exit 1
  fi

  echo "Pure-FTPd đã được cài đặt thành công."
fi
