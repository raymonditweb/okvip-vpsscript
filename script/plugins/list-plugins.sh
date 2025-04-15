#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Cài jq nếu chưa có
if ! command -v jq >/dev/null 2>&1; then
  echo "Đang cài đặt jq..."
  apt update && apt install -y jq
  if [ $? -ne 0 ]; then
    echo "Error: Cài jq thất bại. Vui lòng kiểm tra kết nối mạng hoặc cấu hình apt."
    exit 1
  fi
fi

# Lấy tham số tìm kiếm và số trang
PAGE=${1:-1}
SEARCH_TERM="$2"

# Gọi API và xử lý dữ liệu
# Nếu có search_term, thực hiện tìm kiếm
if [ -n "$SEARCH_TERM" ]; then
  curl -s "https://api.wordpress.org/plugins/info/1.2/?action=query_plugins&request[search]=$SEARCH_TERM&request[page]=$PAGE" \
  | jq '.plugins[] | {name, slug, rating}'
else
  curl -s "https://api.wordpress.org/plugins/info/1.2/?action=query_plugins&request[page]=$PAGE" \
  | jq '.plugins[] | {name, slug, rating}'
fi
