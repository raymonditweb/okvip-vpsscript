#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"

# Hàm để kiểm tra status của FTP user
check_ftp_status() {
  local username=$1

  # Kiểm tra xem user có tồn tại trong Pure-FTPd database không
  if pure-pw show "$username" &>/dev/null; then
    # Kiểm tra shell hệ thống để xác định trạng thái
    local shell
    shell=$(getent passwd "$username" | cut -d: -f7)
    if [[ "$shell" == "/sbin/nologin" ]]; then
      echo "Inactive"
    else
      echo "Active"
    fi
  else
    # Không tìm thấy trong Pure-FTPd database
    echo "Inactive"
  fi
}

# Hàm để lấy FTP quota
get_ftp_quota() {
  local username=$1
  local quota=$(pure-pw show "$username" 2>/dev/null | awk '/Ratio/ {split($3,a,":"); print a[1]}')
  if [ -z "$quota" ] || [ "$quota" = "none" ]; then
    echo "Unlimited"
  else
    echo "$quota"
  fi
}

# Hàm để lấy FTP directory
get_ftp_directory() {
  local username=$1
  local dir=$(pure-pw show "$username" 2>/dev/null | grep "Directory" | awk '{print $3}' | sed 's|/./||g')
  if [ -z "$dir" ]; then
    echo "/home/$username"
  else
    echo "$dir"
  fi
}

# Hàm để liệt kê tài khoản FTP
list_accounts() {
  echo "Danh sách chi tiết tài khoản FTP:"
  echo "--------------------------------------------------------------------------------"
  printf "%-15s %-15s %-20s %-15s %-10s\n" "USERNAME" "PASSWORD" "DIRECTORY" "QUOTA" "STATUS"
  echo "--------------------------------------------------------------------------------"

  if [[ -f $FTP_USER_FILE ]]; then
    while IFS=: read -r username password remainder; do
      if [ ! -z "$username" ]; then
        # Lấy thông tin chi tiết
        status=$(check_ftp_status "$username")
        quota=$(get_ftp_quota "$username")
        directory=$(get_ftp_directory "$username")

        password=$(echo "$password")

        printf "%-15s %-15s %-20s %-15s %-10s\n" \
          "$username" \
          "$password" \
          "$directory" \
          "$quota" \
          "$status"
      fi
    done <"$FTP_USER_FILE"
  else
    echo "Error: Không tìm thấy file $FTP_USER_FILE"
    echo "Tạo file mới..."
    touch "$FTP_USER_FILE"
    chmod 600 "$FTP_USER_FILE"
    echo "Đã tạo file $FTP_USER_FILE"
  fi
  echo "--------------------------------------------------------------------------------"
}

# Kiểm tra các lệnh cần thiết
check_requirements() {
  commands=("pure-pw" "grep" "awk")
  for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Error: Lệnh '$cmd' chưa được cài đặt."
      echo "Vui lòng cài đặt Pure-FTPD và các gói cần thiết."
      return 1
    fi
  done
}

# Kiểm tra yêu cầu trước khi chạy
check_requirements

# Thực thi hàm liệt kê tài khoản
list_accounts

# Hiển thị tổng số tài khoản
total_accounts=$(grep -c "." "$FTP_USER_FILE" 2>/dev/null || echo 0)
echo "Tổng số tài khoản: $total_accounts"
