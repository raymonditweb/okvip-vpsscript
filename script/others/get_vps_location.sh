#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Hàm cài đặt jq sử dụng trình quản lý gói phù hợp
install_jq() {
  echo "Đang cố gắng cài đặt jq..."
  if command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y jq
  elif command -v yum &>/dev/null; then
    sudo yum install -y jq
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y jq
  elif command -v pacman &>/dev/null; then
    sudo pacman -S jq --noconfirm
  else
    echo
    return 1
  fi

  # Xác minh xem jq đã được cài đặt thành công chưa
  if ! command -v jq &>/dev/null; then
    echo
    return 1
  fi
}

# Kiểm tra nếu curl đã được cài đặt
if ! command -v curl &>/dev/null; then
  echo
  exit 1
fi

# Kiểm tra nếu jq đã được cài đặt, nếu chưa thì cài đặt
if ! command -v jq &>/dev/null; then
  install_jq
fi

# Lấy dữ liệu vị trí bằng ipinfo.io với timeout 10 giây
echo "Đang lấy thông tin vị trí VPS..."
response=$(curl -s --max-time 10 https://ipinfo.io)

# Kiểm tra nếu gọi API thành công hoặc hết thời gian chờ
if [[ -z "$response" || "$response" == *"error"* ]]; then
  echo
  exit 1
fi

# Hiển thị toàn bộ thông tin phản hồi
echo "Phản hồi từ API:"
echo "$response"
