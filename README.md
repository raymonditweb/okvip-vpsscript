## OKVIP-VPSSCRIPT:

OKVIP-VPSSCRIPT là nền để quản lý và cài đặt website wordpress trên Ubuntu 20.04


### 1. Quản lý Máy Chủ (Server/VPS)
#### Cài đặt LEMP:
+ Ubuntu 20.04:
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/install-ubuntu-lemp-20.04 ) <mysql_root_password> <init_main_domain.com>
```

### Lệnh Cài Đặt yum-cron (auto update system):
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/yum-cron-setup )
```

#### Quản lý file:
+ List file & folder
+ Upload/ Add / Edit / Zip / Unzip/ Delete
+ Set chrmode file, folder

####  Theo dõi thông số server:
+ Ram, Ổ cứng,
+ Process
+ Network, load

#### Quản lý application:
+ Install application list
+ Install / Uninstall

#### Quản lý services:
+ Restart VPS / Terminal
+ Stop / Start / Restart /

#### Quản lý logs:
+ Service logs
+ Error log
+ Application Log
+ System log

#### Backup VPS: Backup to google driver

#### Cronjob:
+ Quản lý / Thêm / Xoá

#### Security:
+ Firewall Rules
+ Change SSH Port

### 2. Quản lý website

#### List danh sách website trên vps
```
/etc/vpsscript/menu/vpsscript-list-website-tren-vps;;  
```

#### Cài đặt website WordPress tự động theo template: 
+ Add domain
+ Tạo database
+ SSL 
+ FTP
+ Download mẫu
+ Cấu hình config

```
https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/refs/heads/main/install-wordpress <mysql_root_password*> <domain*> <template_slug = default>
```

#### Tiện ích: Bật / Tắt 1 hoặc nhiều website

### Cập nhật plugin and Wordpress core:

```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/vpsscript/menu/tienich/update-wordpress-for-all-site )
```

### Scan malware for Wordpress website:

```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/vpsscript/menu/tienich/scan-wordpress-malware.sh )
```

#### Quản lý Database:
+ Listdbs / Add / Edit / Delete
+ Db Users / Add / Edit / Delete

