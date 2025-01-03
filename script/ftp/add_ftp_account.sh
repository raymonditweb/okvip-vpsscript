#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Kiểm tra và cài đặt expect nếu chưa có
if ! command -v expect &>/dev/null; then
  echo "Expect chưa được cài đặt. Đang tiến hành cài đặt..."
  if [ -x "$(command -v apt-get)" ]; then
    apt-get update && apt-get install -y expect # Trên Ubuntu/Debian
  elif [ -x "$(command -v yum)" ]; then
    yum install -y expect # Trên CentOS/RHEL
  else
    echo "Error: Không thể xác định trình quản lý gói để cài đặt expect."
    exit 1
  fi
fi

# Kiểm tra và cài đặt Pure-FTPd nếu chưa có
if ! command -v pure-pw &>/dev/null; then
  echo "Pure-FTPd chưa được cài đặt. Đang tiến hành cài đặt..."
  if [ -x "$(command -v apt-get)" ]; then
    apt-get update && apt-get install -y pure-ftpd
  elif [ -x "$(command -v yum)" ]; then
    yum install -y pure-ftpd
  else
    echo "Error: Không thể xác định trình quản lý gói để cài đặt Pure-FTPd."
    exit 1
  fi
fi

# Đường dẫn tới tệp chứa danh sách tài khoản FTP
FTP_USER_FILE="/etc/ftp_users.txt"
DEFAULT_USERNAME="default_user"
DEFAULT_PASSWORD="default_password"
FTP_HOME="/home/ftp_users"
FTP_SHELL="/sbin/nologin"

# Đảm bảo shell tồn tại trong /etc/shells
if ! grep -q "^$FTP_SHELL$" /etc/shells; then
  echo "Thêm $FTP_SHELL vào /etc/shells..."
  echo "$FTP_SHELL" >>/etc/shells
fi

# Hàm để thêm tài khoản FTP
add_account() {
  local username="${1:-$DEFAULT_USERNAME}"
  local password="${2:-$DEFAULT_PASSWORD}"
  local directory="${3:-$FTP_HOME/$username}"

  # Đảm bảo đường dẫn là tuyệt đối
  if [[ "$directory" != /* ]]; then
    directory="/$directory"
  fi

  # Kiểm tra xem tài khoản đã tồn tại chưa
  if grep -q "^$username:" "$FTP_USER_FILE"; then
    echo "Error: Tài khoản $username đã tồn tại."
    return 1
  fi

  # Tạo tài khoản hệ thống và thiết lập thư mục FTP riêng
  if ! useradd -m -d "$directory" -s "$FTP_SHELL" "$username"; then
    echo "Error: Không thể tạo tài khoản hệ thống $username."
    return 1
  fi

  # Tự động nhập mật khẩu cho lệnh chpasswd
  if ! echo "$username:$password" | chpasswd; then
    echo "Error: Không thể đặt mật khẩu cho tài khoản $username."
    return 1
  fi

  # Thêm tài khoản vào tệp theo dõi tài khoản FTP
  echo "$username:$password" >>"$FTP_USER_FILE"

  # Thiết lập quyền thư mục
  mkdir -p "$directory"
  chown "$username:$username" "$directory"
  chmod 755 "$directory"

  # Tạo tài khoản FTP trong cơ sở dữ liệu Pure-FTPd bằng expect
  uid=$(id -u "$username")
  gid=$(id -g "$username")

  expect -c "
  spawn pure-pw useradd $username -u $uid -g $gid -d $directory
  expect \"Password:\"
  send \"$password\r\"
  expect \"Repeat password:\"
  send \"$password\r\"
  expect eof
  " || {
    echo "Error: Không thể thêm tài khoản FTP $username vào Pure-FTPd."
    return 1
  }

  # Cập nhật cơ sở dữ liệu của Pure-FTPd
  pure-pw mkdb || {
    echo "Error: Không thể cập nhật cơ sở dữ liệu của Pure-FTPd."
    return 1
  }

  # Kích hoạt tài khoản FTP
  echo "Tài khoản FTP $username đã được thêm thành công với đầy đủ quyền."
}

# Gọi hàm thêm tài khoản với tham số từ dòng lệnh
add_account "$1" "$2" "$3"
