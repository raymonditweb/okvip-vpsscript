#!/bin/bash

# Kiểm tra xem người dùng có quyền root hay không
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra nếu đối số (chmod code và file/thư mục) được cung cấp
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: Vui lòng cung cấp quyền chmod và file/thư mục."
  echo "Usage: ./set-chmod.sh <permission_code> <file_or_folder>"
  exit 1
fi

PERMISSION=$1
FILE_OR_FOLDER=$2

# Kiểm tra nếu file hoặc thư mục tồn tại
if [ ! -e "$FILE_OR_FOLDER" ]; then
  echo "Error: File hoặc thư mục $FILE_OR_FOLDER không tồn tại."
  exit 1
fi

# Thực hiện chmod
chmod "$PERMISSION" "$FILE_OR_FOLDER"
echo "Đã thiết lập quyền $PERMISSION cho $FILE_OR_FOLDER."
