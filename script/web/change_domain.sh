#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Vui lòng chạy script với quyền root."
  exit 1
fi

# Kiểm tra số lượng tham số đầu vào
if [ "$#" -ne 2 ]; then
  echo "Sử dụng: $0 old_domain new_domain"
  echo "Ví dụ: $0 example.com newexample.com"
  exit 1
fi

OLD_DOMAIN=$1
NEW_DOMAIN=$2

# Tạo backup trước khi thay đổi
backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Hàm khôi phục từ backup
restore_from_backup() {
  echo "Đang khôi phục từ backup..."
  find "$backup_dir" -type f | while IFS= read -r backup_file; do
    original_file="${backup_file#$backup_dir/}"
    if [ -f "$original_file" ]; then
      cp "$backup_file" "$original_file"
      echo "Đã khôi phục: $original_file"
    fi
  done
  echo "Khôi phục hoàn tất"
}

# Bẫy lỗi để khôi phục khi có lỗi
trap 'echo "Error: Đã phát hiện lỗi"; restore_from_backup; exit 1' ERR INT TERM

# Biến đếm số file được thay đổi
changed_files=0

# Tìm và thay thế trong tất cả các file văn bản (loại trừ file nhị phân)
find . -type f -not -path "./$backup_dir/*" -not -path "./.git/*" | while IFS= read -r file; do
  if grep -Iq "$OLD_DOMAIN" "$file"; then
    # Tạo backup của file
    backup_path="$backup_dir/$file"
    mkdir -p "$(dirname "$backup_path")"
    cp "$file" "$backup_path"

    # Thay thế domain
    if sed -i "s/$OLD_DOMAIN/$NEW_DOMAIN/g" "$file"; then
      echo "Đã xử lý file: $file"
      ((changed_files++))
    else
      echo "Error: Lỗi khi xử lý file: $file"
      restore_from_backup
      exit 1
    fi
  fi
done

# Kiểm tra xem có file nào được thay đổi không
if [ $changed_files -eq 0 ]; then
  echo "Error: Không tìm thấy file nào chứa domain $OLD_DOMAIN"
  restore_from_backup
  exit 1
fi

# Hiển thị kết quả
echo "Đã thay đổi thành công $changed_files file"
echo "Danh sách các file đã được thay đổi:"
find . -type f -not -path "./$backup_dir/*" -not -path "./.git/*" -exec grep -l "$NEW_DOMAIN" {} \;

echo "Đã tạo backup tại thư mục: $backup_dir"
echo "Hoàn thành thay đổi domain từ $OLD_DOMAIN sang $NEW_DOMAIN"
