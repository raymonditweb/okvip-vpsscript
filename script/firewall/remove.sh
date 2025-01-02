#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số cổng
if [ -z "$1" ]; then
  echo "Error: Vui lòng cung cấp cổng và giao thức (tcp/udp)."
  echo "Usage: $0 <port> <tcp|udp>"
  exit 1
fi

PORT=$1
PROTOCOL=$2

# Xóa quy tắc tường lửa
if [ -z "$PROTOCOL" ]; then
  echo "---- XÓA QUY TẮC TƯỜNG LỬA CHO CẢ TCP VÀ UDP ----"
  ufw delete allow $PORT/tcp
  ufw delete allow $PORT/udp
else
  echo "---- XÓA QUY TẮC TƯỜNG LỬA ----"
  ufw delete allow $PORT/$PROTOCOL
fi

# Kiểm tra trạng thái của tường lửa
ufw status
