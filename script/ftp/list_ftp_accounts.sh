#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Hàm để kiểm tra trạng thái của tài khoản FTP
check_ftp_status() {
  local username="$1"
  # Kiểm tra xem tài khoản có tồn tại trong Pure-FTPd không
  if pure-pw show "$username" &>/dev/null; then
    echo "Active"
  else
    echo "Inactive"
  fi
}

# Hàm để lấy quota của tài khoản FTP
get_ftp_quota() {
  local username="$1"
  local quota=$(pure-pw show "$username" 2>/dev/null | awk '/Quota/ {print $3}')
  if [ -z "$quota" ] || [ "$quota" = "none" ]; then
    echo "Unlimited"
  else
    echo "$quota"
  fi
}

# Hàm để lấy thư mục của tài khoản FTP
get_ftp_directory() {
  local username="$1"
  local dir=$(pure-pw show "$username" 2>/dev/null | awk '/Directory/ {print $3}')
  if [ -z "$dir" ]; then
    echo "Unknown"
  else
    echo "$dir"
  fi
}

# Hàm để liệt kê danh sách tài khoản FTP
list_accounts() {
  echo "Danh sách chi tiết tài khoản FTP:"
  echo "--------------------------------------------------------------------------------"
  printf "%-15s %-20s %-15s %-10s\n" "USERNAME" "DIRECTORY" "QUOTA" "STATUS"
  echo "--------------------------------------------------------------------------------"

  # Lấy danh sách tài khoản từ Pure-FTPd
  pure-pw list | awk '{print $1}' | while read -r username; do
    directory=$(get_ftp_directory "$username")
    quota=$(get_ftp_quota "$username")
    status=$(check_ftp_status "$username")

    printf "%-15s %-20s %-15s %-10s\n" \
      "$username" \
      "$directory" \
      "$quota" \
      "$status"
  done
  echo "--------------------------------------------------------------------------------"
}

# Kiểm tra các lệnh cần thiết
check_requirements() {
  commands=("pure-pw" "awk")
  for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Error: Lệnh '$cmd' chưa được cài đặt."
      echo "Vui lòng cài đặt Pure-FTPD và các gói cần thiết."
      exit 1
    fi
  done
}

# Kiểm tra yêu cầu trước khi chạy
check_requirements

# Thực thi hàm liệt kê tài khoản
list_accounts

# Hiển thị tổng số tài khoản
total_accounts=$(pure-pw list | wc -l)
echo "Tổng số tài khoản: $total_accounts"
