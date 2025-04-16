#!/bin/bash

# Kiểm tra số lượng tham số
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 plugin-slug domain1 domain2 ... domainN"
  exit 1
fi

# Lấy plugin slug từ tham số đầu tiên
PLUGIN="$1"

# Lấy danh sách domain (trừ plugin slug)
DOMAINS=("${@:2}")

# Kiểm tra WP-CLI
if ! command -v wp >/dev/null 2>&1; then
  echo "WP-CLI not found. Installing via apt..."

  apt update
  apt install -y wp-cli

  # Kiểm tra lại sau khi cài
  if ! command -v wp >/dev/null 2>&1; then
    echo "Error: WP-CLI installation failed. Please install manually."
    exit 1
  fi

  echo "WP-CLI installed successfully via apt."
fi


# Lặp qua từng domain
for DOMAIN in "${DOMAINS[@]}"; do
  SITE_PATH="/var/www/$DOMAIN"
  echo "Installing plugin '$PLUGIN' for domain $DOMAIN "

  if [ ! -f "$SITE_PATH/wp-config.php" ]; then
    echo "Skipped: wp-config.php not found in $SITE_PATH"
    continue
  fi

  # Cài plugin và kích hoạt
  wp plugin install "$PLUGIN" --activate --allow-root --path="$SITE_PATH" --quiet
  if [ $? -eq 0 ]; then
    echo "Installed '$PLUGIN' on $DOMAIN success"
  else
    echo "Error: Failed to install '$PLUGIN' on $DOMAIN"
  fi
done
# Tải lại Nginx
nginx -t
systemctl reload nginx
