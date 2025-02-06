#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root"
  exit 1
fi

# Đường dẫn đến file cấu hình
CONFIG_FILE="/home/vpsscript.conf"

# Kiểm tra xem file cấu hình có tồn tại không
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: File cấu hình $CONFIG_FILE không tồn tại!"
  exit 1
fi

# Nếu file tồn tại, thông báo kết nối thành công
echo "Kết nối thành công: Đã tìm thấy file cấu hình!"
