#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Vui lòng chạy script này với quyền root."
    exit 1
fi

# Xác định hệ điều hành và trình quản lý gói để cài đặt UFW
install_ufw() {
    if command -v apt-get &> /dev/null; then
        echo "Cài đặt UFW bằng apt-get trên hệ thống dựa trên Debian/Ubuntu..."
        apt-get update
        apt-get install -y ufw
    elif command -v yum &> /dev/null; then
        echo "Cài đặt UFW bằng yum trên hệ thống dựa trên CentOS/RHEL..."
        yum install -y epel-release
        yum install -y ufw
    else
        echo "Error: Không thể xác định trình quản lý gói. Vui lòng cài đặt UFW thủ công."
        exit 1
    fi
}

# Kiểm tra xem UFW có được cài đặt không, nếu không thì cài đặt
if ! command -v ufw &> /dev/null; then
    echo "UFW không được cài đặt. Đang tiến hành cài đặt UFW..."
    install_ufw
fi

# Kiểm tra lại xem UFW đã cài đặt thành công chưa
if ! command -v ufw &> /dev/null; then
    echo "Error: Cài đặt UFW thất bại. Vui lòng kiểm tra lại."
    exit 1
fi

# Kích hoạt UFW với tùy chọn --force để tự động chọn [y/n] by y khi cài đặt
echo "Kích hoạt UFW..."
ufw --force enable

# Hiển thị danh sách các IP bị chặn
echo "Danh sách các IP bị chặn:"
denied_ips=$(ufw status numbered | grep DENY)

if [ -z "$denied_ips" ]; then
    echo "Chưa có IP nào đang bị chặn."
else
    echo "$denied_ips"
fi
