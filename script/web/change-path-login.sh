#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy với quyền root."
  exit 1
fi

# Kiểm tra tham số
if [ "$#" -lt 1 ]; then
  echo "Cách dùng: $0 <domain1> [domain2] [domain3] ..."
  echo "Ví dụ: $0 abc.com xyz.net"
  exit 1
fi

DOMAINS=("$@")

REWRITE_DIR="/etc/nginx/rewrite"

for DOMAIN in "${DOMAINS[@]}"; do
  REWRITE_FILE="$REWRITE_DIR/$DOMAIN.conf"

  if [ ! -f "$REWRITE_FILE" ]; then
    echo "Không tìm thấy file rewrite cho domain: $DOMAIN ($REWRITE_FILE)"
    continue
  fi

  echo "Đang xử lý domain: $DOMAIN"

  # Tạo slug gọn: bỏ đuôi .com, .net, .org, .vn, .info, .co.uk...
  MAIN_PART=$(echo "$DOMAIN" | awk -F. '{print $1}')
  SLUG="$MAIN_PART"

  echo "Slug mới sẽ là: /$SLUG"

  # Kiểm tra đã có cấu hình chưa
  if grep -q "rewrite ^/$SLUG" "$REWRITE_FILE"; then
    echo "Đã có cấu hình rewrite slug /$SLUG rồi, bỏ qua."
    continue
  fi

  # Ghi thêm vào cuối file rewrite
  cat >> "$REWRITE_FILE" <<EOF

# Rewrite wp-login.php bảo mật
location = /$SLUG {
    rewrite ^/$SLUG\$ /wp-login.php break;
}
location = /wp-login.php {
    deny all;
}
EOF

  echo "Đã thêm rewrite mới vào: $REWRITE_FILE"

done

# Kiểm tra và reload nginx
echo "🛠 Kiểm tra cấu hình nginx..."
if nginx -t; then
  echo "Reload nginx..."
  systemctl reload nginx
  echo "Cập nhật thành công cho các domain!"
else
  echo "Lỗi cấu hình nginx, vui lòng kiểm tra!"
fi
