#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Hiển thị các quy tắc tường lửa hiện có
echo "---- DANH SÁCH QUY TẮC TƯỜNG LỬA ----"
ufw status verbose
