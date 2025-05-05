# OKVIP - VPSSCRIPT Documentation

OKVIP - VPSSCRIPT là nền tang để quản lý và cài đặt website wordpress trên Ubuntu 20.04
[OKVIP - VPSSCRIPT is a management and installation framework for WordPress websites on Ubuntu 20.04]

## 1. Quản lý Máy Chủ (Server/VPS) - Server/VPS Management

### Cài đặt LEMP - LEMP Installation

For Ubuntu 20.04:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/install-ubuntu-lemp-20.04 ) <mysql_root_password> <init_main_domain.com>
```

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/install-ubuntu-lemp-20.04 ) okvip@P@ssw0rd2024`

### Go Cài đặt LEMP - LEMP Uninstallation

For Ubuntu 20.04:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/remove-ubuntu-lemp-20.04 )
```

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/remove-ubuntu-lemp-20.04 )`

### Check VPS status

For Ubuntu 20.04:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/status_vps.sh )
```

### System Management Commands

#### Lệnh Cài Đặt yum-cron - Auto Update System

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/yum-cron-setup )
```

#### VPS Restart

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/restart-vps )
```

### Quản lý file - File Management

#### List Files & Folders

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/file/list-files.sh ) </path/to/file_or_folder*>
```

#### Set File/Folder Permissions

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/file/set-chmod ) <mod*> </path/to/file_or_folder*>
```

### System Monitoring

#### VPS Monitoring

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/vpsscript/vps_monitoring.sh ) <today|yesterday|7day|30day|range start_date end_date*>
```

`ví dụ:
thong tin cho today/yesterday/7day/30day truyen tham so tuong ung:
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/vpsscript/vps_monitoring.sh ) today`
`thong tin cho range date start_date va end_date: bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/vpsscript/vps_monitoring.sh ) range "2024-11-01" "2024-11-25"`

- Kết quả trả về:
  - Không có root : Error: Vui lòng chạy script với quyền root.
  - Thành công: In ra các thông số đã thu thập được sau mỗi sample. Hoàn Tất
  - Không đung tham số: Error: Sử dụng tham so: {today|yesterday|7day|30day|range start_date end_date}
  - Thất bại: Error: Không thể lấy dữ liệu CPU./Error: Không thể lấy dữ liệu Memory usage.

#### Theo dõi thông số server - Memory Information

```bash
free -h
```

#### Thông tin ổ cứng - Disk Usage

```bash
df -h
```

#### Thông tin INODE - INODE Usage

```bash
df -i
```

#### Danh sách process- Process Management

Top CPU Usage:

```bash
ps aux --sort=-%cpu | head -n 10
```

Danh sách sử dụng dung lượng RAM - Top Memory Usage:

```bash
ps aux --sort=-%mem | head -n 10
```

Network Load:

```bash
iftop -n
```

### Application Management

#### Kiểm tra đã cài đặt chưa, trả về 0 hoặc 1 - Check Application Installation

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/application/check-app ) <app_name*>
```

#### Cài đặt ứng dụng mới - Install Application

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/application/install-app ) <app_name*> <app_type=[app|service]> <app_version=lastest>
```

#### Remove Application

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/application/remove-app ) <app_name*>
```

#### Start/Stop/Reload ứng dụng - Control Applications

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/application/[start/stop/reload]-app ) <app_name*>
```

### Quản lý logs - Log Management

Mở file log để đọc, log được lưu trong /var/log, sử dụng lên cat để đọc

```bash
cat [file_log]
```

- Danh sách file logs: nằm trong /var/log/
  /var/log/syslog: Log hệ thống chính, chứa log từ nhiều dịch vụ và hoạt động hệ thống.
  /var/log/auth.log: Log về việc đăng nhập và xác thực.
  /var/log/dmesg: Log của kernel, ghi lại thông tin phần cứng và các thiết bị.
  /var/log/boot.log: Log quá trình khởi động hệ thống.
  /var/log/nginx/error.log: Log lỗi của Nginx.
  /var/log/mysql/error.log: Log lỗi của MySQL.
  /var/log/apache2/error.log: Log lỗi của Apache (nếu cài đặt).
  /var/log/php7.4-fpm.log: Log của PHP-FPM (nếu đang sử dụng PHP).

### Thay đổi PHP version - Change PHP version

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/change_php_version.sh) [PHPVersion]
```

`ví dụ: bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/change_php_version.sh) 7.0`

- Kết quả trả về:
  - Không có root : Error: Vui lòng chạy script với quyền root.
  - Thành công: Thay đổi PHP sang $PHP_VERSION hoàn tất!
  - Nếu PHP đã tồn tại: PHP $PHP_VERSION đã có sẵn trên hệ thống.
  - Không đủ tham số: Error: Sử dụng: phiên_bản_php (ví dụ: 7.4/ 8.1)
  - Thất bại: Error: Không thể cài đặt PHP $PHP_VERSION. Vui lòng kiểm tra lại.

### Cấu hình PHP version cho từng website - Configure PHP version for each website

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/configure_php_each_site.sh) <domain*> <php_version*> <root_directory*>
```

`Vi du: bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/configure_php_each_site.sh) example.com 8.1 /var/www/example.com`

### Cấu hình php.ini - Configure php.ini

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/configure_php_ini.sh) <domain*> <property1:value1*> <property2:value2*>...
```

`Vi du: bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/configure_php_ini.sh) example.com memory_limit:512M upload_max_filesize:50M post_max_size:50M`

#### Install Rclone for sync backup to gdrive

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/install_rclone_gdrive.sh )
```

`Cach dung Rclone tao link authen: https://docs.google.com/document/d/1LRuq7TwaSb1Nx4X6mYsQyAnIzi65SM8dfy7deWpO0To/edit?tab=t.0#heading=h.2mmclmb880qr`

#### Backup VPS: Backup to google driver

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/sync_backup_to_ggdrive.sh ) BACKUP_DIR REMOTE_NAME REMOTE_DIR START_TIME BACKUP_INTERVAL_DAYS
```

`ví dụ: bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/sync_backup_to_ggdrive.sh ) "/path/to/backup_dir" "gdrive" "backup_folder_on_drive" "03:00" 7`

/path/to/backup_dir: Đường dẫn tới thư mục cần đồng bộ.
"gdrive": Neu Không cung cấp tên remote, script sẽ mặc định sử dụng gdrive.
backup_folder_on_drive: Tên thư mục trên Google Drive.
03:00: Thời gian bắt đầu đồng bộ (định dạng HH:MM).
7: Tần suất đồng bộ (số ngày).

### Cron Job Management

#### List Cron Jobs

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/list.sh )
```

#### Add Cron Job

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/add.sh ) <"* * * * * exec-command"*>
```

#### Delete Cron Job

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/remove.sh ) <"* * * * * exec-command"*>
```

#### Enable/Disable Cron Job

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/manage_cron.sh ) <enable|disable> <"* * * * * exec-command"*>
```

`Vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/manage_cron.sh ) enable "0 2 * * * /path/to/script.sh"`

- Kết quả trả về:
  - Khong có quyền root: Error: Vui lòng chạy script với quyền root.
  - Sai Tham Số: Error: `Sử dụng: $0 <enable|disable> '<cron_job> / Ví dụ: $0 enable '0 2 * * * /path/to/script.sh`
  - Cron tồn tại và đang được bật: Error: Cron job đã được bật trước đó.
  - Cron tồn tại và đang tat: Error: Cron job không tồn tại hoặc đã bị tắt trước đó.
  - Nếu không tìm thấy cron job, sẽ thông báo lỗi: Error: Hành động không hợp lệ. Sử dụng 'enable' hoặc 'disable'.
  - Thanh cong: Cập nhật cron hoàn tất!

#### Excute Cron Job

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/excute.sh ) <"* * * * * exec-command"*>
```

`Vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/excute.sh ) "0 2 * * * /path/to/script.sh"`

- Kết quả trả về:
  - Khong có quyền root: Error: Vui lòng chạy script với quyền root.
  - Sai Tham Số: Error: `Sử dụng: $0 '<cron_job> / Ví dụ: $0 '0 2 * * * /path/to/script.sh`
  - Nếu không tìm thấy cron job: "Error: Cronjob khong ton tai: $CRONJOB_COMMAND. Khong the thuc thi!
  - Thanh cong: Executing cronjob: $CRONJOB_COMMAND

### Security Management

### Firewall Rules

#### List firewall rules

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/list.sh )
```

#### Add new port

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/add.sh ) <port*> [tcp|udp]
```

#### Remove port

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/remove.sh ) <port*> <tcp|udp*>
```

#### List blocked IPs

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/list_blocked_ips.sh )
```

### Other Security Features

#### Liệt kê danh sách fail2ban - List fail2ban status

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/get_list_fail2ban.sh )
```

#### Re-insatall Fail2ban after break down

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/reinstall_fail2ban.sh )
```

- Kết quả trả về:
  - Không có root : Error: Vui lòng chạy script với quyền root.
  - Thành công: Fail2Ban đã được cài đặt lại và khởi động thành công.

#### Thêm service vào giám sát Fail2Ban - Add service to Fail2Ban

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/add_services_fail2ban.sh ) [SERVICE_NAME]
```

- Kết quả trả về:
  - Không có root : Error: Vui lòng chạy script với quyền root.
  - Thành công: Dịch vụ SERVICE_NAME đã được thêm vào danh sách giám sát của Fail2Ban.
  - Thiếu tham số: Error: Sử dụng: [tên_dịch_vụ]
  - Service không đang chạy: Error: Dịch vụ SERVICE_NAME không đang chạy. Không thể thêm vào Fail2Ban.
  - Đã tồn tại: Error: Dịch vụ SERVICE_NAME đã tồn tại trong JAIL_LOCAL_FILE

#### Thêm Địa chỉ IP vào Danh sách Whitelist của Fail2ban - Add IP to ignorelist

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/add_ip_whitelist.sh) [IP1] [IP2]
```

- Kết quả trả về:
  - Không có root : Error: Vui lòng chạy script với quyền root.
  - Thành công: Các thay đổi đã được áp dụng thành công!
  - Nếu IP đã tồn tại: Error: Địa chỉ IP $ip đã có trong whitelist..
  - Không đủ tham số:
    Error: Sử dụng Cú pháp: [ip1] [ip2] ...
    Ví dụ: [192.168.1.10] [192.168.1.20]

#### Change SSH port

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/change-ssh-port.sh ) <new_ssh_port*>
```

#### Limit ssh login

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/limit_ssh_login.sh ) <MAX_FAILED_ATTEMPTS*> <BLOCK_TIME*>
```

`Vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/limit_ssh_login.sh ) 3 300`

Giải thích:
Cho phép tối đa 3 lần đăng nhập sai trước khi khóa.
Khóa sẽ kéo dài 300 giây (5 phút).

- Kết quả trả về:
  ++ Đúng tham số: Đã thiết lập giới hạn đăng nhập SSH thất bại: 3 lần trong 300 giây.
  Cấu hình iptables đã được lưu.
  Cấu hình SSH đã được cập nhật và SSH đã được khởi động lại.
  ++ Không đủ tham số: Error: Sử dụng: <MAX_FAILED_ATTEMPTS> <BLOCK_TIME>Ví dụ: $0 3 300 (giới hạn 3 lần đăng nhập sai, khóa trong 300 giây)
  ++ Thanh cong: Cấu hình SSH đã được cập nhật và SSH đã được khởi động lại.
  ++ That bai: Đã thiết lập giới hạn đăng nhập SSH thất bại/

#### Change root password

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/change-password.sh ) <'new_password'*>
```

Nhập mật khẩu mới trong cặp dấu nháy đơn, ví dụ: 'cC,2K%5kSkj!yKqtu'

## 2. Website Management

### Website Operations

#### Login 1 lần - One time login

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/otl/one_time_login.sh ) <DOMAIN*> <WP_USERNAME*> <WP_PASSWORD*>
```

#### List Websites

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/list-websites) <directory*>
```

- <directory\*> có thể co hoăc khong
  Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/list-websites) /var/www/
```

#### Change domain

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/change_domain.sh) <old_domain*> <new_domain*> <mysql_root_password*>
```

#### Cài đặt website WordPress tự động theo template

- Add domain
- Tạo database
- SSL
- Download mẫu
- Cấu hình config

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/install-wordpress) <mysql_root_password*> <domain*> <template_url*> <db_username*> <db_password*> <admin_username*> <admin_password*>
```

#### Check SSL domains

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/check_ssl_domains.sh )
```

#### SSL new / re-newal

Nếu SSL chưa có thì tạo mới SSL, nếu đã có thì làm mới SSL. Kiểm tra, nếu có proxy thì báo Error: Không thể đăng kí SSL vì proxy. Vui lòng tắt proxy để đăng kí SSL.

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/ssl_renewal.sh) <domain/ip*>
```

vi du:

- voi Domain:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/ssl_renewal.sh) example.com
```

- voi IP:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/ssl_renewal.sh) 192.168.1.1
```

#### Thêm addon domain

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/addon-domain.sh) <primary-domain*> <addon-domain1*> <addon-domain2*> <addon-domain3*> ...
```

Cung cấp primary-domain và ít nhất 1 addon-domain để thêm vào addon domain, có thể thêm nhiều addon khác nhau

#### Lấy danh sách alias domain

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/get-alias-domain.sh) <domain*>
```

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/get-alias-domain.sh ) example.com`

- Giải thích các tham số:
  domain: Tên miền (ví dụ: domain.com) hoac path: Đường dẫn (ví dụ: /path/\*)

#### Xoá website: yêu cầu có mysql root password để remove db - Remove Website

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/remove-website) <domain*> <mysql_root_password*>
```

#### Tiện ích: Bật / Tắt 1 hoặc nhiều website - Enable/Disable Website

##### Enable

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/enable-website) <domain*>
```

##### Disable

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/disable-website) <domain*>
```

#### Cấu hình redirect (301, 302) - Redirect configuration (301, 302, etc.)

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/setup_redirect.sh ) <domain/path> <redirect-type> <target>
```

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/setup_redirect.sh ) example.com 301 http://b1.com`

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/setup_redirect.sh ) example.com 302 http://b2.com`

- Giải thích các tham số:
  domain: Tên miền (ví dụ: domain.com) hoac path: Đường dẫn (ví dụ: /path/\*)
  redirect-type: Loại redirect (có thể là 301, 302)
  target: URL đích tới (ví dụ: https://domain-dich.com)

#### Cấu hình redirect nhiều domains(301) - Redirect configuration for multiple domains (301)

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/multiple_redirects.sh ) <main-domain*> <domain1.com*> <domain2.com*> <domain3.com*> <https://targeturl.com*>
```

#### Xoá redirect

````bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/remove-redirect.sh) <domain/path> <redirect-type> <target>

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/remove-redirect.sh ) example.com 301 http://b1.com`

#### Change redirect
```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/change-redirect.sh) <domain/path> <redirect-type> <target> <new_target>

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/change-redirect.sh ) example.com 301 http://b1.com http://b2.com`

#### Lấy thông tin cấu hình redirect (301, 302) - Redirect configuration Information (301, 302, etc.)

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/get_redirect.sh ) <domain/path>
````

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/get_redirect.sh ) example.com`

- Giải thích các tham số:
  domain: Tên miền (ví dụ: domain.com) hoac path: Đường dẫn (ví dụ: /path/\*)

#### Cấu hình Wordpress URL rewrite - Configuration for Wordpress URL rewrite

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/wordpress_nginx_rewrite.sh ) <domain*> <extra_config*>
```

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/wordpress_nginx_rewrite.sh ) example.com "location /custom { return 200 'Hello'; }"`

#### Export DB

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/export_db.sh ) [domain]
```

`vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/export_db.sh ) example.com`

- Kết quả trả về:
  - Không có root : Error: Vui lòng chạy script với quyền root.
  - Khi thiếu tham số: Error: Vui lòng truyền tham số: [tên_domain]. Ví dụ đúng: example.com
  - Thành công: Export database example_com thành công! File: backup_example_com.sql
  - Thất bại: Error: Có lỗi khi xuất dữ liệu từ database example_com. / Vui lòng kiểm tra thông tin kết nối hoặc database có tồn tại không.
  - Khi file wp-config.php không tồn tại: Error: Không tìm thấy file wp-config.php tại /var/www/example.com/wp-config.php.
  - Khi không lấy được thông tin kết nối MySQL từ wp-config.php: Error: Không thể lấy thông tin kết nối từ /var/www/example.com/wp-config.php.

#### Thay đổi site directory - Change website directory

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/change_site_directory.sh) [SITE_NAME] [new_directory]
```

- Kết quả trả về:
  - Không có root : Error: Vui lòng chạy script với quyền root.
  - Thành công: Thành công! Thư mục của site 'SITE_NAME' đã được thay đổi thành: NEW_DIRECTORY
  - Thiếu tham số: Error: Sử dụng cú pháp: [SITE_NAME] [new_directory]
    Ví dụ: example.com /var/www/example_new
  - Cấu hình không tồn tại: Error: Cấu hình Nginx cho site '$SITE_NAME' không tồn tại.
  - Thất bại: Error: Cú pháp cấu hình Nginx không hợp lệ, không thể áp dụng thay đổi.

#### Backup website

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/setup_backup.sh) DOMAIN BACKUP_DIR BACKUP_TIME BACKUP_INTERVAL_DAYS
```

`Vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/setup_backup.sh) example.com /path/to/backup 03:00 2
`

`- Tạo một backup vào 3 giờ sáng mỗi 2 ngày.`

Lưu ý:
BACKUP_TIME: là tham số có thể truyền dạng 24h như 01:00 / 02:00 / 23:30
BACKUP_INTERVAL_DAYS là tham số so ngay: 1 / 2 /

#### Restore website

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/restore_backup.sh <file_backup> <thư_mục_khôi_phục>
```

vi du:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/restore_backup.sh /backup/domain_14062024120000.zip /var/www/domain.com
```

## 3. WordPress Maintenance

### Cập nhật plugin and Wordpress core- Update WordPress Core and Plugins

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/vpsscript/menu/tienich/update-wordpress-for-all-site )
```

### Scan WordPress Malware

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/vpsscript/menu/tienich/scan-wordpress-malware.sh )
```

## 4. Database Management

### Database Operations

#### Liệt kê danh sách database - List databases

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/list-db ) <mysql_root_password*>
```

`vi du:
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/list-db ) okvip@P@ssw0rd2024
`

#### Thêm database và userdb tương ứng mới (userdb = dbname) - Add database

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/add-db ) <mysql_root_password*> <db_name*> <db_user_password*>
```

#### Rename database

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/rename-db ) <mysql_root_password*> <old_db_name*> <new_db_name*>
```

#### Delete database

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/delete-db ) <mysql_root_password*> <db_name*>
```

`vi du:
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/delete-db ) okvip@P@ssw0rd2024 test_db
`

## 5. User Operations

### List users

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/list-users ) <mysql_root_password*>
```

#### Thêm db user & assign db - Add user

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/add-user ) <mysql_root_password*> <user_name*> <user_password*> [db_name]
```

- nếu không truyền vào db_name thì chỉ tạo user

#### Đổi tên người dùng

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/rename-user ) <mysql_root_password*> <old_user_name*> <new_user_name*>
```

#### Đổi mật khẩu người dùng - Change user password

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/change-user-password ) <mysql_root_password*> <user_name*> <new_password*>
```

#### Delete user

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/delete-user ) <mysql_root_password*> <user_name*>
```

## 6. FTP Management

### Quản lý Network

#### Lấy thông tin network/load

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/network/get_network_and_load.sh )
```

### Quản lý application / services

#### Lấy danh sách package đã cài gần đây

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/package/get_recently_installed_packages.sh ) <all|number>
```

`Vi du: Lay tat ca: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/package/get_recently_installed_packages.sh ) all`

`vi du: Lay 20 items: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/package/get_recently_installed_packages.sh ) 20`

- Kết quả trả về:
  - Không có root : Error: Vui lòng chạy script với quyền root.
  - Thành công: List thoong tin packages.
  - Thất bại: Error: Không thể tìm thấy thông tin về: $package.
  - Tham số sai: Error: không hợp lệ. Vui lòng nhập một số hoặc 'all'.

#### Install Pure-FTPd

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/install_pureftpd.sh )
```

- Kết quả trả về:
  - Thành công: Pure-FTPd đã được cài đặt thành công.
  - Nếu Pure-FTPd đã được cài đặt: Error: Pure-FTPd đã được cài đặt.

### FTP Account Management

#### Danh sách FTP Account - List accounts

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/list_ftp_accounts.sh )
```

- Kết quả trả về:
  - Nếu có tài khoản FTP: List tài khoản FTP:
    [user1]:[password1]
    [user2]:[password2]
  - Nếu không có tài khoản FTP: No result

#### Thêm FTP Account - Add account

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/add_ftp_account.sh ) [username] [password] [domain]
```

- Kết quả trả về:
  - Thành công: Tài khoản FTP [username] đã được thêm thành công với đầy đủ quyền.
  - Nếu tài khoản đã tồn tại: Error: Tài khoản [username] đã tồn tại.
  - Không đủ tham số: Error: Vui lòng truyền tham số: [default_username] [default_password]

#### Xoá FTP Account - Delete account

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/delete_ftp_account.sh ) [username]
```

- Kết quả trả về:
  - Thành công: Tài khoản [username] đã được xóa.
  - Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  - Thất bại: Error: Vui lòng cung cấp tên tài khoản để xóa.
  - Không đủ tham số: Error: Vui lòng cung cấp tên tài khoản để xóa.

#### Bật tài khoản FTP - Enable account

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/toggle_ftp_account.sh ) [username] enable
```

- Kết quả trả về:
  - Thành công: Tài khoản [username] đã được bật.
  - Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  - Truyền sai: Error: Hành động không hợp lệ. Vui lòng sử dụng 'enable' hoặc 'disable'.

#### Disable account - Tắt tài khoản FTP

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/toggle_ftp_account.sh ) [username] disable
```

- Kết quả trả về:
  - Thành công: Tài khoản [username] đã được tắt.
  - Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  - Truyền sai: Error: Hành động không hợp lệ. Vui lòng sử dụng 'enable' hoặc 'disable'.

#### Set FTP Quota

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/set_ftp_quota.sh ) [username] [quota]
```

- Kết quả trả về:
  - Thành công: Đã đặt [quota] cho tài khoản FTP [username].
  - Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  - Không đủ tham số: Error: Vui lòng truyền tham số: [tên_tài_khoản] [quota (MB)]

#### Copy password FTP

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/copy_ftp_password.sh ) [username]
```

- Kết quả trả về:
  - Thành công: Mật khẩu của tài khoản [username] là: [password].
  - Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  - Không đủ tham số: Error: Vui lòng truyền tham số: [tên_tài_khoản]

#### Change password

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/change_ftp_pass.sh ) [username] [new_password]
```

- Kết quả trả về:
  - Thành công: Mật khẩu cho tài khoản [username] đã được thay đổi.
  - Thành công: Mật khẩu cho tài khoản [username] đã được cập nhật trong Pure-FTPd.
  - Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  - Không đủ tham số: Error: Vui lòng truyền tham số: [tên_tài_khoản] [mật_khẩu_mới]

#### Change home directory

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/change_ftp_home_directory.sh ) [username] [new_home_directory]
```

- Kết quả trả về:
  - Thành công: Thư mục [new_home_directory] đã được tạo thành công.
  - Thành công: Thư mục home cho tài khoản [username] đã được cập nhật trong Pure-FTPd.
  - Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  - Không đủ tham số: Error: Vui lòng truyền tham số: [tên_tài_khoản] [thư_mục_home_mới].

## 7. Monitor delete - list deleted - backup

### Monitor delete file/folder - show list deleted - restore file/folder

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/monitor_delete_restore.sh.sh ) {delete|delete-permanent|deleted-all|list|restore|restore-all} <folder-or-file-path>
```

Cách dùng

`Xóa file/folder(chuyển vào recycle bin):`

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/monitor_delete_restore.sh.sh ) delete /var/www/html/old_website
```

- delete: Là hành động mà bạn muốn thực hiện (di chuyển thư mục hoặc file vào thư mục backup).
- /var/www/html/old_website: Là đường dẫn đến thư mục hoặc file bạn muốn xóa.

`Xóa hoàn toàn file trong recycle bin:`

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/monitor_delete_restore.sh.sh ) delete-permanent /var/www/html/old_website
```

`Xóa tất cả trong recycle bin:`

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/monitor_delete_restore.sh.sh ) deleted-all
```

`Hiển thị các file và thư mục đã di chuyển vào thư mục sao lưu (list):`

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/monitor_delete_restore.sh.sh ) list
```

`Phục hồi file hoặc thư mục từ thư mục sao lưu (restore):`

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/monitor_delete_restore.sh.sh ) restore old_website
```

- restore: Là hành động mà bạn muốn thực hiện (phục hồi file hoặc thư mục từ thư mục backup).
- old_website: Là tên của file hoặc thư mục bạn muốn phục hồi (tên này phải trùng với tên thư mục hoặc file trong thư mục backup).

Ví dụ:
`Phục hồi thư mục old_website từ thư mục backup về lại thư mục /var/www/html.`

`Phục hồi tất cả từ thư mục sao lưu (restore):`

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/monitor_delete_restore.sh.sh ) restore-all
```

### Lấy thông tin location của vps - Get location of VPS

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/get_vps_location.sh )
```

#### Add plugins

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/add-plugins.sh) <plugin_slug*> <domain1*> <domain2*> ... <domainN*>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/add-plugins.sh) contact abc.com bcd.com
```

#### Check plugin

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/check-plugin.sh) abc.com
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/add-plugin.sh) abc.com
```

#### Update plugin

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/update-plugin.sh) linkokvipb4.com akismet:active:enable
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/update-plugin.sh) linkokvipb4.com akismet:active:enable
```

#### Auto update plugin

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/auto-update-plugin.sh) <action*>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/auto-update-plugin.sh) enable
```

#### Active/Deactive maintenance mode

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/maintenance-website.sh) <status*> <domain1*> <domain2*> ... <domainN*>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/maintenance-website.sh) active abc.com bcd.com
```

#### Check Active/Deactive maintenance mode

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/check-maintenance-website.sh) <domain1*> <domain2*> ... <domainN*>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/check-maintenance-website.sh) abc.com bcd.com
```

#### Change path login for domain wp

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/change-path-login.sh) <domain1*> <domain2*> ... <domainN*>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/change-path-login.sh) abc.com bcd.com
```

#### Auto update by plugin

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/auto-update-by-plugin.sh) <plugin*> <action*>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/plugins/auto-update-by-plugin.sh) test enable
```

#### Bật/tắt edit file mode

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/file/edit-file-mode.sh) <action*> <domain1*> <domain2*> ... <domainN*>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/file/edit-file-mode.sh) active domain1.com domain2.com
```

#### Cài đặt tường lửa

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/install-firewall.sh) <domain1*> <domain2*> ... <domainN*>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/install-firewall.sh) domain1.com domain2.com
```

#### Scan malware

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/file/scan-malware.sh) <domain1*> <domain2*> ... <domainN*>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/file/scan-malware.sh) domain1.com domain2.com
```

#### Get list page

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/get-list-page.sh) <domain>
```

Example:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/get-list-page.sh) domain1.com
```
