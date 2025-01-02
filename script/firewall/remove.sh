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

delete_rule() {
  local port=$1
  local protocol=$2

  if [ -z "$protocol" ]; then
    # Kiểm tra và xóa quy tắc không chỉ định giao thức
    if ufw status | grep -q "^\s*${port}\s"; then
      ufw delete allow "$port"
      echo "Quy tắc cho cổng $port đã được xóa."
    else
      echo "Quy tắc cho cổng $port không tồn tại."
    fi
  else
    # Kiểm tra và xóa quy tắc có giao thức
    if ufw status | grep -q "${port}/${protocol}"; then
      ufw delete allow "$port/$protocol"
      echo "Quy tắc cho cổng $port/$protocol đã được xóa."
    else
      echo "Quy tắc cho cổng $port/$protocol không tồn tại."
    fi
  fi
}

# Xóa quy tắc tường lửa
if [ -z "$PROTOCOL" ]; then
  echo "---- XÓA QUY TẮC TƯỜNG LỬA CHO CẢ TCP VÀ UDP ----"
  delete_rule "$PORT" ""
else
  echo "---- XÓA QUY TẮC TƯỜNG LỬA ----"
  delete_rule "$PORT" "$PROTOCOL"
fi

# Làm mới trạng thái tường lửa
echo "---- LÀM MỚI TRẠNG THÁI TƯỜNG LỬA ----"
ufw reload
echo "Tường lửa đã được làm mới."

# Kiểm tra trạng thái của tường lửa
ufw status
