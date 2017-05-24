#!/bin/bash -
#
# *************************************************************************
#   > File Name: linuxbackup.sh
#   > Author: zosy
#   > Created Time: Tue 06 Dec 2016 09:40:17 PM CST
# *************************************************************************
#
# let count++
# eq(=),
# query-replace-regexp any numbers abc[0-9]\{1,\}
# nvidia tearing problem
  # add Option         "metamodes" "DVI-I-1: nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }, DVI-D-0: nvidia-auto-select +1920+0 { ForceFullCompositionPipeline = On }" to Section "Screen"

# net dev name wlan0/eth0
  #1. add net.ifnames=0 biosdevname=0 to /etc/default/grub
  #2. grub2-mkconfig -o /boot/grub2/grub.cfg

# disable nouveau and  change terminal console resolution and open intel VT-D
  #1. add rdblacklist=nouveau to /etc/default/grub
  #2. add vga=0x34D to /etc/default/grub
  #3. add intel_iommu=on to /etc/default/grub 
  #4. grub2-mkconfig -o /boot/grub2/grub.cfg
  
# timedatectl
  # timedatectl set-time "YYYY-MM-DD HH:MM:SS"
  # timedatectl set-local-rtc 0
  # timedatectl set-timezone Asia/Shanghai
  # timedatectl set-ntp yes  #use local time
# ntpdate cn.pool.ntp.org

# vsftpd config begin
  #1. useradd -m -d /vault/ftp/zosyftp -s /sbin/nologin zosyftp
  #2. add chroot_local_user=YES
  #3. chroot_list_enable=YES
  #4. chroot_list_file=/etc/vsftpd/chroot_list
  #5. allow_writeable_chroot=YES
  #6. uncomment local_enable=YES
  #7. write_enable=YES
  #8. touch /etc/vsftpd/chroot_list
  #9. sestatus -b| grep ftp
  #10. setsebool -P ftp_home_dir 1
  #11. setsebool -P ftpd_full_access 1 
  #12. systemctl restart vsftpd
  #13. firewall-cmd --add-service=ftp --permanent
  #14. firewall-cmd --reload
# fcitx
  #1.imsettings-switch fcitx
  #2.settings set org.gnome.settings-daemon.plugins.keyboard active false
  #3.gtk-query-immodules-2.0-64 >/lib64/gtk-2.0/2.10.0/immodules.cache

# rpmbuild
  #1.rpmbuild --rebuild --clean smplayer-16.7.0-1.fc24.src.rpm

# dnf
  #1. rm -rf /etc/yum.repos.d/epel*
  #2. try install epel via dnf
  #3. dnf clean all dnf install epel-release

# xdg-user-dir
#1./usr/bin/xdg-user-dirs-update

# compile emacs
#1.emacs -Q --batch -L . -f batch-byte-compile company.el company-*.el

# compile wireshark
 #1.make rpm-package
 #2.groupadd  wireshark
 #3.usermod -aG wireshark username
 #4.chgrp wireshark /usr/local/bin/dumpcap
#5.chmod 4750 /usr/local/bin/dumpcap

# efibootmgr
 #1.efibootmgr -b 0001 -B #delete boot item
# cinnamon icon alert
 #1.gsettings reset org.cinnamon.desktop.interface icon-theme
# resize2fs 
#1.resize2fs /dev/sdb4

#grub2 password
#1.add this to /etc/grub.d/00_head
# cat <<EOF
# set superusers="zosy"
# password_pbkdf2 zosy generate-passwd-by-grub2-mkpasswd-pbkdf2 
# EOF
#2.grub2-mkconfig -o /boot/grub2/grub.cfg

#about qt5 style on archlinux
#1.echo  QT_QPA_PLATFORMTHEME=qt5ct >> /etc/environment 
#2.pacman -S qt5ct(qt5 style change tools)
#3.git clone https://aur.archlinux.org/qt5-styleplugins.git
#4.makepkg PKGBUILD
#5.pacman -U qt5-styleplugins-5.0.0-1-x86_64.pkg.tar.xz

#about mariadb on archlinux
#1.mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

#about fonts
#1.cd .fonts
#2.mkfontscale
#3.mkfontdir
#4.fc-cache -fv
#about YoucompleteMe
#1.git clone https://github.com/Valloric/YouCompleteMe.git
#2../install.py --clang-completer --system-libclang --tern-completer

#about icons
#1.gtk-update-icon-cache /usr/share/icons/hicolor/

#about hostname
#1.hostnamectl set-hostname name

#about obs-stuido can't quit in bad networks
#1.add 127.0.0.1    obsproject.com to /etc/hosts

#about smplayer
#1.make QMAKE=qmake-qt5

#about gnome-shell shotcuts
#1.gsettings get org.gnome.desktop.wm.preferences mouse-button-modifier
#2.gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier "<Alt>"

#set nemo instead of nautilus
#1.gsettings set org.gnome.desktop.background show-desktop-icons false
#2.gsettings set org.nemo.desktop show-desktop-icons true
#3.xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
#4.edit /etc/mime.types and carefully review if nothing is left of nautilus. If it is, replace it by nemo.

#set application no to autostart
#1.X-GNOME-Autostart-enabled=false

#hide user from login list
#1.create file /var/lib/AccountsService/users/<username>
#2.add
#[User]
#SystemAccount=true
#to /var/lib/AccountsService/users/<username>

#samba
#1.smbpasswd -a username
#2. chcon -t samba_share_t dir (very important!!!)

# gtk3 with compton border issue in i3
#add blows css style to ~/.config/gtk-3.0/gtk.css 
# .window-frame, .window-frame:backdrop {
#  box-shadow: 0 0 0 black;
#  border-style: none;
#  margin: 0;
#  border-radius: 0;
# }
#
# .titlebar {
#  border-radius: 0;
# }


os_release="centos"
backup_date=`date +%Y-%m-%d`
backup_opt_str=$1
compile_dir="/usr/src"
install_dir="/usr/local"
compile_result=""
backup_dir="/home/zosy/Documents/backup/os"
backup_dir_config="/home/zosy/Documents/backup/centos/config_file"
backup_dir_os="/home/zosy/Documents/backup/os/centos"
backup_dir_home="/home/zosy/Documents/backup/centos/home"
backup_dir_mysql="/home/zosy/Documents/backup/centos/mysql"
backup_dir_work="/home/zosy/Documents/backup/centos/work"
backup_dir_src="/home/zosy/Documents/backup/centos/src"
backup_dir_rpm="/home/zosy/Documents/backup/centos/rpm"
#source code dir array
source_code_array=(
1-obs/obs-studio-0.16.6
)
#modify sshd port
#semanage port -a -t ssh_port_t -p tcp port
#semanage port -l | grep ssh
#firewall-cmd --zone=public --add-port=port/tcp --permanent
function CurrentUserCheck()
{
    current_user=`whoami`
    if [ "$current_user"x != "root"x ]; then
        echo -e "\033[31mneed to be root!\033[0m"
        # set -e means quit terminal,here use exit.
        exit
    fi
}
function MessageBox()
{
    if [ "$3"x == "red"x ]; then
        echo -e "\n\033[31m$1 $2\033[0m\n"
    else
        echo -e "\n$1 $2"
    fi
}
# parameter must add "" while call the function!
# MessageBox "msg" "color" "other"
function MessageBoxResult()
{
    if [ $? -eq 0 ]; then
        MessageBox "$1" "complete."
    else
        MessageBox "$1" "faild!" "red"
    fi
}
function ZosyYumInstall()
{
    CurrentUserCheck
    yum makecache
    yum update
    yum install -y bind-utils NetworkManager opencl-headers NetworkManager-wifi \
    pciutils wget  xorg-x11-server-Xorg  lightdm qtcreator \
    cryptsetup gcc  kernel-devel xorg-x11-drv-evdev autoconf213 \
    gnome-terminal file-roller    redhat-lsb httpd gtk+-devel \
    gcc  httpd alsa-lib-devel pulseaudio-libs-devel libXScrnSaver \
    SDL-devel  SDL-devel gtk2-devel zlib-devel yasm openjpeg-devel  \
    extra-cmake-modules enchant libxml2-devel iso-codes libxkbfile-devel  \
    qt-devel gobject-introspection-devel qemu-kvm libvirt virt-install \
    bridge-utils virt-manager ncurses-devel libtiff-devel libXpm-devel \
    gdb ntp mariadb-devel transmission gimp filezilla libnotify-devel \
    dos2unix ftp vinagre evince jack-audio-connection-kit \
    libsamplerate-devel libsndfile-devel gvfs-afc libIDL-devel traceroute \
    gtk3-immodule-xim gtk2-immodule-xim traceroute gvfs-mtp cmake gtk3-devel \
    iso-codes-devel kde-filesystem qtwebkit-devel qtsingleapplication-devel \
    fribidi-devel goldendict xdg-user-dirs make mariadb-server vsftpd \
    qt5-qtbase-mysql gtkmm30-devel libcanberra-gtk3 jack-audio-connection-kit-devel \
    automake inkscape gimp alsa-plugins-pulseaudio gtkmm30-devel rpm-build \
    libsigc++20-devel mariadb-embedded-devel gnome-shell-extension-user-theme\
    intltool automake libcanberra-devel pulseaudio-libs-devel libvirt-daemon-kvm \
    qt-config xulrunner.i686 eog libXtst.i686 libpng12.i686 xdg-user-dirs gvfs-smb \
    boost-filesystem boost-regex tinyxml libzip python-paramiko  unixODBC libpqxx \
    gcc-c++ xorg-x11-utils libpcap-devel flex byacc bison c-ares-devel libvdpau \
    hdparm libconfig-devel asciidoc muffin-devel libsoup-devel GConf2-devel \
    cjs-devel NetworkManager-glib-devel polkit-devel libgnome-keyring-devel \
    colord colord-devel libgnomekbd-devel xkeyboard-config-devel pam-devel \
    gtk-doc gtksourceview3-devel mate-screenshot libjpeg-turbo-devel texinfo \
    giflib-devel qt5-qttools-devel qt5-qtscript-devel npm mtr python34-devel \
    webkitgtk3-devel python2-devel libacl-devel liblockfile-devel  gpm-devel \
    m17n-lib-devel librsvg2-devel gnutls-devel libXdmcp-devel nodejs iftop \
    libcurl-devel qt5-qtx11extras-devel libv4l-devel qt5-linguist irssi mutt nmap \
    libnl-devel mercurial gtk-murrine-engine wireshark-gnome hexchat samba \
    gtk-murrine-engine  readline-devel qtsingleapplication-qt5-devel \
    php-mysql fuse-devel xdotool wmctrl  OpenImageIO libGLEW openjpeg2-devel \
    libbluray-devel libgcrypt-devel qt5-qtmultimedia-devel gnome-common pcre \
    gnome-doc-utils libass-devel gmp-devel clang ImageMagick-devel qt5-qtwebkit-devel \
    libotf-devel iotop  tree iotop dejavu-sans-mono-fonts quazip-devel \
    php libcanberra-gtk3 centos-bookmarks libxkbcommon-devel doxygen enchant-devel \
    opencc-devel lua-devel lm_sensors glade dconf-editor sudo xcb-util-keysyms-devel \
    xcb-util-devel  yajl-devel libXrandr-devel startup-notification-devel libev-devel \
    xcb-util-cursor-devel libXinerama-devel  libxkbcommon-x11-devel pcre-devel pango-devel \
    xcb-util-wm-devel xorg-x11-util-macros  imlib2-devel glm-devel unique imsettings \
    rxvt-unicode-256color libXtst-devel hunspell-devel libvorbis-devel phonon-devel \
    lzo-devel eb-devel iw wireless-tools polkit-gnome libxfce4util-devel libxfce4ui-devel \
    thunar vim-X11 pavucontrol xorg-x11-server-Xephyr i3lock ffmpegthumbnailer-devel ffmpeg-devel
}
function InitSomeServices()
{
#add user to wireshark group
    usermod -a -G wireshark zosy
#add samba user
    useradd -m -d /vault/zosysmb -s /sbin/nologin zosysmb
    passwd zosysmb
    smbpasswd -a zosysmb
#add vsftp user
    useradd -m -d /vault/ftp/zosyftp -s /sbin/nologin zosyftp
    passwd zosyftp
#samba
    mv /etc/samba/smb.conf /etc/samba/smb.conf.back
    cp $backup_dir_config/smb.conf /etc/samba/
#vsftp
    mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.backup
    cp $backup_dir_config/vsftpd.conf /etc/vsftpd/
    cp $backup_dir_config/zosyftp /var/lib/AccountsService/users
    cp $backup_dir_config/zosysmb /var/lib/AccountsService/users
#selinux   sestatus -b | grep ftp
    setsebool -P ftpd_full_access 1
    chcon -t samba_share_t /vault/zosysmb
    systemctl restart vsftpd
    systemctl restart smb
#firewall
    firewall-cmd --zone=public --add-service=ftp --permanent
    firewall-cmd --zone=public --add-service=samba --permanent
    firewall-cmd --reload
#account search and unrar
    cp $backup_dir/binary/accountsearch /usr/local/bin
    cp $backup_dir/binary/unrar /usr/local/bin
#hosts
    if [ `grep 'obsproject.com' /etc/hosts` -lt 1 ]; then
        echo "127.0.0.1       obsproject.com" >> /etc/hosts
    fi
#repos
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
    mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
}
function DisableUnnecessaryServices()
{
    CurrentUserCheck
    systemctl disable bluetooth
    systemctl disable cups
    systemctl disable postfix
    systemctl disable teamviewerd
    #google-chrome service
    systemctl disable atd
    MessageBoxResult "disable unnecessary service"
}
function UninstallUnnecessarySoft()
{
    CurrentUserCheck
    yum autoremove ibus nautilus tracker cheese totem empathy \
    gnome-software gnome-weather ekiga rhythmbox gnome-dictionary \
    gnome-online-accounts
    MessageBoxResult "remove unnecessary soft "
}
#mplayer codecs path
function RestorCodecs()
{
    if [ ! -d /usr/local/lib/codecs ]; then
        echo -e "copying codecs...\n"
        cp -r $backup_dir/codecs /usr/local/lib/
        MessageBoxResult "cp codecs"
    fi
}
#compile category
function NormalConfigure()
{
# unuse
    # ./configure --prefix=$compile_dir
    echo -e "not finish yet"
}
function CmakeConfigure()
{
    echo -e "not finish yet"
}
function DoExport()
{
    export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/pkgconfig
}
function Reldconfig()
{
    if [ `grep  '/usr/local/lib' /etc/ld.so.conf | wc -l` -lt 1 ]; then 
        echo "/usr/local/lib" >> /etc/ld.so.conf
        ldconfig 
    fi
    if [ `grep  '/usr/local/lib64' /etc/ld.so.conf | wc -l` -lt 1 ]; then 
        echo "/usr/local/lib64" >> /etc/ld.so.conf
        ldconfig
    fi
}
function FcitxConfig()
{
    cp $backup_dir/fcitx/fcitx.conf /etc/X11/xinit/xinput.d/
    MessageBoxResult "cp fcitx.conf to /etc/X11/xinit/xinitrc.d/"
    rm -rf /etc/alternatives/xinputrc
    ln -s  /etc/X11/xinit/xinitrc.d/fcitx.conf /etc/alternatives/xinputrc
    MessageBoxResult "ln /etc/alternatives/xinputrc"
    if [ `grep 'fcitx' /usr/lib64/gtk-2.0/2.10.0/immodules.cache | wc -l` -lt 1 ]; then
        gtk-query-immodules-2.0-64 /usr/local/lib/gtk-2.0/2.10.0/immodules/im-fcitx.so \
        >> /usr/lib64/gtk-2.0/2.10.0/immodules.cache
    fi
    if [ `grep 'fcitx' /usr/lib64/gtk-3.0/3.0.0/immodules.cache | wc -l` -lt 1 ]; then
        gtk-query-immodules-3.0-64 /usr/local/lib/gtk-3.0/3.0.0/immodules/im-fcitx.so \
        >> /usr/lib64/gtk-3.0/3.0.0/immodules.cache
    fi
}
function ZosyBackupSystem()
{
    CurrentUserCheck
    time tar -zvcpf $backup_dir_os/$os_release-$backup_date.tar.gz / \
    --exclude-from=/home/zosy/Documents/backup/system_tar_exclude.list
    MessageBoxResult "system bakcup"
}
function ZosyRestoreSystem()
{
    CurrentUserCheck
    ls $backup_dir_os
    echo -n "type the date when you want to restore:"
    read os_date_select
    if [ -f $backup_dir_os/$os_release-$date_select.tar.gz ];then
        tar -zxvpf $backup_dir_os/$os_release-$os_date_select.tar.gz -C /
        MessageBoxResult "system restore"
        # restore Selinux privilege, you can't login system if you don't do this.
        restorecon -Rv /
    else
        echo -e "\033[31m$os_release-$os_date_select.tar.gz doesn't exist!\033[0m"
    fi
}
function ZosyBackupHome()
{
    time tar -zcvpf $backup_dir_home/homebackup-$backup_date.tar.gz \
    .vimrc .vim .emacs .emacs.d .icons .themes .zosy_shell .mplayer .bashrc \
    .bash_profile .Xresources .local/share/gnome-shell .local/share/themes \
    .fonts .config/autostart .config/obs-studio .local/share/vinagre .goldendict \
    -C /home/zosy 
    MessageBoxResult "home backup"
}
function ZosyRestoreHome()
{
    ls $backup_dir_home
    echo -n "type the date:"
    read home_date_select
    if [ -f $backup_dir_home/homebackup-$home_date_select.tar.gz ]; then
        tar -zxvpf $backup_dir_home/homebackup-$home_date_select.tar.gz -C /home/zosy/ 
        MessageBoxResult "home restore"
    else
        echo -e "\033[31mhomebackup-$home_date_select.tar.gz doesn't exist!\033[0m"
    fi
}
function ZosyBackupMysql()
{
    mysql_check=`ps -ef | grep mysql | grep -v grep | wc -l`
    if [ $mysql_check -gt 0 ]; then
        mysqldump -uroot -p zosy > $backup_dir_mysql/zosy_mysql_backup-$backup_date.sql
        MessageBoxResult "backup mysql"
    else
        echo -e "\033[31mmysql inactive! \033[0m\n"
    fi
}
function ZosyRestoreMysql()
{
    mysql_check=`ps -ef | grep mysql | grep -v grep | wc -l`
    if [ $mysql_check -gt 0 ]; then
        ls $backup_dir_mysql
        echo -n "type date: "
        read mysql_date_select
        if [ -f $backup_dir_mysql/zosy_mysql_backup-$mysql_date_select.sql ]; then
            mysql -uroot -p zosy < $backup_dir_mysql/zosy_mysql_backup-$mysql_date_select.sql
            MessageBoxResult " mysql restore"
        else
            echo -e "\033[31m zosy_mysql_backup-$mysql_date_select.sql doesn't exist! \033[0m"
        fi
    else
        echo -e "\033[31mmysql inactive! \033[0m\n"
    fi
}
function ZosyBackupWork()
{
    time tar -zcvpf $backup_dir_home/workbackup-$backup_date.tar.gz \
    Documents/work -C /home/zosy 
    MessageBoxResult " work backup"
}
function ZosyBackupSource()
{
    CurrentUserCheck
    tar -zcPpvf $backup_dir_src/src-$backup_date.tar.gz /usr/src \
    --exclude=debug --exclude=kernels --exclude=include \
    --exclude=lib --exclude=nvidia* 
    MessageBoxResult "backup source code"
}
function ZosyRestoreSource()
{
    ls $backup_dir_src
    echo -n "type the date:"
    read src_date_select
    if [ -f $backup_dir_src/src-$src_date_select.tar.gz ]; then
        tar -zxPpvf $backup_dir_src/src-$src_date_select.tar.gz 
        MessageBoxResult "src restore"
    else
        echo -e "\033[31msrc-$src_date_select.tar.gz doesn't exist!\033[0m"
    fi
}    
function ZosyCompile()
{
    CurrentUserCheck
    if [ -d $compile_dir ]; then
        for i in "${!source_code_array[@]}"
        do
            case ${source_code_array[$i]} in
            *x265*) 
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    cmake source/
                    ;;
            *xvidcore*)
                    cd $compile_dir/${source_code_array[$i]}/build/generic
                    DoExport
                    ./configure --prefix=$install_dir
                    ;;
            *ffmpeg-3*)
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    ./configure --prefix=$install_dir \
                    --enable-gpl \
                    --enable-version3 \
                    --disable-shared \
                    --disable-debug \
                    --enable-runtime-cpudetect \
                    --enable-libfaac \
                    --enable-nonfree \
                    --enable-libmp3lame \
                    --enable-libx264 \
                    --enable-libx265 \
                    --enable-libvorbis \
                    --enable-libxvid \
                    --enable-libwebp \
                    --enable-libspeex \
                    --enable-libvorbis \
                    --enable-libvpx \
                    --enable-libfreetype \
                    --enable-fontconfig \
                    --enable-libopencore-amrnb \
                    --enable-libopencore-amrwb \
                    --enable-libtheora \
                    --enable-libvo-amrwbenc \
                    --enable-gray \
                    --enable-libopenjpeg \
                    --enable-libopus \
                    --enable-libass \
                    --enable-gnutls \
                    --enable-libvidstab \
                    --enable-libsoxr \
                    --enable-frei0r \
                    --enable-libfribidi
                    ;;  
            *obs*)
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    if [ ! -d build ]; then
                        mkdir build 
                    fi
                    cd build
                    cmake3 -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=/usr/local ..
                    ;;
            *ffmpegthumbnailer*)
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_GIO=ON -DENABLE_THUMBNAILER=ON .
                    ;;
            *nemo*)
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    ./autogen.sh
                    ./configure --prefix=$install_dir
                    ;;
            *fileroller*)
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    ./autogen.sh
                    ./configure --prefix=$install_dir
                    ;;
            *fcitx-4.2.9*)
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    if [ ! -d build ]; then
                        mkdir build 
                    fi
                    cd build
                    cmake3 .. -DCMAKE_INSTALL_PREFIX=$install_dir -DENABLE_GTK3_IM_MODULE=On \
                    -DENABLE_QT_IM_MODULE=On -DENABLE_OPENCC=On -DENABLE_LUA=On -DENABLE_GIR=On \
                    -DENABLE_XDGAUTOSTART=Off -DENABLE_PINYIN=Off
                    ;;
            *fcitx-configtool*)
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    if [ ! -d build ]; then
                        mkdir build 
                    fi
                    cd build
                    cmake3 .. -DCMAKE_INSTALL_PREFIX=$install_dir
                    ;;
            *fcitx-qt5*)
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    if [ ! -d build ]; then
                        mkdir build 
                    fi
                    cd build
                    cmake3 .. -DCMAKE_INSTALL_PREFIX=$install_dir
                    ;;
            *) 
                    cd $compile_dir/${source_code_array[$i]}/
                    DoExport
                    if [ "${source_code_array[$i]}"x == "11-mplayer/MPlayer-1.3.0"x ]; then
                        ./configure --prefix=$install_dir 
                    else
                        ./configure --prefix=$install_dir --enable-shared
                    fi
                    ;;
            esac
            softname=${source_code_array[$i]}
            make -j12 
            make install
            if [ $? -eq 0 ]; then
                # first loop add \n
                if [ $i -eq 0 ]; then
                    compile_result="\\n$compile_result $softname compile ok\\n"
                    Reldconfig
                else
                    compile_result="$compile_result $softname compile ok\\n"
                    if [ "${source_code_array[$i]}"x == "15-fcitx/fcitx-4.2.9"x ]; then
                        FcitxConfig           
                    fi
                fi 
                echo -e "$compile_result"
                sleep 3
            else
                compile_result="$compile_result\033[31m $softname compile failed \033[0m \\n"
                echo -e "$compile_result"
                echo -n -e "compile failed, countinue?[y/n]: "
                read is_continue
                if [ "$is_continue"x == "y"x ] || [ "$is_continue"x == "yes"x ]; then
                    echo -e "continuing"
                else
                    break
                fi
            fi
        done
        ldconfig
        RestorCodecs
    else
        echo -e "\033[31mcompile dir doesn't exist!\033[0m"
    fi
}
#main 
# version 2.1.0 on github
echo -e "backup script v2.0.8\n"
echo -e "1) system backup"
echo -e "2) system restore"
echo -e "3) home backup"
echo -e "4) home restore"
echo -e "5) mysql backup" 
echo -e "6) mysql restore" 
echo -e "7) yum install"
echo -e "8) compile soft install"
echo -e "9) disable unnecessary services"
echo -e "10) remove unnecessary software"
echo -e "11) init vsftp samba service" 
echo -e "12) work backcup"
echo -e "13) source code backup"
echo -e "14) source code restore"
echo -e "15) ALL\n"
echo -n -e "select some number: "

read  linuxbackup_cmd_select
for i in $linuxbackup_cmd_select; do
        case $i in
            1)  ZosyBackupSystem;;
            2)  ZosyRestoreSystem;;
            3)  ZosyBackupHome;;
            4)  ZosyRestoreHome;;
            5)  ZosyBackupMysql;;
            6)  ZosyRestoreMysql;;
            7)  ZosyYumInstall;;
            8)  ZosyCompile;;
            9)  DisableUnnecessaryServices;;
            10) UninstallUnnecessarySoft;;
            11) InitSomeServices;;
            12) ZosyBackupWork;;
            13) ZosyBackupSource;;
            14) ZosyRestoreSource;;
            *) 	echo -e "\033[31m$i is invalid number ! \033[0m";;
        esac
done
#481
