## OKVIP-VPSSCRIPT:

OKVIP-VPSSCRIPT là nền để quản lý và cài đặt website wordpress trên Ubuntu 20.04


### 1. Quản lý Máy Chủ (Server/VPS)
#### Cài đặt LEMP:
+ Ubuntu 20.04:
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/install-ubuntu-lemp-20.04 ) <mysql_root_password> <init_main_domain.com>
```

### Lệnh Cài Đặt yum-cron (auto update system):
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/yum-cron-setup )
```

#### Restart VPS:
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/restart-vps )
```

#### Quản lý file:
+ List file & folder
+ Upload/ Add / Edit / Zip / Unzip/ Delete
+ Set chrmode file, folder

####  Theo dõi thông số server:
+ Ram, Ổ cứng,
+ Process
+ Network, load

#### Quản lý application / services:
+ Kiểm tra đã cài đặt chưa, trả về 0 hoặc 1
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/application/check-app ) <app_name*>
```
+ Cài đặt ứng dụng mới
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/application/install-app ) <app_name*> <app_type=[app|service]> <app_version=lastest>
```

+ Remove ứng dụng
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/application/remove-app ) <app_name*>
```

+ Start/Stop/Reload ứng dụng
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/application/[start/stop/reload]-app ) <app_name*>
```

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
bash <( curl -k /etc/vpsscript/menu/vpsscript-list-website-tren-vps )  
```

#### Cài đặt website WordPress tự động theo template: 
+ Add domain
+ Tạo database
+ SSL 
+ Download mẫu
+ Cấu hình config

```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/install-wordpress) <mysql_root_password*> <domain*> <template_slug = default>
```
#### Xoá website: yêu cầu có mysql root password để remove db
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/remove-website) <domain*> <mysql_root_password*>
```

#### Tiện ích: Bật / Tắt 1 hoặc nhiều website
+ Bật website
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/enable-website) <domain*>
```
+ Tắt website
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/script/web/disable-website) <domain*>
```

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
