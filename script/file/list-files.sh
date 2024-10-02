#!/bin/bash

# Kiểm tra xem người dùng có quyền root hay không
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra nếu đối số đầu vào (thư mục) được cung cấp
if [ -z "$1" ]; then
  echo "Error: Vui lòng cung cấp thư mục để liệt kê."
  exit 1
fi

DIRECTORY=$1

# Kiểm tra nếu thư mục tồn tại
if [ ! -d "$DIRECTORY" ]; then
  echo "Error: Thư mục $DIRECTORY không tồn tại."
  exit 1
fi

# Liệt kê file và thư mục
echo "Danh sách file và thư mục trong $DIRECTORY:"
ls -l "$DIRECTORY"
