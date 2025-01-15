#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Hàm cài đặt Pure-FTPD nếu chưa có
install_pureftpd() {
  if ! command -v pure-pw &>/dev/null; then
    echo "Pure-FTPD chưa được cài đặt. Đang tiến hành cài đặt..."
    if command -v apt-get &>/dev/null; then
      apt-get update
      apt-get install -y pure-ftpd
    elif command -v yum &>/dev/null; then
      yum install -y pure-ftpd
    else
      echo "Không thể xác định trình quản lý gói. Vui lòng cài đặt Pure-FTPD thủ công."
      exit 1
    fi
    echo "Pure-FTPD đã được cài đặt."
  else
    echo "Pure-FTPD đã được cài đặt."
  fi
}

# Đường dẫn tới tệp khóa (theo dõi tài khoản bị vô hiệu hóa)
LOCK_FILE="/etc/ftp_users.lock"

# Đảm bảo tệp khóa tồn tại
if [ ! -f "$LOCK_FILE" ]; then
  touch "$LOCK_FILE"
fi

# Hàm để kiểm tra trạng thái của tài khoản FTP
check_ftp_status() {
  local username="$1"

  # Kiểm tra xem tài khoản có bị vô hiệu hóa không
  if grep -q "^$username$" "$LOCK_FILE"; then
    echo "Inactive"
    return
  fi

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
  local quota
  quota=$(pure-pw show "$username" 2>/dev/null | awk '/Ratio/ {print $3}')
  if [ -z "$quota" ] || [ "$quota" = "none" ]; then
    echo "Unlimited"
  else
    echo "$quota"
  fi
}

# Hàm để lấy thư mục của tài khoản FTP
get_ftp_directory() {
  local username="$1"
  local dir
  dir=$(pure-pw show "$username" 2>/dev/null | awk '/Directory/ {print $3}')
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
  printf "%-15s %-35s %-15s %-10s\n" "USERNAME" "DIRECTORY" "QUOTA" "STATUS"
  echo "--------------------------------------------------------------------------------"

  # Lấy danh sách tài khoản từ Pure-FTPd
  pure-pw list | awk '{print $1}' | while read -r username; do
    directory=$(get_ftp_directory "$username")
    quota=$(get_ftp_quota "$username")
    status=$(check_ftp_status "$username")

    printf "%-15s %-35s %-15s %-10s\n" \
      "$username" \
      "$directory" \
      "$quota" \
      "$status"
  done

  # Liệt kê các tài khoản có trong LOCK_FILE mà không có trong Pure-FTPd
  while IFS= read -r locked_user; do
    if ! pure-pw show "$locked_user" &>/dev/null; then
      printf "%-15s %-35s %-15s %-10s\n" \
        "$locked_user" \
        "Unknown" \
        "Unknown" \
        "Inactive"
    fi
  done <"$LOCK_FILE"

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

# Kiểm tra và cài đặt Pure-FTPD nếu cần
install_pureftpd

# Kiểm tra yêu cầu trước khi chạy
check_requirements

# Thực thi hàm liệt kê tài khoản
list_accounts

# Hiển thị tổng số tài khoản
total_accounts=$(pure-pw list | wc -l)
echo "Tổng số tài khoản: $total_accounts"
