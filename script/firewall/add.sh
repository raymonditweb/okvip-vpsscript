#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số cổng
if [ -z "$1" ]; then
  echo "Error: Vui lòng cung cấp cổng."
  echo "Usage: $0 <port> [tcp|udp]"
  exit 1
fi

PORT=$1
PROTOCOL=$2

# Kiểm tra trạng thái của UFW
if ! ufw status | grep -q "Status: active"; then
  echo "UFW chưa được kích hoạt. Đang kích hoạt..."
  ufw --force enable || {
    echo "Error: Không thể kích hoạt UFW."
    exit 1
  }
fi

# Kiểm tra và xác định giao thức
if [ -z "$PROTOCOL" ]; then
  echo "Không có giao thức được cung cấp. Đang mở full port (TCP và UDP)..."
  ufw allow $PORT || {
    echo "Error: Lỗi khi thêm quy tắc tường lửa cho cổng $PORT."
    exit 1
  }
else
  # Kiểm tra giao thức có hợp lệ hay không
  if [[ "$PROTOCOL" != "tcp" && "$PROTOCOL" != "udp" ]]; then
    echo "Error: Giao thức không hợp lệ. Vui lòng chọn tcp hoặc udp."
    exit 1
  fi
  echo "Đang mở cổng $PORT với giao thức $PROTOCOL..."
  ufw allow $PORT/$PROTOCOL || {
    echo "Error: Lỗi khi thêm quy tắc tường lửa cho cổng $PORT/$PROTOCOL."
    exit 1
  }
fi

# Kiểm tra trạng thái của tường lửa
echo "Kiểm tra trạng thái của tường lửa..."
ufw status

echo "Quy tắc tường lửa đã được thêm thành công."
