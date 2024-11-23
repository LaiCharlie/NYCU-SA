## HW3

> [!NOTE] 
> I do 3-3 first, then 3-1, 3-2
> It's a good idea to `sudo su -` as root to do the hw

### HW 3-1 (24%)
- [x] sysadm (6%)
    - [x] Login from ssh and sftp (2%)
    - [x] Full access to “public” (2%), “hidden” (2%)
    
- [x] sftp-u1, sftp-u2 (9%)
    - [x] disable SSH login, only accept SFTP, Chrooted (/home/sftp)(3%)
    - [x] Full access to “public”, can only delete files and directories they owned. (2%)
    - [x] Full access to “hidden” (2%)
    - [x] adjust DAC (2%)
        - remove all permission (rwx) of others when uploading
            
- [x] anonymous (9%)
    - [x] disable SSH login, only accept SFTP, Chrooted (/home/sftp) (3%)
    - [x] can enter “hidden” (2%) and “public” (2%)
    - [x] operations are read-only(even the file is writable to anonymous) (2%)

> [!NOTE]
> #### Ref:
> [Ubuntu SFTP reference 1](https://www.cybrosys.com/blog/how-to-setup-sftp-server-on-ubuntu-20-04)
> [Ubuntu SFTP reference 2](https://ui-code.com/archives/310)
> [SFTP reference](https://caibaoz.com/blog/2013/04/27/sftp_config_for_openssh/)

> create user with ssh disable but sftp enable
```bash
# modify the shell of user to nologin
sudo useradd -m -s /usr/sbin/nologin sftp-u1
sudo useradd -m -s /usr/sbin/nologin sftp-u2
sudo useradd -m -s /usr/sbin/nologin anonymous
# -m : Create the user's home directory if it does not exist.
```

> Remember to copy /home/judge/**.ssh/authorized_keys** to every users home dir and set proper permission
> ```bash
> root@sa2024-108:/# ls -al /home/judge/.ssh/
> # drwx------  2 judge judge   5 Nov  2 03:16 .
> # -rw-------  1 judge judge  96 Sep 13 17:52 authorized_keys
> ```

> [!WARNING] 
> #### Wrong config
> Will cause both SSH and SFTP disable
> ```bash
> sudo vim /etc/ssh/sshd_config
> # DenyUsers sftp-u1 sftp-u2 anonymous
> ```

> create user `sysadm`
```bash
sudo useradd -m -s /bin/bash sysadm
```

> change home dir of `sysadm`
```bash
sudo usermod -d /home/sftp sysadm
```

> set password for users
```bash
sudo passwd sftp-u1
sudo passwd sftp-u2
sudo passwd anonymous
sudo passwd sysadm
```

> create group for permission control
```bash
sudo groupadd sftpgroup
sudo usermod -aG sftpgroup sysadm
sudo usermod -aG sftpgroup sftp-u1
sudo usermod -aG sftpgroup sftp-u2
```

> remove user from group
```bash
sudo deluser anonymous sftpgroup
```

> set SFTP
```bash
sudo vim /etc/ssh/sshd_config
# -- Add these lines in the tail of file --
# Match User sftp-u1,sftp-u2,anonymous
#     ChrootDirectory /home/sftp
#     ForceCommand internal-sftp
#     AllowTcpForwarding no
#     X11Forwarding no
#     PermitTunnel no
#     PermitTTY no
#     AllowAgentForwarding no
```

> （Sticky Bit）代表只有目錄內的檔案所有者或是 root 才能進行刪除或移動
```bash
sudo chown sysadm:sftpgroup /home/sftp/public
sudo chown sysadm:sftpgroup /home/sftp/hidden
sudo chown sysadm:sftpgroup /home/sftp/hidden/treasure
sudo chown sysadm:sftpgroup /home/sftp/hidden/treasure/secret
sudo chmod 1775 /home/sftp/public
sudo chmod 0771 /home/sftp/hidden
sudo chmod 0775 /home/sftp/hidden/treasure
sudo chmod  775 /home/sftp/hidden/treasure/secret
```

> adjust DAC
```bash
sudo vim /etc/ssh/sshd_config
# Match User sftp-u1,sftp-u2,anonymous
#         ChrootDirectory /home/sftp
#         ForceCommand internal-sftp -u 0007
```

 
> After setting sshd_config
```
sudo systemctl restart ssh
```


### HW 3-2 (22%)
- [x] sftp_watchd
    - [x] SFTP logging (3%)
    - [x] aggregate only SFTP log to “/var/log/sftp.log” (3%)
    - [x] violation file should moved to /home/sftp/hidden/.violated/ (4%)
    - [x] logging after the violation file upload (4%)

- [x] Service operation works correctly
    - [x] sftp_watchd should be auto-start (2%)
    - [x] start/status/stop/restart (6%)
        - sftp_watchd should be run in the background, and pid file is not required when using Linux 

> [!NOTE]  
> #### Ref:
> [Ubuntu service](https://chenhh.gitbooks.io/ubuntu-linux/content/service.html)
> [service file setting](https://blog.gtwang.org/linux/linux-create-systemd-service-unit-for-python-echo-server-tutorial-examples/)
> [Ubuntu /etc/init.d](https://felix-lin.com/linux/debianubuntu-%E6%96%B0%E5%A2%9E%E9%96%8B%E6%A9%9F%E8%87%AA%E5%8B%95%E5%9F%B7%E8%A1%8C%E7%A8%8B%E5%BC%8F/)
> [sftp_watchd program by Bee](https://github.com/bee0511/SA/tree/main/HW3)
> [systemd man page](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#StandardOutput=)
> [service output](https://askubuntu.com/questions/1166798/systemd-service-output-to-terminal-pty)


> check rsyslog 
```bash
service rsyslog status
```

> check the parameter
```bash
man sftp-server
```

> enable logging SFTP
```bash
sudo vim /etc/ssh/sshd_config
# -- Modify the line Subsystem as --
# Subsystem sftp internal-sftp -l VERBOSE -f LOCAL0
```

> setting the log file by rsyslog
```bash
sudo vim /etc/rsyslog.d/50-default.conf
# -- add the line into file --
# local0.warning                    /var/log/sftp_watchd.log
# local0.info                       /var/log/sftp.log
```

> restart ssh and rsyslog
```bash
sudo systemctl restart ssh
sudo systemctl restart rsyslog
```

> test the file is executable or not
```bash
root@sa2024-108:/home/sftp/public# file test-513642f4
# test-513642f4: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=9ba9e22af85aa315e7248e5056d31fbfa1035331, for GNU/Linux 3.2.0, not stripped
```

> sftp_watchd
```bash
# Write a program sftp_watchd
# I put it at /usr/local/bin/
```

> Add judge into sftpgroup (oj use `judge` to rm file in `.violate`)
```bash
sudo usermod -aG sftpgroup judge
```

> sftp_watchd service
```bash
# Method 1 (preferred)
sudo vim /etc/systemd/system/sftp_watchd.service
# Add your config to control sftp_watchd (my path is /usr/local/bin/sftp_watchd)
sudo systemctl daemon-reload
sudo systemctl restart sftp_watchd
sudo systemctl enable sftp_watchd

# Method 2
# sudo vim /etc/init.d/sftp_watchd
# sudo update-rc.d sftp_watchd defaults
```

> test service
```bash
service sftp_watchd start
service sftp_watchd stop
service sftp_watchd restart
service sftp_watchd status
cat /var/run/sftp_watchd.pid
systemctl list-units --type=service | grep sftp
```

<!-- 
```bash
# `sudo service sftp_watchd start`
# terminal output: "Starting sftp_watchd." and run the function /usr/local/bin/sftp_watchd

# `sudo service sftp_watchd stop`
# terminal output: "Kill: 3209" (3209 is the pid of /usr/local/bin/sftp_watchd) and kill the function /usr/local/bin/sftp_watchd

# `sudo service sftp_watchd restart`
# terminal output: "Kill: 3204\nStarting sftp_watchd." and stop the /usr/local/bin/sftp_watchd first then start it.

# `sudo service sftp_watchd status`
# terminal output: "sftp_watchd is running as pid 3204." (3204 is the pid of /usr/local/bin/sftp_watchd)

# /usr/local/bin/sftp_watchd should be run in the background and should be auto-start after boot. 
```
-->

### HW 3-3 (54%)
- [x] Disk Setup (Add 4 new disks)
    - [x] Enable kernel to show gpt label in /dev/gpt/ (FreeBSD), /dev/disk/by-partlabel (Linux) (3%)
    - [x] partition with GPT scheme with correct label (2%)

- [x] ZFS
    - [x] Create a raid10 pool using block device at /dev/gpt as vdev (3%)
    - [x] Create all datasets and set up correctly mountpoint, atime, compression (3%)
    
- [x] zfsbak
    - [x] Usage (2%)
    - [x] Create, List, Delete (9% / each)
    - [x] Export, Import (include log) (7% / each) 

--------

> Add 4 new disks
```
Open VirtualBox and go to Settings > Storage.
Click on Controller: SATA (or add a new controller if needed) and add four new virtual hard disks.
```

> check the disk
```bash
lsblk
# 4 new disk
# sdb      8:16   0    10G  0 disk 
# sdc      8:32   0    10G  0 disk 
# sdd      8:48   0    10G  0 disk 
# sde      8:64   0    10G  0 disk 
```

> [!NOTE]  
> #### Ref:
> [Partition reference](https://askubuntu.com/questions/586439/create-guid-partition-table-gpt-during-ubuntu-server-install)


> Partition for each disk
```bash
sudo parted /dev/sdb
> GNU Parted 3.6
> Using /dev/sdb
> Welcome to GNU Parted! Type 'help' to view a list of commands.

(parted) mklabel gpt
> Warning: The existing disk label on /dev/sdb will be destroyed and all data on this disk will be lost. Do you want to continue?
> Yes/No? Yes

(parted) mkpart primary 0% 100%

(parted) name 1 mypool-1

(parted) print   
> Model: ATA VBOX HARDDISK (scsi)
> Disk /dev/sdb: 10.7GB
> Sector size (logical/physical): 512B/512B
> Partition Table: gpt
> Disk Flags: 
> Number  Start   End     Size    File system  Name      Flags
>  1      1049kB  10.7GB  10.7GB               mypool-1

(parted) ?  
>  align-check TYPE N                       check partition N for TYPE(min|opt) alignment
>  help [COMMAND]                           print general help, or help on COMMAND
>  mklabel,mktable LABEL-TYPE               create a new disklabel (partition table)
>  mkpart PART-TYPE [FS-TYPE] START END     make a partition
>  name NUMBER NAME                         name partition NUMBER as NAME
>  print [devices|free|list,all]            display the partition table, or available devices, or free space, or all found partitions
>  quit                                     exit program
>  rescue START END                         rescue a lost partition near START and END
>  resizepart NUMBER END                    resize partition NUMBER
>  rm NUMBER                                delete partition NUMBER
>  select DEVICE                            choose the device to edit
>  disk_set FLAG STATE                      change the FLAG on selected device
>  disk_toggle [FLAG]                       toggle the state of FLAG on selected device
>  set NUMBER FLAG STATE                    change the FLAG on partition NUMBER
>  toggle [NUMBER [FLAG]]                   toggle the state of FLAG on partition NUMBER
>  type NUMBER TYPE-ID or TYPE-UUID         type set TYPE-ID or TYPE-UUID of partition NUMBER
>  unit UNIT                                set the default unit to UNIT
>  version                                  display the version number and copyright information of GNU Parted

(parted) quit
```

> verify setting
```bash
ls /dev/disk/by-partlabel
# mypool-1  mypool-2  mypool-3  mypool-4
```

> [!NOTE]  
> #### Ref:
> [zpool reference](https://www.cyberciti.biz/faq/how-to-create-raid-10-striped-mirror-vdev-zpool-on-ubuntu-linux/)
> [zfs ubuntu wiki](https://wiki.ubuntu.com/Kernel/Reference/ZFS)


> create zfs pool
```bash
sudo zpool create mypool mirror /dev/disk/by-partlabel/mypool-1 /dev/disk/by-partlabel/mypool-2 mirror /dev/disk/by-partlabel/mypool-3 /dev/disk/by-partlabel/mypool-4
```

> zfs mount point
```bash
zfs set mountpoint=/home/sftp mypool
```

> verify zpool
```bash
root@sa2024-108:~# zpool status mypool
#   pool: mypool
#  state: ONLINE
# config: ...
 
root@sa2024-108:~# zpool list
# NAME     SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
# mypool    19G   116K  19.0G        -         -     0%     0%  1.00x    ONLINE  -

root@sa2024-108:/home# df -h | grep mypool
# mypool                                             19G  128K   19G   1% /home/sftp

root@sa2024-108:~# zfs list mypool
# NAME                                               USED  AVAIL  REFER  MOUNTPOINT
# mypool                                             116K  18.4G    24K  /home/sftp

root@sa2024-108:/home# lsblk --output NAME,FSTYPE,MODEL,LABEL,PTTYPE,SIZE -e 7
# NAME   FSTYPE     MODEL         LABEL  PTTYPE  SIZE
# sdb               VBOX HARDDISK        gpt      10G
# └─sdb1 zfs_member               mypool gpt      10G
# sdc               VBOX HARDDISK        gpt      10G
# └─sdc1 zfs_member               mypool gpt      10G
# sdd               VBOX HARDDISK        gpt      10G
# └─sdd1 zfs_member               mypool gpt      10G
# sde               VBOX HARDDISK        gpt      10G
# └─sde1 zfs_member               mypool gpt      10G
```

> create ZFS datasets
```bash
sudo zfs create mypool/public
sudo zfs create mypool/hidden

sudo zfs set compression=lz4 mypool
sudo zfs set atime=off       mypool

zfs get all mypool/public mypool/hidden | grep -E "compression|atime"
# mypool/hidden  compression           lz4                    local
# mypool/hidden  atime                 off                    local
# mypool/public  compression           lz4                    local
# mypool/public  atime                 off                    local
```

#### zfsbak

> [!NOTE]  
> #### Ref:
> [zfs Ubuntu wiki](https://wiki.ubuntu.com/Kernel/Reference/ZFS)
> [2023 HW written by KJL](https://github.com/KJLdefeated/NYCU-SA/blob/main/usr/local/etc/zfsbak)


> [!TIP]
> **KJL** is NYCU CS student who went to UIUC for one semester.
> 
> [shellcheck](https://www.shellcheck.net/) is your good helper while doing **zfsbak**


> check $PATH
```bash
root@sa2024-108:/usr/local/bin# echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
```

> add script to $PATH 
```bash
root@sa2024-108:~# cd /usr/local/bin/
root@sa2024-108:/usr/local/bin# ls
zfsbak

# Now, we can execute zfsbak with command “zfsbak”, not “./zfsbak”
```

> Preserve `$HOME` while using `sudo`
```sh=
root@sa2024-108:~# visudo
# Defaults:%sudo env_keep += "HOME"
```

> test for user judge
```bash
$ zfsbak
Usage:
- create: zfsbak DATASET [ROTATION_CNT]
- list: zfsbak -l|--list [DATASET|ID|DATASET ID...]
- delete: zfsbak -d|--delete [DATASET|ID|DATASET ID...]
- export: zfsbak -e|--export DATASET [ID]
- import: zfsbak -i|--import FILENAME DATASET
```

<!-- > Install tools for judge
```bash
# [ERR]: SSH execute `sha256` return 1
# [DBG]: SSH connection stderr: `sudo: sha256: command not found`
# secret.bin: FAILED
# sha256sum: WARNING: 1 of 1 computed checksums did NOT match
apt install hashalot
``` -->

> watch log to debug
```
sudo cat /var/log/auth.log
```

```bash
judge : PWD=/home/judge ; USER=root ; ENV=ZFSBAK_PASS=sImpleP@ss-sa-2023 ; COMMAND=/usr/local/bin/zfsbak -e mypool/public 1
```
