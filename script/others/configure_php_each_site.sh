#!/bin/bash

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Error: Cách dùng: $0 domain php_version root_directory"
  echo "Ví dụ: $0 example.com 8.1 /var/www/example.com"
  exit 1
fi

# Assign arguments to variables
DOMAIN=$1
PHP_VERSION=$2
ROOT_DIR=$3

# Validate PHP version format
if ! [[ $PHP_VERSION =~ ^[5-9]\.[0-9]+$ ]]; then
  echo "Error: Sai PHP version format. Dùng 7.4, 8.1, etc."
  exit 1
fi

# Check if root directory exists
if [ ! -d "$ROOT_DIR" ]; then
  echo "Error: Root directory $ROOT_DIR không tồn tại."
  exit 1
fi

CONFIG_FILE="/etc/nginx/conf.d/${DOMAIN}.conf"
TEMP_FILE=$(mktemp)

update_php_config() {
  local config_file=$1
  local temp_file=$2
  local new_php_version=$3
  local new_root_dir=$4

  # Read the existing config file line by line
  while IFS= read -r line; do
    # Update PHP-FPM socket path
    if [[ $line =~ fastcgi_pass.*php.*-fpm\.sock ]]; then
      echo "        fastcgi_pass unix:/var/run/php/php${new_php_version}-fpm.sock;"
    # Update root directory if specified in arguments
    elif [[ $line =~ ^[[:space:]]*root ]]; then
      echo "    root ${new_root_dir};"
    # Keep all other lines unchanged
    else
      echo "$line"
    fi
  done <"$config_file" >"$temp_file"
}

if [ -f "$CONFIG_FILE" ]; then
  echo "Tìm thấy configuration ${DOMAIN}"

  # Create backup
  BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$CONFIG_FILE" "$BACKUP_FILE"
  echo "Backup vào: $BACKUP_FILE"

  # Extract current PHP version and root directory
  CURRENT_PHP=$(grep -oP "php\K[0-9]+\.[0-9]+" "$CONFIG_FILE" | head -1)
  CURRENT_ROOT=$(grep -oP "root \K[^;]+" "$CONFIG_FILE")

  echo "Configuration hiện tại:"
  echo "- PHP Version: $CURRENT_PHP"
  echo "- Root Directory: $CURRENT_ROOT"

  # Update configuration while preserving custom settings
  update_php_config "$CONFIG_FILE" "$TEMP_FILE" "$PHP_VERSION" "$ROOT_DIR"

else
  # Create new configuration file if it doesn't exist
  cat >"$TEMP_FILE" <<EOF
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    root ${ROOT_DIR};
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
fi

# Check if PHP-FPM is installed
if ! systemctl status php${PHP_VERSION}-fpm &>/dev/null; then
  echo "Warning: PHP-FPM ${PHP_VERSION} chưa được cài."
  echo "Run: apt install php${PHP_VERSION}-fpm"
  rm "$TEMP_FILE"
  exit 1
fi

# Apply new configuration
mv "$TEMP_FILE" "$CONFIG_FILE"
chmod 644 "$CONFIG_FILE"

# Test Nginx configuration
nginx -t

if [ $? -eq 0 ]; then
  systemctl restart nginx
  echo "Hoàn tất Config cho ${DOMAIN} với PHP ${PHP_VERSION}"
  echo "Website root directory: ${ROOT_DIR}"

  if [ -f "$BACKUP_FILE" ]; then
    echo -e "\nThay đổi cho:"
    diff "$BACKUP_FILE" "$CONFIG_FILE"
  fi
else
  if [ -f "$BACKUP_FILE" ]; then
    mv "$BACKUP_FILE" "$CONFIG_FILE"
    echo "Error: Nginx configuration test failed. Restored previous configuration."
  else
    echo "Error: Nginx configuration test failed"
  fi
  exit 1
fi
