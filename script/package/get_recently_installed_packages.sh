#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Function to get service status and PID
get_service_status() {
  local service_name="$1"
  local status="Unknown"
  local pid="N/A"

  # Check with systemctl
  if systemctl list-unit-files | grep -q "$service_name"; then
    local systemctl_status=$(systemctl is-active "$service_name" 2>/dev/null)
    case "$systemctl_status" in
      active)
        status="Running"
        # Get PID of the running service
        pid=$(pgrep -f "$service_name" | head -n 1)
        if [ -z "$pid" ]; then
          pid="No matching PID found" # Nếu không tìm thấy PID
        fi
        ;;
      inactive)
        status="Stopped"
        ;;
      failed)
        status="Failed"
        ;;
      *)
        status="Unknown"
        ;;
    esac
  fi

  echo "PID: $pid"
  echo "Service Status: $status"
}

# Get the number of packages to display (default is number packages in '/var/log/dpkg.log')
num_packages="${1:-10}"

# If the input is "all", fetch all packages
if [ "$num_packages" == "all" ]; then
  num_packages=$(grep " install " /var/log/dpkg.log | wc -l) # Get total number of installed packages
else
  # Ensure the input is a number
  if ! [[ "$num_packages" =~ ^[0-9]+$ ]]; then
    echo "Error: không hợp lệ. Vui lòng nhập một số hoặc 'all'."
    exit 1
  fi
fi

# Get list of recently installed packages
recent_packages=$(grep " install " /var/log/dpkg.log | tail -n "$num_packages" | awk '{print $4}' | sort -u)

echo "Information about recently installed packages:"

# Get detailed information for each package
for package in $recent_packages; do
  # Get information from dpkg
  details=$(dpkg-query -s "$package" 2>/dev/null)
  if [ $? -eq 0 ]; then
    # Extract necessary information
    name=$(echo "$details" | grep '^Package:' | awk '{print $2}')
    version=$(echo "$details" | grep '^Version:' | awk '{print $2}')
    arch=$(echo "$details" | grep '^Architecture:' | awk '{print $2}')
    description=$(echo "$details" | grep '^Description:' | cut -d ':' -f2- | xargs)

    # Get service status and PID
    service_status=$(get_service_status "$name")

    # Print information
    echo "Package Name: $name"
    echo "Version: $version"
    echo "Architecture: $arch"
    echo "Description: $description"
    echo "$service_status"
    echo
  else
    echo "Error: Không thể tìm thấy thông tin về: $package"
  fi
done
