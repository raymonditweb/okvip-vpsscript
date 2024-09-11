## OKVIP-VPSSCRIPT:

OKVIP-VPSSCRIPT là bản chỉnh sửa lại từ vpsscript-3.8.1, hỗ trợ các hệ điều hành mới hơn như CentOS 7,8,9, Almalinux 8,9.

### Lệnh Cài Đặt OKVIP-VPSSCRIPT :

#### Ubuntu 20.04:
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/main/install-ubuntu-lemp-20.04 ) <mysql_root_password> <init_main_domain.com>
```
*) mysql_root_password : rỗng = tự tạo
*) init_main_domain.com : rỗng = vpsscript.demo

#### CentOS 7,8,9, Almalinux 8,9: 
```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/install )
```

#### OS Hỗ trợ: `CentOS 7` `CentOS 8` `CentOS 9` `AlmaLinux 8` `AlmaLinux 9` (Without SELinux):

### Lệnh Cài Đặt yum-cron (auto update system):

```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/yum-cron-setup )
```

### Find and update plugin and Wordpress core for Wordpress website:

```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/vpsscript/menu/tienich/update-wordpress-for-all-site )
```

### Find and Scan malware for Wordpress website:

```
bash <( curl -k https://raw.githubusercontent.com/raymonditweb/okvip-vpsscript/master/script/vpsscript/menu/tienich/scan-wordpress-malware.sh )
```

---

### Danh sách các file bat cmd:

#### List danh sách website trên vps

```
/etc/vpsscript/menu/vpsscript-list-website-tren-vps;;  
```

