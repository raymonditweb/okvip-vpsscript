#!/bin/bash

ACTION=$1 # enable hoặc disable

if [[ "$ACTION" != "enable" && "$ACTION" != "disable" ]]; then
    echo "Usage: $0 [enable|disable]"
    exit 1
fi

echo "$ACTION auto-update cho tất cả plugins..."
wp plugin list --field=name | xargs -n1 wp plugin auto-updates "$ACTION"

