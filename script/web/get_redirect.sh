#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra tham số đầu vào
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <domain_or_path>"
  exit 1
fi

domain=$1

# Function to check redirects
check_redirects() {
  local url=$1
  local max_redirects=10
  local redirect_count=0
  local has_redirects=false

  while [ $redirect_count -lt $max_redirects ]; do
    # Fetch headers
    headers=$(curl -sI "$url")

    # Get HTTP status code
    status_code=$(echo "$headers" | grep -oP '^HTTP/\d\.\d\s+\K\d+')

    # Check for Location header (redirect)
    location=$(echo "$headers" | grep -i "^Location:" | awk '{print $2}' | tr -d '\r')

    if [[ -n $location ]]; then
      if [ "$redirect_count" -eq 0 ]; then
        echo "Redirect rules:"
      fi
      echo "$url -> $location (HTTP $status_code)"

      # Update URL to follow the redirect
      url=$location
      ((redirect_count++))
      has_redirects=true
    else
      # No more redirects
      if [ "$status_code" == "301" ]; then
        echo "$url (HTTP 301): Permanent redirect nhưng không có Location header."
      fi
      break
    fi
  done

  if [ "$has_redirects" = false ]; then
    echo "Không tìm thấy redirect nào."
  fi

  if [ $redirect_count -eq $max_redirects ]; then
    echo "Maximum number of redirects ($max_redirects) reached."
  fi
}

# Main execution
echo "Checking redirect rules for $domain"

# Check both http and https
check_redirects "http://$domain"
check_redirects "https://$domain"
