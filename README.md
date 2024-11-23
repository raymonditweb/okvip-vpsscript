# OKVIP - VPSSCRIPT Documentation

OKVIP - VPSSCRIPT là nền tang để quản lý và cài đặt website wordpress trên Ubuntu 20.04
[OKVIP - VPSSCRIPT is a management and installation framework for WordPress websites on Ubuntu 20.04]

## 1. Quản lý Máy Chủ (Server/VPS) - Server/VPS Management

### Cài đặt LEMP - LEMP Installation

For Ubuntu 20.04:

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/install-ubuntu-lemp-20.04 ) <mysql_root_password> <init_main_domain.com>
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

+ Danh sách file logs: nằm trong /var/log/
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

`
ví dụ: bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/others/change_php_version.sh) 7.0
`

+ Kết quả trả về:
  + Không có root : Error: Vui lòng chạy script với quyền root.
  + Thành công: Thay đổi PHP sang $PHP_VERSION hoàn tất!
  + Nếu PHP đã tồn tại: PHP $PHP_VERSION đã có sẵn trên hệ thống.
  + Không đủ tham số: Error: Sử dụng: phiên_bản_php (ví dụ: 7.4/ 8.1)
  + Thất bại: Error: Không thể cài đặt PHP $PHP_VERSION. Vui lòng kiểm tra lại.

#### Backup VPS: Backup to google driver

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

`
Vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/manage_cron.sh ) enable "0 2 * * * /path/to/script.sh"
`

+ Kết quả trả về:
  + Khong có quyền root: Error: Vui lòng chạy script với quyền root.
  + Sai Tham Số: Error: `Sử dụng: $0 <enable|disable> '<cron_job> / Ví dụ: $0 enable '0 2 * * * /path/to/script.sh`
  + Cron tồn tại và đang được bật: Error: Cron job đã được bật trước đó.
  + Cron tồn tại và đang tat: Error: Cron job không tồn tại hoặc đã bị tắt trước đó.
  + Nếu không tìm thấy cron job, sẽ thông báo lỗi: Error: Hành động không hợp lệ. Sử dụng 'enable' hoặc 'disable'.
  + Thanh cong: Cập nhật cron hoàn tất!

#### Excute Cron Job

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/excute.sh ) <"* * * * * exec-command"*>
```

`
Vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/excute.sh ) "0 2 * * * /path/to/script.sh"
`

+ Kết quả trả về:
  + Khong có quyền root: Error: Vui lòng chạy script với quyền root.
  + Sai Tham Số: Error: `Sử dụng: $0 '<cron_job> / Ví dụ: $0 '0 2 * * * /path/to/script.sh`
  + Nếu không tìm thấy cron job: "Error: Cronjob khong ton tai: $CRONJOB_COMMAND. Khong the thuc thi!
  + Thanh cong: Executing cronjob: $CRONJOB_COMMAND

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

+ Kết quả trả về:
  + Không có root : Error: Vui lòng chạy script với quyền root.
  + Thành công: Fail2Ban đã được cài đặt lại và khởi động thành công.

#### Thêm service vào giám sát Fail2Ban - Add service to Fail2Ban

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/add_services_fail2ban.sh ) [SERVICE_NAME]
```

+ Kết quả trả về:
  + Không có root : Error: Vui lòng chạy script với quyền root.
  + Thành công: Dịch vụ SERVICE_NAME đã được thêm vào danh sách giám sát của Fail2Ban.
  + Thiếu tham số: Error: Sử dụng: [tên_dịch_vụ]
  + Service không đang chạy: Error: Dịch vụ SERVICE_NAME không đang chạy. Không thể thêm vào Fail2Ban.
  + Đã tồn tại: Error: Dịch vụ SERVICE_NAME đã tồn tại trong JAIL_LOCAL_FILE

#### Thêm Địa chỉ IP vào Danh sách Whitelist của Fail2ban - Add IP to ignorelist

```bash
bash <(curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/add_ip_whitelist.sh) [IP1] [IP2]
```

+ Kết quả trả về:
  + Không có root : Error: Vui lòng chạy script với quyền root.
  + Thành công: Các thay đổi đã được áp dụng thành công!
  + Nếu IP đã tồn tại: Error: Địa chỉ IP $ip đã có trong whitelist..
  + Không đủ tham số:
    Error: Sử dụng Cú pháp: [ip1] [ip2] ...
    Ví dụ: [192.168.1.10] [192.168.1.20]

#### Change SSH port

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/change-ssh-port.sh ) <new_ssh_port*>
```

#### Change root password

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/change-password.sh ) <'new_password'*>
```

Nhập mật khẩu mới trong cặp dấu nháy đơn, ví dụ: 'cC,2K%5kSkj!yKqtu'

## 2. Website Management

### Website Operations

#### List Websites

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/list-websites)
```

#### Cài đặt website WordPress tự động theo template

+ Add domain
+ Tạo database
+ SSL
+ Download mẫu
+ Cấu hình config

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/install-wordpress) <mysql_root_password*> <domain*> <template_url*>
```

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

#### Cấu hình redirect (301, 302..) - Redirect configuration (301, 302, etc.)

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/setup_redirect.sh ) [domain] [URL-301] [URL-301-target] [URL-302] [URL-302-target] [URL-307] [URL-307-target] [URL-308] [URL-308-target]
```

`
vi du: bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/setup_redirect.sh ) [http://www.example.com/new-page] [/old-page-301] [/new-page-301] [/temporary-page-302] [/new-temporary-page-302] [/temporary-page-307] [/new-temporary-page-307] [/old-permanent-page-308] [/new-permanent-page-308]
`

+ Kết quả trả về:
  + Không có root : Error: Vui lòng chạy script với quyền root.
  + Thành công: Redirects đã được cấu hình thành công cho Nginx.
  + Số lượng tham số không đúng: Error: Cách sử dụng: [domain] [URL-301] [URL-301-target] [URL-302] [URL-302-target] [URL-307] [URL-307-target] [URL-308] [URL-308-target]

#### Thay đổi site directory - Change website directory

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/change_site_directory.sh) [SITE_NAME] [new_directory]
```

+ Kết quả trả về:
  + Không có root : Error: Vui lòng chạy script với quyền root.
  + Thành công: Thành công! Thư mục của site 'SITE_NAME' đã được thay đổi thành: NEW_DIRECTORY
  + Thiếu tham số: Error: Sử dụng cú pháp: [SITE_NAME] [new_directory]
                    Ví dụ: example.com /var/www/example_new
  + Cấu hình không tồn tại: Error: Cấu hình Nginx cho site '$SITE_NAME' không tồn tại.
  + Thất bại: Error: Cú pháp cấu hình Nginx không hợp lệ, không thể áp dụng thay đổi.

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

## 5. User Operations

### List users

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/list-users ) <mysql_root_password*>
```

#### Thêm db user & assign db - Add user

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/add-user ) <mysql_root_password*> <user_name*> <user_password*> [db_name]
```

+ nếu không truyền vào db_name thì chỉ tạo user

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
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/package/get_recently_installed_packages.sh )
```

#### Install Pure-FTPd

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/install_pureftpd.sh )
```

+ Kết quả trả về:
  + Thành công: Pure-FTPd đã được cài đặt thành công.
  + Nếu Pure-FTPd đã được cài đặt: Error: Pure-FTPd đã được cài đặt.

### FTP Account Management

#### Danh sách FTP Account - List accounts

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/list_ftp_accounts.sh )
```

+ Kết quả trả về:
  + Nếu có tài khoản FTP: List tài khoản FTP:
    [user1]:[password1]
    [user2]:[password2]
  + Nếu không có tài khoản FTP: No result

#### Thêm FTP Account - Add account

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/add_ftp_account.sh ) [username] [password]
```

+ Kết quả trả về:
  + Thành công: Tài khoản FTP [username] đã được thêm thành công với đầy đủ quyền.
  + Nếu tài khoản đã tồn tại: Error: Tài khoản [username] đã tồn tại.
  + Không đủ tham số: Error: Vui lòng truyền tham số: [default_username] [default_password]

#### Xoá FTP Account - Delete account

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/delete_ftp_account.sh ) [username]
```

+ Kết quả trả về:
  + Thành công: Tài khoản [username] đã được xóa.
  + Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  + Thất bại: Error: Vui lòng cung cấp tên tài khoản để xóa.
  + Không đủ tham số: Error: Vui lòng cung cấp tên tài khoản để xóa.

#### Bật tài khoản FTP - Enable account

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/toggle_ftp_account.sh ) [username] enable
```

+ Kết quả trả về:
  + Thành công: Tài khoản [username] đã được bật.
  + Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  + Truyền sai: Error: Hành động không hợp lệ. Vui lòng sử dụng 'enable' hoặc 'disable'.

#### Disable account - Tắt tài khoản FTP

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/toggle_ftp_account.sh ) [username] disable
```

+ Kết quả trả về:
  + Thành công: Tài khoản [username] đã được tắt.
  + Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  + Truyền sai: Error: Hành động không hợp lệ. Vui lòng sử dụng 'enable' hoặc 'disable'.

#### Set FTP Quota

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/set_ftp_quota.sh ) [username] [quota]
```

+ Kết quả trả về:
  + Thành công: Đã đặt [quota] cho tài khoản FTP [username].
  + Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  + Không đủ tham số: Error: Vui lòng truyền tham số: [tên_tài_khoản] [quota (MB)]

#### Copy password FTP

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/copy_ftp_password.sh ) [username]
```

+ Kết quả trả về:
  + Thành công: Mật khẩu của tài khoản [username] là: [password].
  + Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  + Không đủ tham số: Error: Vui lòng truyền tham số: [tên_tài_khoản]

#### Change password

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/change_ftp_pass.sh ) [username] [new_password]
```

+ Kết quả trả về:
  + Thành công: Mật khẩu cho tài khoản [username] đã được thay đổi.
  + Thành công: Mật khẩu cho tài khoản [username] đã được cập nhật trong Pure-FTPd.
  + Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  + Không đủ tham số: Error: Vui lòng truyền tham số: [tên_tài_khoản] [mật_khẩu_mới]

#### Change home directory

```bash
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/ftp/change_ftp_home_directory.sh ) [username] [new_home_directory]
```

+ Kết quả trả về:
  + Thành công: Thư mục [new_home_directory] đã được tạo thành công.
  + Thành công: Thư mục home cho tài khoản [username] đã được cập nhật trong Pure-FTPd.
  + Nếu tài khoản không tồn tại: Error: Tài khoản [username] không tồn tại.
  + Không đủ tham số: Error: Vui lòng truyền tham số: [tên_tài_khoản] [thư_mục_home_mới].
