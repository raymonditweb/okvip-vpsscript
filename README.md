## OKVIP-VPSSCRIPT:

OKVIP-VPSSCRIPT là nền để quản lý và cài đặt website wordpress trên Ubuntu 20.04


### 1. Quản lý Máy Chủ (Server/VPS)
#### Cài đặt LEMP:
- Ubuntu 20.04:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/install-ubuntu-lemp-20.04 ) <mysql_root_password> <init_main_domain.com>
```

### Lệnh Cài Đặt yum-cron (auto update system):
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/yum-cron-setup )
```

#### Restart VPS:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/restart-vps )
```

#### Quản lý file:
- List file & folder
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/file/list-files.sh ) </path/to/file_or_folder*>
```
- Set chrmode file, folder
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/file/set-chmod ) <mod*> </path/to/file_or_folder*>
```
- Upload / Add / Delete: [Code core]

####  Theo dõi thông số server:
- Thông tin RAM
```
free -h
```
- Thông tin ổ cứng
```
df -h
```
- Thông tin INODE
```
df -i
```
- Danh sách process
```
ps aux --sort=-%cpu | head -n 10
```
- Danh sách sử dụng dung lượng RAM
```
ps aux --sort=-%mem | head -n 10
```
- Network, load
```
iftop -n
```

#### Quản lý application / services:
- Kiểm tra đã cài đặt chưa, trả về 0 hoặc 1
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/application/check-app ) <app_name*>
```
- Cài đặt ứng dụng mới
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/application/install-app ) <app_name*> <app_type=[app|service]> <app_version=lastest>
```

- Remove ứng dụng
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/application/remove-app ) <app_name*>
```

- Start/Stop/Reload ứng dụng
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/application/[start/stop/reload]-app ) <app_name*>
```

#### Quản lý logs:
Mở file log để đọc, log được lưu trong /var/log, sử dụng lên cat để đọc

```
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


#### Backup VPS: Backup to google driver

#### Cronjob:
- List 
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/list.sh )
```
- Add
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/add.sh ) <"* * * * * exec-command"*>
```
- Delete
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/cronjob/remove.sh ) <"* * * * * exec-command"*>
```
#### Security:
- Firewall Rules
+ Liệt kê danh sách firewall rules:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/list.sh )
```
+ Thêm database mới:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/add.sh ) <port*> <tcp|udp*>
```
+ Đổi tên database:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/remove.sh )  <port*> <tcp|udp*>
```
- Change SSH Port
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/firewall/change-ssh-port.sh ) <new_ssh_port*>
```

### 2. Quản lý website

#### List danh sách website trên vps
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/list-websites)  
```

#### Cài đặt website WordPress tự động theo template: 
+ Add domain
+ Tạo database
+ SSL 
+ Download mẫu
+ Cấu hình config

```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/install-wordpress) <mysql_root_password*> <domain*> <template_url*>
```
#### Xoá website: yêu cầu có mysql root password để remove db
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/remove-website) <domain*> <mysql_root_password*>
```

#### Tiện ích: Bật / Tắt 1 hoặc nhiều website
- Bật website
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/enable-website) <domain*>
```
- Tắt website
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/disable-website) <domain*>
```

### Cập nhật plugin and Wordpress core:

```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/vpsscript/menu/tienich/update-wordpress-for-all-site )
```

### Scan malware for Wordpress website:

```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/vpsscript/menu/tienich/scan-wordpress-malware.sh )
```

#### Quản lý Database:

- Liệt kê danh sách database:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/list-db ) <mysql_root_password*>
```
- Thêm database mới:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/add-db ) <mysql_root_password*> <db_name*>
```
- Đổi tên database:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/rename-db ) <mysql_root_password*> <old_db_name*> <new_db_name*>
```
- Xóa database:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/delete-db ) <mysql_root_password*> <db_name*>
```
- Liệt kê danh sách database users:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/list-users ) <mysql_root_password*>
```
- Thêm db user & assign db: 
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/add-user ) <mysql_root_password*> <user_name*> <user_password*> [db_name]
```
* nếu không truyền vào db_name thì chỉ tạo user
- Đổi tên người dùng:
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/rename-user ) <mysql_root_password*> <old_user_name*> <new_user_name*>
```
- Đổi mật khẩu người dùng: 
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/change-user-password ) <mysql_root_password*> <user_name*> <new_password*>
```
- Xóa người dùng: 
```
bash <( curl -k -H "Cache-Control: no-cache" https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/db/delete-user ) <mysql_root_password*> <user_name*>
```