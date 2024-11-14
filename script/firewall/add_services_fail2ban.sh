#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Check if fail2ban is installed
if ! command -v fail2ban-client &> /dev/null; then
  echo "Error: fail2ban is not installed"
  exit 1
fi

# Check if fail2ban service is running
if ! systemctl is-active --quiet fail2ban; then
  echo "Error: fail2ban service is not running"
  exit 1
fi

# Get service name from command line argument
service_name="$1"

# Check if service name is provided
if [ -z "$service_name" ]; then
  echo "Error: Service name not provided"
  exit 1
fi

# Create new jail configuration
jail_config="/etc/fail2ban/jail.d/${service_name}.conf"

# Check if the config file already exists to avoid overwriting
if [ -f "$jail_config" ]; then
  echo "Error: Jail configuration for '$service_name' already exists."
  exit 1
fi

# Create the jail configuration
cat << EOF | sudo tee "$jail_config" > /dev/null
[${service_name}]
enabled = true
port = 0
filter = ${service_name}
logpath = /var/log/${service_name}/${service_name}.log
maxretry = 5
bantime = 600
EOF

# Create filter configuration
filter_config="/etc/fail2ban/filter.d/${service_name}.conf"

# Check if the filter already exists to avoid overwriting
if [ -f "$filter_config" ]; then
  echo "Error: Filter configuration for '$service_name' already exists."
  exit 1
fi

# Create the filter configuration
cat << EOF | sudo tee "$filter_config" > /dev/null
[INCLUDES]
before = common.conf

[Definition]
failregex = ^%(__prefix_line)s<HOST> - (.*)
ignoreregex =
EOF

# Restart fail2ban to apply changes
if sudo systemctl restart fail2ban; then
  echo "New service '$service_name' added to fail2ban successfully!"
else
  echo "Error: Failed to restart fail2ban"
fi
