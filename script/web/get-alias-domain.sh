#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ "$#" -ne 1 ]; then
  echo "Error: Sử dụng: $0 <domain>"
  exit 1
fi

DOMAIN=$1
CONFIG_FILE="/etc/nginx/sites-available/$DOMAIN"

# Kiểm tra file cấu hình của domain
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Không tìm thấy file cấu hình cho domain: $DOMAIN"
  exit 1
fi

# Tìm dòng server_name trong file cấu hình
SERVER_NAME_LINE=$(grep -E "server_name" "$CONFIG_FILE" 2>/dev/null)

if [ -z "$SERVER_NAME_LINE" ]; then
  echo "Không tìm thấy alias domains trong file cấu hình của $DOMAIN"
else
  echo "Alias domains cho domain chính ($DOMAIN):"
  # Lấy danh sách domain, loại bỏ trùng lặp, và loại bỏ domain chính
  echo "$SERVER_NAME_LINE" | sed -E 's/server_name //;s/;//' | tr -s ' ' '\n' | grep -v "^$DOMAIN$" | sort -u
fi
