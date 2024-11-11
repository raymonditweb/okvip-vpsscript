#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Vui lòng chạy script này với quyền root."
    exit 1
fi

# Hàm để cài đặt ifconfig và ifstat
install_tools() {
# Cài đặt các công cụ ifconfig và ifstat.
# 
# Lệnh này sẽ cài đặt ifconfig và ifstat trên hệ điều hành.
# 
# Trả về 0 nếu cài đặt thành công, 1 nếu không.
    if [[ -n "$(command -v apt-get)" ]]; then
        # Hệ điều hành dựa trên Debian (Ubuntu)
        echo "Đang cài đặt ifconfig và ifstat trên hệ điều hành Ubuntu/Debian..."
        apt-get update -y
        apt-get install net-tools ifstat -y
    elif [[ -n "$(command -v yum)" ]]; then
        # Hệ điều hành dựa trên Red Hat (CentOS)
        echo "Đang cài đặt ifconfig và ifstat trên hệ điều hành Red Hat/CentOS..."
        yum install net-tools ifstat -y
    else
        echo "Trình quản lý gói không được hỗ trợ. Vui lòng cài đặt ifconfig và ifstat theo cách thủ công."
        exit 1
    fi
}

# Kiểm tra ifconfig
if ! command -v ifconfig &> /dev/null; then
    echo "ifconfig không được cài đặt."
    install_tools
else
    echo "ifconfig đã được cài đặt."
fi

# Kiểm tra ifstat
if ! command -v ifstat &> /dev/null; then
    echo "ifstat không được cài đặt."
    install_tools
else
    echo "ifstat đã được cài đặt."
fi

# Hiển thị tải CPU
echo "Tải CPU:"
top -b -n1 | grep "Cpu(s)"

# Hiển thị thông tin mạng sử dụng ifconfig
echo -e "\nThông tin mạng (ifconfig):"
ifconfig

# Hiển thị thông tin tải sử dụng ifstat trong 1 giây
echo -e "\nThông tin tải sử dụng ifstat (tonge 1 giây):"
ifstat -S 1 1
