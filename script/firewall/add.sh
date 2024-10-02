#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số cổng và giao thức
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: Vui lòng cung cấp cổng và giao thức (tcp/udp)."
  echo "Usage: $0 <port> <tcp|udp>"
  exit 1
fi

PORT=$1
PROTOCOL=$2

# Thêm quy tắc tường lửa
echo "---- THÊM QUY TẮC TƯỜNG LỬA ----"
ufw allow $PORT/$PROTOCOL

# Kiểm tra trạng thái của tường lửa
ufw status
