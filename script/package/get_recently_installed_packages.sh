#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Vui lòng chạy script này với quyền root."
    exit 1
fi

# Hàm để lấy danh sách gói đã được cài đặt gần đây
get_recently_installed_packages() {
    echo "Danh sách các gói đã được cài đặt gần đây:"
    if [[ -n "$(command -v apt-get)" ]]; then
        # Đối với hệ điều hành Debian/Ubuntu
        dpkg-query -W --showformat='${Package} ${Version}\n' | grep -E "^.*$" | tac | head -n 10
    elif [[ -n "$(command -v rpm)" ]]; then
        # Đối với hệ điều hành Red Hat/CentOS
        rpm -qa --last | head -n 10
    else
        echo "Error: Hệ điều hành không được hỗ trợ."
        exit 1
    fi
}

# Gọi hàm để lấy danh sách gói đã được cài đặt gần đây
get_recently_installed_packages
