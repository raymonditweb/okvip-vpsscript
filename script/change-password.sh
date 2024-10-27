#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra hệ điều hành là Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
  echo "Error: Script này chỉ hỗ trợ hệ điều hành Ubuntu."
  exit 1
fi

# Kiểm tra đối số đầu vào
if [ -z "$1" ]; then
  echo "Error: Vui lòng cung cấp mật khẩu root mới."
  echo "Usage: $0 <new_root_password>"
  exit 1
fi

NEW_PASSWORD=$1

# Đổi mật khẩu root
echo "Đang thay đổi mật khẩu root..."
echo "root:$NEW_PASSWORD" | chpasswd

# Kiểm tra lỗi sau khi đổi mật khẩu
if [ $? -eq 0 ]; then
  echo "Mật khẩu root đã được thay đổi thành công."
else
  echo "Error: Đã có lỗi xảy ra khi thay đổi mật khẩu root."
  exit 1
fi
