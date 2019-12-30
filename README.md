# Gentoo 安装


## 1 什么安装Gentoo
信安装gentoo的人都对gentoo有一定的了解， 如果不了解， 建议先去百度一下。

gentoo是一个比archlinux复杂， 比LFS简单的一个发行版本， 由于安装过程比较复杂， 很多需求都可以按自己的需求安装。这就是gentoo最大的优点， 高度可定制。portage相比pacman更加稳定， 相信用过archlinux的人都经历过滾挂过。FLS的复杂度是最高的， 定制性更强。 想深入学习linux，FLS是最好的选择

## 2 准备
#### 本教程适用与UEFI+GPT分区
如果当前有可以正常运行的Linux, 可以不用制作启动盘, 直接在官网下载下载[stage3](https://www.gentoo.org/downloads/)文件, 用tar解压*stage3*文件， 最好加上**p**参数， 可以保留该文件的原始权限。 然后将分好的分区进行挂载， 这需要有一定的Linux安装基础， 如果不会的话可以使用传统的安装方法， 下面会说到， 这种方法有利与复制粘贴， 当然你也可以使用ssh。最快的方法还是直接copy一份已经安装好的gentoo。


如果没有正在运行的linux， 需要去官网下载[Minimal Installation CD](https://www.gentoo.org/downloads/), linux下用dd命令制作启动盘， windows下自行百度。

## 3 分区

####  分区表
|挂载点|文件类型|分区大小|磁盘位置|
| ---: | -----: |  ----: |  ----: |
| /boot|   fat32|    100M|/dev/sda1|
|     /|    ext4|     50G|/dev/sda2|
| /home|    ext4|     70G|/dev/sda3|
|  swap|    swap|      2G|/dev/sda4|

#### 格式化
格式化boot分区   
```mkfs.vfat /dev/sda1```  
格式化/分区  
```mkfs.ext4 /dev/sda2```  
格式化home分区  
```mkfs.ext4 /dev/sda3```  
格式化swap分区  
```mkswap /dev/sda4```  
激活swap  
```swapon /dev/sda4```  

#### 挂载
```
mount /dev/sda2 /mnt/gentoo  
mkdir /mnt/gentoo  
mount /dev/sda3 /mnt/gentoo/home
```

## 4 联网
##### wifi使用 **iw**  
例如开放无线网：  
```iw dev wlp3s0 connetc SSID```  
*wlp3s0*为网口， 通过**ip a**查看  
*SSID*为网络名称
使用加密无线网自行百度iw用法  

##### 获取静态ip使用 dhcpcd
如果连不上网可以使用手机开启**USB共享网络**再使用dhcpcd


## 5 更新时间

验证当前时间使用命令**date**  

##### 自动
```ntpd -q -g```  
##### 手动
用**date**命令来对系统时钟执行手动设置。使用 MMDDhhmmYYYY 语法 (月, 日, 小时, 分钟 和 年)  
```date 100313162016```

## 6 安装stage包
#### 下载stage压缩包  
前往挂载根文件系统的Gentoo挂载点  
```cd /mnt/gentoo```  
命令行浏览器  
```links https://www.163.com/gentoo```  
#### 解压stage压缩包
```tar xpvf stage3-*.tar.bz2 --xattrs-include='*.*' --numeric-owner```  

## 7 make.conf配置  
启动编辑器（在本指南中，我们使用 nano）来更改我们将在下面讨论的优化变量  
```nano -w /mnt/gentoo/etc/portage/make.conf```  
以下参数在经过自己调整或选择之后加入到 /mnt/gentoo/etc/portage/make.conf  

1.USE: 首先,你可以删掉默认的USE标记，加上-bindist (不了解USE的情况下建议如此)  
2.CFLAGS: 将CFLAGS修改为CFLAGS="-march=native -O2 -pipe" 或者你也可以指定.例如我的Intel CPU是haswell,将native换成haswell就行(不确定就不要指定).你也可以在这里看到所有可以设置的值  
MAKEOPTS: 根据你的CPU核心数设置MAKEOPTS例如双四线程设置为MAKEOPTS="-j5"  
3.GENTOO_MIRRORS: 设置为GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo/" 请自行选择速度最快的Mirror  
4.EMERGE_DEFAULT_OPTS: 设置为EMERGE_DEFAULT_OPTS="--keep-going --with-bdeps=y"是个不错的选择,keep going意为安装一堆软件时遇到编译错误自动跳过这个软件继续编译安装  
5.FEATURES: 在这里最好写成# FEATURES="${FEATURES} -userpriv -usersandbox -sandbox",最好在前面加上#注释掉,在你编译软件遇到权限不足时去掉注释即可解决问题（但请务必注意是不是因为rm -rf /*等命令权限不足，因为说不定你的ebuild文件被篡改了）  
6.ACCEPT_KEYWORDS: 如果你想用作桌面/学习/开发系统那就务必加上ACCEPT_KEYWORDS="~amd64"，服务器/工作/家/娱乐用可以忽略  
7.ACCEPT_LICENSE: 加上ACCEPT_LICENSE="*"表示此系统接受所有软件许可证,即不论非自由还是自由软件都接受,非商业用户基本不需要考虑  
8.L10N: 设置为L10N="en-US zh-CN en zh"  
9.LINGUAS: 设置为LINGUAS="en_US zh_CN en zh"  
10.VIDEO_CARDS: 根据你的显卡类型设置假如你是NVIDIA单显卡则设置为VIDEO_CARDS="nvidia"(闭源驱动)VIDEO_CARDS="nouveau"(开源驱动).还有radeon和intel,但如果你是双显卡例如Intel+NVIDIA则设置为VIDEO_CARDS="intel i965 nvidia"(只要不是远古的集成显卡都是用i965)  
11.GRUB_PLATFORMS: 如果你使用GRUB且使用UEFI启动则添加GRUB_PLATFORMS="efi-64"  
我的：  
```
CHOST="x86_64-pc-linux-gnu"
CFLAGS="-march=skylake -O2 -pipe"
CXXFLAGS="${CFLAGS}"
CPU_FLAGS_X86="aes avx avx2 fma3 mmx mmxext pclmul popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"
MAKEOPTS="-j9"


USE="bluetooth dbus policykit udisks  eudev consolekit X"
ACCEPT_KEYWORDS="~amd64"
ACCEPT_LICENSE="*"

VIDEO_CARDS="intel"
LLVM_TARGETS="X86"

GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo/"
GRUB_PLATFORMS="efi-64"
EMERGE_DEFAULT_OPTS="--keep-going --with-bdeps=y"

# NOTE: This stage was built with the bindist Use flag enabled
PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"
 
 # This sets the language of build output to English.
 # Please keep this setting intact when reporting bugs.
 LC_MESSAGES=C
```


12.Portage Mirror: 这个不是make.conf的选项.mkdir /mnt/gentoo/etc/portage/repos.conf创建repos.conf目录并添加如下到/mnt/gentoo/etc/portage/repos.conf/gentoo.conf文件里面(自行选择速度最快的镜像站):  
```
[DEFAULT]
main-repo = gentoo
 
[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://mirrors.tuna.tsinghua.edu.cn/gentoo-portage/
auto-sync = yes
sync-rsync-verify-jobs = 1
sync-rsync-verify-metamanifest = yes
sync-rsync-verify-max-age = 24
sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
sync-openpgp-key-refresh-retry-count = 40
sync-openpgp-key-refresh-retry-overall-timeout = 1200
sync-openpgp-key-refresh-retry-delay-exp-base = 2
sync-openpgp-key-refresh-retry-delay-max = 60
sync-openpgp-key-refresh-retry-delay-mult = 4
```

## 8 进入chroot前准备

#### 复制DNS信息  
```cp --dereference /etc/resolv.conf /mnt/gentoo/etc/```  
#### 挂载必要的文件系统
```
mount --types proc /proc /mnt/gentoo/proc 
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
```

## 9 进入新环境
完成chroot有三个步骤：  
1.使用chroot将根位置从/（在安装媒介里）更改成/mnt/gentoo/（在分区里）  
2.使用source命令将一些设置（那些在/etc/profile中的）重新载入到内存中  
3.更改主提示符来帮助我们记住当前会话在一个chroot环境里面。  
```
chroot /mnt/gentoo /bin/bash 
source /etc/profile
export PS1="(chroot) ${PS1}"
```
#### 挂载 boot 分区
``` mount /dev/sda1 /boot```

## 10 配置Portage
#### 从网站安装ebuild 数据库快照
```emerge-webrsync```
#### 更新Portage ebuild 数据库
```emerge --sync```

#### 选择正确的配置文件
```
root # eselect profile list
  [1]   default/linux/amd64/17.0 (stable)
  [2]   default/linux/amd64/17.0/selinux (stable)
  [3]   default/linux/amd64/17.0/hardened (stable)
  [4]   default/linux/amd64/17.0/hardened/selinux (stable)
  [5]   default/linux/amd64/17.0/desktop (stable)
  [6]   default/linux/amd64/17.0/desktop/gnome (stable)
  [7]   default/linux/amd64/17.0/desktop/gnome/systemd (stable)
  [8]   default/linux/amd64/17.0/desktop/plasma (stable)
  [9]   default/linux/amd64/17.0/desktop/plasma/systemd (stable)
  [10]  default/linux/amd64/17.0/developer (stable)
  [11]  default/linux/amd64/17.0/no-multilib (stable)
  [12]  default/linux/amd64/17.0/no-multilib/hardened (stable)
  [13]  default/linux/amd64/17.0/no-multilib/hardened/selinux (stable)
  [14]  default/linux/amd64/17.0/systemd (stable)
  [15]  default/linux/amd64/17.0/x32 (dev)
  [16]  default/linux/amd64/17.1 (stable)
  [17]  default/linux/amd64/17.1/selinux (stable)
  [18]  default/linux/amd64/17.1/hardened (stable)
  [19]  default/linux/amd64/17.1/hardened/selinux (stable)
  [20]  default/linux/amd64/17.1/desktop (stable) *
  [21]  default/linux/amd64/17.1/desktop/gnome (stable)
  [22]  default/linux/amd64/17.1/desktop/gnome/systemd (stable)
  [23]  default/linux/amd64/17.1/desktop/plasma (stable)
  [24]  default/linux/amd64/17.1/desktop/plasma/systemd (stable)
  [25]  default/linux/amd64/17.1/developer (stable)
  [26]  default/linux/amd64/17.1/no-multilib (stable)
  [27]  default/linux/amd64/17.1/no-multilib/hardened (stable)
  [28]  default/linux/amd64/17.1/no-multilib/hardened/selinux (stable)
  [29]  default/linux/amd64/17.1/systemd (stable)
  [30]  default/linux/amd64/17.0/musl (exp)
  [31]  default/linux/amd64/17.0/musl/hardened (exp)
  [32]  default/linux/amd64/17.0/musl/hardened/selinux (exp)
  [33]  default/linux/amd64/17.0/uclibc (exp)
  [34]  default/linux/amd64/17.0/uclibc/hardened (exp)
```
根据自己的需求选择profile  
例如  
KDE桌面选择```[23]  default/linux/amd64/17.1/desktop/plasma (stable)```  
gnome选择 ``` [21]  default/linux/amd64/17.1/desktop/gnome (stable)```  
最小安装 ``` [16]  default/linux/amd64/17.1 (stable)```  
我使用的是wm窗口管理器， 所以我选的是```[20]  default/linux/amd64/17.1/desktop (stable) *```  
``` eselect profile set 20```  
如果你使用systemd则需要选上带有systemd字样的选项  
如果你不使用systemd则不建议使用GNOME桌面,因为GNOME桌面依赖systemd  

#### 更新@world集合
```
emerge --ask --verbose --update --deep --newuse @world
```
## 11 本地化
#### 时区
```
echo "Asia/Shanghai" > /etc/timezone
emerge --config sys-libs/timezone-data
```
#### 配置地区
```
echo "en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8" >> /etc/locale.gen

locale-gen

eselect locale list

eselect locale set 8
```
这里建议使用英语易于排错,之后你可以自行换成中文  

#### 修改主机名
```echo hostname=\"Test\" > /etc/conf.d/hostname```

#### 重新加载环境
```env-update && source /etc/profile && export PS1="(chroot) ${PS1}"```

## 12 配置内核

#### 安装源码
```emerge --ask sys-kernel/gentoo-sources```  

#### 自动配置
不知道配置内核的建议使用genkernel  
```
emerge -av genkernel
genkernel --menuconfig all
genkernel --install initramfs
```

#### 手动配置
手动配置可以参考gentoo[官网](https://wiki.gentoo.org/wiki/Kernel/Gentoo_Kernel_Configuration_Guide), [金步国](http://www.jinbuguo.com/kernel/longterm-linux-kernel-options.html)  


## 13 配置fstab,安装文件系统工具
借用**YangMame**脚本
```
wget https://raw.githubusercontent.com/YangMame/Gentoo-Installer/master/genfstab
chmod +x genfstab
#可选 cp genfstab /usr/bin/
./genfstab / > /etc/fstab
nano /etc/fstab #最好检查下此文件,删掉无用挂载点
```  

## 14 安装一些必要工具并配置

```
emerge -av networkmanager app-admin/sysklogd sys-process/cronie sudo layman grub layman
sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
passwd #是时候设置root密码了
```
#### openRC(即非systemd)添加开机服务:
```
rc-update add NetworkManager default
rc-update add sysklogd default
rc-update add cronie default
```

## 15 安装GRUB并创建用户
#### GRUB
```
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Gentoo
grub-mkconfig -o /boot/grub/grub.cfg
```
#### 用户
```
useradd -m -G users,wheel,portage,usb,video 这里换成你的用户名(小写)
passwd 用户名
```

## 16 显卡驱动
Intel单显卡:  
```emerge -av x11-drivers/xf86-video-intel```

## 17 检查系统可用性
1.boot目录是否有相应文件
2.GRUB是否正确生成配置并显示内核等文件
3.fstab是否正确无误
4.重启

## 18 安装桌面
#### 如果前面没问题就可以安装桌面了 

首先需要确保已安装xorg-server和显卡驱动:  
```
emerge -av xorg-server
emerge xf86-video-intel #Intel显卡驱动
```

#### KDE:
```emerge -av plasma-desktop plasma-nm plasma-pa sddm konsole```

#### i3wm 
```emerge -av i3-gaps app-misc/ranger media-gfx/feh x11-misc/i3blocks x11-misc/i3lock x11-misc/i3lock-color x11-misc/i3status x11-misc/compton media-gfx/imagemagick x11-misc/rofi```

openrc则编辑/etc/conf.d/xdm将DISPLAYMANAGER的值改为sddm并:  
```rc-update add xdm default```

#### 重启进入sddm登入
