#!/bin/bash
#
# Author: Aniverse
# https://github.com/Aniverse/inexistence
#
#
# https://github.com/FunctionClub/YankeeBBR
# https://sometimesnaive.org/article/linux/bash/tcp_nanqinlang
# https://moeclub.org/2017/06/06/249/
# https://moeclub.org/2017/03/08/14/
# https://www.94ish.me/1635.html
# http://xiaofd.win/onekey-ruisu.html
# https://teddysun.com/489.html

ScriptVersion=1.0
ScriptDate=2018.03.15

# 颜色 -----------------------------------------------------------------------------------

black=$(tput setaf 0); red=$(tput setaf 1); green=$(tput setaf 2); yellow=$(tput setaf 3);
blue=$(tput setaf 4); magenta=$(tput setaf 5); cyan=$(tput setaf 6); white=$(tput setaf 7);
on_red=$(tput setab 1); on_green=$(tput setab 2); on_yellow=$(tput setab 3); on_blue=$(tput setab 4);
on_magenta=$(tput setab 5); on_cyan=$(tput setab 6); on_white=$(tput setab 7); bold=$(tput bold);
dim=$(tput dim); underline=$(tput smul); reset_underline=$(tput rmul); standout=$(tput smso);
reset_standout=$(tput rmso); normal=$(tput sgr0); alert=${white}${on_red}; title=${standout};
baihuangse=${white}${on_yellow}; bailanse=${white}${on_blue}; bailvse=${white}${on_green};
baiqingse=${white}${on_cyan}; baihongse=${white}${on_red}; baizise=${white}${on_magenta};
heibaise=${black}${on_white};
shanshuo=$(tput blink); wuguangbiao=$(tput civis); guangbiao=$(tput cnorm)

#  -----------------------------------------------------------------------------------

SysSupport=0
KernelBit=` getconf LONG_BIT `
DISTRO=`  awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release | tr 'A-Z' 'a-z'  `
DISTROU=`  awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release  `
CODENAME=`  cat /etc/os-release | grep VERSION= | tr '[A-Z]' '[a-z]' | sed 's/\"\|(\|)\|[0-9.,]\|version\|lts//g' | awk '{print $2}'  `
[[ $DISTRO == ubuntu ]] && osversion=`  grep -oE  "[0-9.]+" /etc/issue  `
[[ $DISTRO == debian ]] && osversion=`  cat /etc/debian_version  `
[[ $CODENAME =~ ("xenial"|"jessie"|"stretch") ]] && SysSupport=1

#  -----------------------------------------------------------------------------------

[[ $EUID -ne 0 ]] && echo -e "\n${red}错误${normal}${bold} 请使用 root 运行本脚本！${normal}" && exit 1
[[ -d /proc/vz ]] && echo -e "\n${red}错误${normal}${bold} 不支持 OpenVZ！${normal}" && exit 1
[[ ! $KernelBit == 64 ]] && echo -e "\n${red}错误${normal}${bold} 不支持非 64 位系统！${normal}" && exit 1
[[ -z "$(dpkg -l |grep 'grub-')" ]] && echo "\n${red}错误${normal}${bold} 未发现 grub！${normal}" && exit 1
[[ ! $SysSupport == 1 ]] && echo "\n${red}错误${normal}${bold} 不支持 Debian 8、Debian 9、Ubuntu 16.04 以外的系统！${normal}" && exit 1

# 菜单
function _menu() { clear ; echo

# 操作系统、内核等参数检测
[ -f /etc/redhat-release ] && KNA=$(awk '{print $1}' /etc/redhat-release)
[ -f /etc/os-release ] && KNA=$(awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release)
[ -f /etc/lsb-release ] && KNA=$(awk -F'[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release)
tcp_control=` sysctl net.ipv4.tcp_available_congestion_control | awk '{print $3}' `
running_kernel=` uname -r `
arch=$( uname -m )
lbit=$( getconf LONG_BIT )

[[ $tcp_control == "cubic" ]] && tcp_c_name="cubic (系统默认算法)"
[[ $tcp_control == "bbr" ]] && tcp_c_name="bbr (原版 BBR)"
[[ $tcp_control == "bbr_powered" ]] && tcp_c_name="bbr_powered (Vicer 脚本版 魔改 BBR)"
[[ $tcp_control == "tsunami" ]] && tcp_c_name="tsunami (Yankee 版 魔改 BBR)"
[[ $tcp_control == "nanqinlang" ]] && tcp_c_name="nanqinlang (南琴浪 版 魔改 BBR)"

# 检查理论上内核是否支持锐速
SSKernel="${red}否${white}"
URLKernel='https://raw.githubusercontent.com/0oVicero0/serverSpeeder_kernel/master/serverSpeeder.txt'
AcceVer=$(wget --no-check-certificate -qO- "$URLKernel" |grep "$KNA/" |grep "/x$KernelBit/" |grep "/$running_kernel/" |awk -F'/' '{print $NF}' |sort -n -k 2 -t '_' |tail -n 1)
MyKernel=$(wget --no-check-certificate -qO- "$URLKernel" |grep "$KNA/" |grep "/x$KernelBit/" |grep "/$running_kernel/" |grep "$AcceVer" |tail -n 1)
[[ ! -z "$MyKernel" ]] && SSKernel="${green}是${white}"

# 检查理论上内核是否支持原版 BBR
function version_ge(){ test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1" ; }
kernel_vvv=$(uname -r | cut -d- -f1)
if version_ge ${kernel_vvv} 4.9  ; then BBRKernel="${green}是${white}" ; else BBRKernel="${red}否${white}" ; fi
if version_ge ${kernel_vvv} 4.10 && ! version_ge ${kernel_vvv} 4.13 ; then YKKernel="${green}是${white}" ; else YKKernel="${red}否${white}" ; fi
if version_ge ${kernel_vvv} 4.10 && ! version_ge ${kernel_vvv} 4.16 ; then NQLKernel="${green}是${white}" ; else NQLKernel="${red}否${white}" ; fi

# 检查 锐速 与 BBR 是否已启用
[[ ` ps aux | grep appex | grep -v grep ` ]] && SSrunning="${green}是${white}" || SSrunning="${red}否${white}"
export tcp_control=$(sysctl net.ipv4.tcp_available_congestion_control | awk '{print $3}')
if [[ $tcp_control =~ ("nanqinlang"|"tsunami") ]]; then bbrinuse="${green}是${white}"
elif [[ `echo $tcp_control | grep bbr` ]]; then bbrinuse="${green}是${white}"
else bbrinuse="${red}否${white}" ; fi

dpkg -l | grep linux-image   | awk '{print $2}' >> /tmp/system_kernel_list
dpkg -l | grep linux-headers | awk '{print $2}' >> /tmp/system_kernel_list

echo -e  " ${baizise}${bold}                                   El Psy Congroo!                                   ${normal} "
echo -e  "  ${bold}${white}"
echo -e  "  当前操作系统                         ${green}$DISTROU $osversion $CODENAME (x$lbit)${white}"
echo -e  "  当前正在使用的 TCP 拥塞控制算法      ${green}$tcp_c_name${white}"
echo -e  "  当前正在使用的系统内核               ${green}$running_kernel${white}"
echo -e  "  当前 BBR  是否已启用                 $bbrinuse"
echo -e  "  当前内核是否支持 原版 BBR            $BBRKernel"
echo -e  "  当前内核是否支持 Yankee 版魔改 BBR   $YKKernel"
echo -e  "  当前内核是否支持 南琴浪 版魔改 BBR   $NQLKernel"
echo -e  "  当前内核是否支持 Vicer  版锐速       $SSKernel"
echo -e  "  当前 锐速 是否已启用                 $SSrunning"

echo -e  "\n  当前系统内所有已安装的内核列表\n"
cat -n /tmp/system_kernel_list | sed 's/\t/ /g' | sed "s/ linux-/) ${green}linux-/g" | sed "s/     /  ${magenta}(0/g" | sed "s/    /  ${magenta}(/g"
echo -e  "\n  ${yellow}${bold}使用本脚本前请先阅读本脚本 GitHub 上的 README；作者水平菜，不保证脚本不会翻车${normal}\n"

echo -e  "  ${green}(01) ${white}安装 原版 BBR"
echo -e  "  ${green}(02) ${white}安装 魔改 BBR (tsunami)"
echo -e  "  ${green}(03) ${white}安装 魔改 BBR (nanqinlang)"
echo -e  "  ${green}(04) ${white}安装 锐速"
echo -e  "  ${green}(21) ${white}卸载 BBR"
echo -e  "  ${green}(22) ${white}卸载 锐速"
# echo -e  "  ${green}(11) ${white}安装 最新内核"
# echo -e  "  ${green}(12) ${white}安装 指定内核"
# echo -e  "  ${green}(13) ${white}安装 锐速内核"
echo -e  "  ${green}(99) ${white}返回\n"
rm -rf /tmp/system_kernel_list ; }






# action
function _read_response() {
echo -ne "  ${yellow}你想做什么？(默认返回) ${normal} " ; read -e response
case $response in
    1 | 01) # 安装 原版 BBR
            _obbr_install ;;
    2 | 02) # 安装 魔改 BBR (Yankee)
            _ykbbr_install ;;
    3 | 03) # 安装 魔改 BBR (nanqinlang)
            _nqlbbr_install ;;
    4 | 04) # 安装 锐速
            _ss_install ;;
        21) # 卸载 BBR
            _bbr_uninstall ;;
        22) # 卸载 锐速
            _ss_uninstall ;;
    99 |"") # 返回
            echo ; exit 0 ;;
         *) echo ; exit 0 ;;
esac ; }






###################################################################################################################################################################





# 安装 原版 BBR
function _obbr_install() {

[[ `grep "Advanced options for Ubuntu" /etc/default/grub` ]] && sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=""/' /etc/default/grub

if [[ $BBRKernel == "${green}是${white}" ]]; then
    echo -e "\n${bold}${white}理论上当前内核已支持 ${green}原版 BBR${white}，不安装新内核，直接启用 BBR ...${normal}"
    bbrname=bbr
    _enable_bbr
    if [[ ` sysctl net.ipv4.tcp_available_congestion_control | awk '{print $3}' ` == bbr ]]; then echo -e "\n${bold}${white}BBR 已启用 ...\n${normal}"
    else echo -e "\n${bold}${red}错误 ${white}BBR 开启失败！${normal}\n" ; exit 1 ; fi
else
    echo -e "\n${bold}${white}当前内核不支持 BBR，需要安装 ${green}4.11.12${white} 内核以启用 BBR ...${normal}"
    _online_ubuntu_bbr_firmware
    _bbr_kernel_4_11_12
    bbrname=bbr
    _enable_bbr
    echo -e "\n${bold}${white}即将重启系统，重启后 ${green}BBR${white} 将会启动 ... ${normal}\n"
    reboot
fi ; }


# 安装 Yankee版魔改 BBR
function _ykbbr_install() {

[[ `grep "Advanced options for Ubuntu" /etc/default/grub` ]] && sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' /etc/default/grub

if [[ $YKKernel == "${green}是${white}" ]]; then
    echo -e "\n${bold}${white}理论上当前内核已支持 ${green}Yankee${white} 版魔改 BBR，安装并启用魔改 BBR ...${normal}"
    _check_essential
    _bbr_tsunami
    bbrname=tsunami
    _enable_bbr
    if [[ ` sysctl net.ipv4.tcp_available_congestion_control | awk '{print $3}' ` == tsunami ]]; then echo -e "\n${bold}${white}已开启 ${green}Yankee 版魔改 BBR${white} ...${normal}\n"
    else echo -e "\n${bold}${red}错误 ${green}Yankee 版魔改 BBR${white} 开启失败！${normal}\n" ; exit 1 ; fi
else
    echo -e "\n${bold}${white}当前内核不支持 ${green}Yankee${white} 版魔改 BBR，需要安装 ${green}4.11.12${white} 内核 ...${normal}"
    _online_ubuntu_bbr_firmware
    _check_essential
    _bbr_kernel_4_11_12
    kernel_version=4.11.12 && _delete_kernel
    [[ $CODENAME == stretch ]] && _stretch_enable_rclocal
    _bbr_tsunami_autoinstall_after_reboot
    bbrname=tsunami
    _enable_bbr
    echo -e "\n${bold}${white}即将重启系统，重启后会自动安装 ${green}Yankee${white} 版魔改 BBR ... ${normal}\n"
    reboot
fi ; }



# 安装 南琴浪版魔改 BBR
function _nqlbbr_install() {

[[ `grep "Advanced options for Ubuntu" /etc/default/grub` ]] && sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=""/' /etc/default/grub

if [[ $YKKernel == "${green}是${white}" ]]; then
    echo -e "\n${bold}${white}理论上当前内核已支持 ${green}南琴浪 版魔改 BBR，安装并启用魔改 BBR ...${normal}"
    _check_essential
    _bbr_nanqinlang
    bbrname=nanqinlang
    _enable_bbr
    if [[ ` sysctl net.ipv4.tcp_available_congestion_control | awk '{print $3}' ` == nanqinlang ]]; then echo -e "\n${bold}${white}已开启 ${green}南琴浪 版魔改 BBR${white} ...${normal}\n"
    else echo -e "\n${bold}${red}错误 ${green}南琴浪 版魔改 BBR${white} 开启失败！${normal}\n" ; exit 1 ; fi
else
    echo -e "\n${bold}${white}当前内核不支持 ${green}南琴浪${white} 版魔改 BBR，需要安装 ${green}4.11.12${white} 内核 ...${normal}"
    _online_ubuntu_bbr_firmware
    _check_essential
    _bbr_kernel_4_11_12
    kernel_version=4.11.12 && _delete_kernel
    [[ $CODENAME == stretch ]] && _stretch_enable_rclocal
    _bbr_nanqinlang_autoinstall_after_reboot
    bbrname=nanqinlang
    _enable_bbr
    echo -e "\n${bold}${white}即将重启系统，重启后会自动安装 ${green}南琴浪${white} 版魔改 BBR ... ${normal}\n"
    reboot
fi ; }



# 安装 锐速
function _ss_install() {
if [[ $SSKernel == "${green}是${white}" ]]; then
    echo -e "\n${bold}${white}理论上当前内核已支持 ${green}锐速${white}，直接安装锐速 ... ${normal}\n"
    _serverspeeder_direct_install
elif [[ $SSKernel == "${red}否${white}" ]] && [[ $DISTRO == ubuntu ]]; then
    echo -e "\n${bold}${white}当前内核不支持 锐速，安装 ${green}3.16.0-43${white} 内核 ... ${normal}\n"
    kernelver=3.16.0-43-generic
    _ubuntu_serverspeeder_kernel_repo
    _ubuntu_serverspeeder_updategrub
    _serverspeeder_autoinstall_after_reboot
    echo -e "\n${bold}${white}即将重启系统，重启后会自动安装锐速 ... ${normal}\n"
    reboot
elif [[ $SSKernel == "${red}否${white}" ]] && [[ $CODENAME == jessie ]]; then
    echo -e "\n${bold}${white}当前内核不支持 锐速，安装 ${green}3.12.1${white} 内核 ... ${normal}\n"
    kernel_version=3.12-1
    _debian_serverspeeder_kernel_312
    _delete_kernel
    _serverspeeder_autoinstall_after_reboot
    echo -e "\n${bold}${white}即将重启系统，重启后会自动安装锐速 ... ${normal}\n"
    reboot
elif [[ $SSKernel == "${red}否${white}" ]] && [[ $CODENAME == stretch ]]; then
    echo -e "\n${bold}${white}当前内核不支持 锐速，安装 ${green}3.16.0-4${white} 内核 ... ${normal}\n"
    kernel_version=3.16.0-4
    _debian_serverspeeder_kernel_316
    _delete_kernel
    _stretch_enable_rclocal
    _serverspeeder_autoinstall_after_reboot
    echo -e "\n${bold}${white}即将重启系统，重启后会自动安装锐速 ... ${normal}\n"
    reboot
fi ; }



# 卸载 锐速
function _ss_uninstall() {
echo -ne "\n  ${bold}${red}警告 ${white}即将开始卸载 ${green}锐速${white}，敲 回车 继续，否则退出${normal} " ; read input
case $input in
    "" ) echo ;;
    *  ) echo ; _read_response ;;
esac
[[ `grep "Advanced options for Ubuntu" /etc/default/grub` ]] && sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=""/' /etc/default/grub && update-grub > /dev/null 2>&1
wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && echo | bash /tmp/appex.sh 'uninstall'
echo -e "${bold}${red}已卸载 锐速，但安装的内核仍保留${normal}\n" ; }


# 卸载 BBR
function _bbr_uninstall() {
echo -ne "\n  ${bold}${red}警告 ${white}即将开始卸载 ${green}BBR${white}，敲 回车 继续，否则退出${normal} " ; read input
case $input in
    "" ) echo ;;
    *  ) echo ; _read_response ;;
esac
tcp_control=` sysctl net.ipv4.tcp_available_congestion_control | awk '{print $3}' `
if [[ $tcp_control =~ ("nanqinlang"|"tsunami"|"bbr"|"bbr_powered") ]]; then bbrname=$tcp_control ; _disable_bbr ; echo -e "${bold}${red}已卸载 BBR，但安装的内核仍保留${normal}\n"
else echo -e "${bold}${red}错误 ${white}你并没有使用本脚本安装 BBR ...${normal}\n" ; _read_response ; fi ; }






###################################################################################################################################################################






# 重启后自动安装 南琴浪 版 BBR
function _bbr_nanqinlang_autoinstall_after_reboot() {

mkdir -p /etc/autoinstall
[[ ! -f /etc/rc.local.bak ]] && cp /etc/rc.local /etc/rc.local.bak

cat > /etc/autoinstall/nqlbbr.sh <<EOF
ver_4_13=\`dpkg -l | grep linux-image | awk '{print \$2}' | awk -F '-' '{print \$3}' | grep "4.13"\`
ver_4_14=\`dpkg -l | grep linux-image | awk '{print \$2}' | awk -F '-' '{print \$3}' | grep "4.14"\`
ver_4_15=\`dpkg -l | grep linux-image | awk '{print \$2}' | awk -F '-' '{print \$3}' | grep "4.15"\`
if   [[ ! -z "\${ver_4_13}" ]]; then wget --no-check-certificate -qO tcp_nanqinlang.c https://raw.githubusercontent.com/nanqinlang-tcp/tcp_nanqinlang/master/General/Debian/source/kernel-v4.13/tcp_nanqinlang.c
elif [[ ! -z "\${ver_4_14}" ]]; then wget --no-check-certificate -qO tcp_nanqinlang.c https://raw.githubusercontent.com/nanqinlang-tcp/tcp_nanqinlang/master/General/Debian/source/kernel-v4.14/tcp_nanqinlang.c
elif [[ ! -z "\${ver_4_15}" ]]; then wget --no-check-certificate -qO tcp_nanqinlang.c https://raw.githubusercontent.com/nanqinlang-tcp/tcp_nanqinlang/master/General/Debian/source/kernel-v4.15/tcp_nanqinlang.c
else wget --no-check-certificate -qO tcp_nanqinlang.c https://raw.githubusercontent.com/nanqinlang-tcp/tcp_nanqinlang/master/General/Debian/source/kernel-v4.12andbelow/tcp_nanqinlang.c ; fi

echo "obj-m := tcp_nanqinlang.o" > Makefile
make -C /lib/modules/\$(uname -r)/build M=\`pwd\` modules CC=\`which gcc\`
cp -rf tcp_nanqinlang.ko /lib/modules/\$(uname -r)/kernel/net/ipv4
insmod /lib/modules/\$(uname -r)/kernel/net/ipv4/tcp_nanqinlang.ko
depmod -a

rm -rf tcp_nanqinlang.c Makefile
cp /etc/rc.local.bak /etc/rc.local
sysctl -p
EOF

sed -i '$d' /etc/rc.local
echo "bash /etc/autoinstall/nqlbbr.sh" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local ; }



# 重启后自动安装 Yankee 版 BBR
function _bbr_tsunami_autoinstall_after_reboot() {

mkdir -p /etc/autoinstall
[[ ! -f /etc/rc.local.bak ]] && cp /etc/rc.local /etc/rc.local.bak

cat > /etc/autoinstall/ykbbr.sh <<EOF
wget --no-check-certificate -qO tcp_tsunami.c https://github.com/Aniverse/BitTorrentClientCollection/raw/master/TCP%20Congestion%20Control/tcp_tsunami.c

echo "obj-m:=tcp_tsunami.o" > Makefile
make -C /lib/modules/\$(uname -r)/build M=\`pwd\` modules CC=\`which gcc\`

insmod tcp_tsunami.ko
cp -rf tcp_tsunami.ko /lib/modules/\$(uname -r)/kernel/net/ipv4
depmod -a
modprobe tcp_tsunami

rm -rf tcp_tsunami.c Makefile
cp /etc/rc.local.bak /etc/rc.local
sysctl -p
EOF

[[ ! -f /etc/rc.local.bak ]] && cp /etc/rc.local /etc/rc.local.bak

sed -i '$d' /etc/rc.local
echo "bash /etc/autoinstall/ykbbr.sh" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local ; }



# 重启后自动安装锐速
function _serverspeeder_autoinstall_after_reboot() {

mkdir -p /etc/autoinstall

cat > /etc/autoinstall/appexinstall.sh << EOF
wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && echo | bash /tmp/appex.sh 'install'
cp /etc/rc.local.bak /etc/rc.local
EOF

[[ ! -f /etc/rc.local.bak ]] && cp /etc/rc.local /etc/rc.local.bak

sed -i '$d' /etc/rc.local
echo "bash /etc/autoinstall/appexinstall.sh" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local ; }






###################################################################################################################################################################







# Debian 安装 3.12.1 内核（For ServerSpeeder）
function _debian_serverspeeder_kernel_312() {
wget --no-check-certificate -qO 1.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-headers-3.12-1.deb
wget --no-check-certificate -qO 2.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-image-3.12-1.deb
dpkg -i [12].deb > /dev/null 2>&1 || { echo -e "${bold}${red}错误${white} 安装 内核 失败！${normal}" ; exit 1 ; }
rm  -rf [12].deb ; }



# Debian 安装 3.16.0-4 内核（For ServerSpeeder）
function _debian_serverspeeder_kernel_316() {
wget --no-check-certificate -qO 1.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-image-3.16.0-4.deb
dpkg -i 1.deb > /dev/null 2>&1 || { echo -e "${bold}${red}错误${white} 安装 内核 失败！${normal}" ; exit 1 ; }
rm  -rf 1.deb ; }



# Ubuntu 安装 4.4.0-47 内核（For ServerSpeeder）
function _ubuntu_serverspeeder_kernel_440() {
wget --no-check-certificate -qO 1.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-image-4.4.0-47.deb
wget --no-check-certificate -qO 2.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-headers-4.4.0-47-all.deb
wget --no-check-certificate -qO 3.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-headers-4.4.0-47.deb
dpkg -i [123].deb > /dev/null 2>&1 || { echo -e "${bold}${red}错误${white} 安装 内核 失败！${normal}" ; exit 1 ; }
rm  -rf [123].deb ; }



# Ubuntu 从系统源安装锐速内核（For ServerSpeeder）
function _ubuntu_serverspeeder_kernel_repo() {
sed -i '/deb http:\/\/security.ubuntu.com\/ubuntu trusty-security main/'d /etc/apt/sources.list
echo "deb http://security.ubuntu.com/ubuntu trusty-security main" >> /etc/apt/sources.list
echo -ne "更新系统源 ...  "
apt-get update > /dev/null 2>&1 && echo "${green}DONE${normal}"
echo -ne "安装内核 ...  "
DEBIAN_FRONTEND=noninteractive apt-get -y install linux-image-extra-$kernelver linux-image-$kernelver linux-headers-$kernelver > /dev/null 2>&1 && echo "${green}DONE${normal}" || { echo -e "${bold}${red}错误${white} 安装 内核 失败！${normal}" ; exit 1 ; }
sed -i '/deb http:\/\/security.ubuntu.com\/ubuntu trusty-security main/'d /etc/apt/sources.list
echo -ne "更新系统源 ...  "
apt-get update > /dev/null 2>&1 && echo "${green}DONE${normal}" ; }



# Ubuntu 不卸载新内核的情况下使用老内核启动（For ServerSpeeder）
function _ubuntu_serverspeeder_updategrub() {
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux kernelver"/' /etc/default/grub
sed -i "s/kernelver/$kernelver/" /etc/default/grub
echo -ne "${bold}更新引导 ...  "
update-grub > /dev/null 2>&1 && echo "${green}DONE${normal}" ; }



# 内核匹配的情况下安装锐速
function _serverspeeder_direct_install() { wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && echo | bash /tmp/appex.sh 'install'
[[ ` ps aux | grep appex | grep -v grep ` ]] && echo -e "\n${bold}${green}锐速已在运行 ...${normal}\n" || echo -e "\n${bold}${green}锐速尚未在运行，可能安装失败！${normal}\n" ; }






###################################################################################################################################################################






# Online.net 独服补充固件（For BBR）
function _online_ubuntu_bbr_firmware() {
mkdir -p /lib/firmware/bnx2
if [[ -f /lib/firmware/bnx2/fw.lock ]]; then
    touch /lib/firmware/bnx2/fw.lock
    echo -e "${bold}${white}下载可能缺少的固件 ... ${normal}\n"
    wget -qO /lib/firmware/bnx2/bnx2-mips-06-6.2.3.fw https://github.com/Aniverse/inexistence/raw/master/03.Files/firmware/bnx2-mips-06-6.2.3.fw
    wget -qO /lib/firmware/bnx2/bnx2-mips-09-6.2.1b.fw https://github.com/Aniverse/inexistence/raw/master/03.Files/firmware/bnx2-mips-09-6.2.1b.fw
    wget -qO /lib/firmware/bnx2/bnx2-rv2p-09ax-6.0.17.fw https://github.com/Aniverse/inexistence/raw/master/03.Files/firmware/bnx2-rv2p-09ax-6.0.17.fw
    wget -qO /lib/firmware/bnx2/bnx2-rv2p-09-6.0.17.fw https://github.com/Aniverse/inexistence/raw/master/03.Files/firmware/bnx2-rv2p-09-6.0.17.fw
    wget -qO /lib/firmware/bnx2/bnx2-rv2p-06-6.0.15.fw https://github.com/Aniverse/inexistence/raw/master/03.Files/firmware/bnx2-rv2p-06-6.0.15.fw
fi ; }



# 安装 4.11.12 的内核（For BBR）
function _bbr_kernel_4_11_12() {
echo -e "\n${bold}${white}安装 4.11.12 内核 ... ${normal}\n"
wget --no-check-certificate -qO 1.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/BBR/linux-headers-4.11.12-all.deb
wget --no-check-certificate -qO 2.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/BBR/linux-headers-4.11.12-amd64.deb
wget --no-check-certificate -qO 3.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/BBR/linux-image-4.11.12-generic-amd64.deb
dpkg -i [123].deb > /dev/null 2>&1 || { echo -e "${bold}${red}错误${white} 安装 内核 失败！${normal}" ; exit 1 ; }
rm -rf [123].deb
echo -ne "${bold}更新引导 ...  "
update-grub > /dev/null 2>&1 && echo "${green}DONE${normal}" ; }



# 检查最新版内核（For BBR）
function _get_latest_version() {
latest_version=$(wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/ | awk -F'\"v' '/v[4-9]./{print $2}' | cut -d/ -f1 | grep -v -  | sort -V | tail -1)
[ -z ${latest_version} ] && return 1
deb_name=$(wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v${latest_version}/ | grep "linux-image" | grep "generic" | awk -F'\">' '/amd64.deb/{print $2}' | cut -d'<' -f1 | head -1)
deb_kernel_url="http://kernel.ubuntu.com/~kernel-ppa/mainline/v${latest_version}/${deb_name}"
deb_kernel_name="linux-image-${latest_version}-amd64.deb"
[ ! -z ${deb_name} ] && return 0 || return 1 ; }



# 下载、安装 最新版内核（For BBR）
function _install_latest_kernel() {
_get_latest_version
[ $? -ne 0 ] && echo -e "${red}Error:${plain} Get latest kernel version failed." && exit 1
wget -c -t3 -T60 -O "${deb_kernel_name}" "${deb_kernel_url}"
if [ $? -ne 0 ]; then
    echo -e "${red}Error:${plain} Download ${deb_kernel_name} failed, please check it."
    exit 1
fi
dpkg -i "${deb_kernel_name}"
rm -fv "${deb_kernel_name}"
echo -ne "${bold}更新引导 ...  "
update-grub > /dev/null 2>&1 && echo "${green}DONE${normal}" ; }



# 检查安装魔改版 BBR 所需的必要软件
function _check_essential() {

if [[ $CODENAME == stretch ]]; then
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e "\n${white}${bold}安装 libssl1.0.0 ...${normal}"
    echo -e "\ndeb http://ftp.hk.debian.org/debian jessie main\c" >> /etc/apt/sources.list
    apt-get update > /dev/null 2>&1
    apt-get install -y libssl1.0.0 > /dev/null 2>&1
    sed  -i '/deb http:\/\/ftp\.hk\.debian\.org\/debian jessie main/d' /etc/apt/sources.list
    apt-get update > /dev/null 2>&1
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e "\n${red}错误${white}${bold} 安装 libssl1.0.0  失败！${normal}" ; exit 1 ; } ; }
else
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e "\n${bold}${white}安装 libssl1.0.0 ...${normal}"  ; DEBIAN_FRONTEND=noninteractive apt-get install -y libssl1.0.0 > /dev/null 2>&1
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e "\n${red}错误${white}${bold} 安装 libssl1.0.0  失败！${normal}" ; exit 1 ; } ; }
fi

which make > /dev/null 2>&1 ; [ $? -ne '0' ] && { echo -e "\n${white}${bold}安装 make ...${normal}" ; DEBIAN_FRONTEND=noninteractive apt-get install -y make > /dev/null 2>&1
which make > /dev/null 2>&1 ; [ $? -ne '0' ] && { echo -e "\n${red}错误${white}${bold} 安装 make 失败！${normal}" ; exit 1 ; } ; }

which awk  > /dev/null 2>&1 ; [ $? -ne '0' ] && { echo -e "\n${white}${bold}安装 awk ...${normal}"  ; DEBIAN_FRONTEND=noninteractive apt-get install -y gawk > /dev/null 2>&1
which awk  > /dev/null 2>&1 ; [ $? -ne '0' ] && { echo -e "\n${red}错误${white}${bold} 安装 awk 失败！${normal}"  ; exit 1 ; } ; }

which gcc  > /dev/null 2>&1 ; [ $? -ne '0' ] && { echo -e "\n${white}${bold}安装 gcc ...${normal}"  ; DEBIAN_FRONTEND=noninteractive apt-get install -y gcc  > /dev/null 2>&1
which gcc  > /dev/null 2>&1 ; [ $? -ne '0' ] && { echo -e "\n${red}错误${white}${bold} 安装 gcc 失败！${normal}"  ; exit 1 ; } ; }

gcc_ok=0 ; gcc_ver=` gcc --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 `
gcc_ver_1=` echo $gcc_ver | awk -F. '{print $1}' ` ; gcc_ver_2=` echo $gcc_ver | awk -F. '{print $2}' `
[[ -n $gcc_ver_1 ]] && [[ $gcc_ver_1 -gt 4 ]] && gcc_ok=1
[[ $gcc_ver_1 == 4 ]] && [[ -n $gcc_ver_2 ]] && [[ $gcc_ver_2 -ge 9 ]] && gcc_ok=1
[[ $gcc_ok == 0 ]] && { echo -e "\n${red}错误${white}${bold} gcc 版本低于 4.9！${normal}" ; exit 1 ; }

[[ ! `dpkg -l | grep build-essential` ]] && { echo -e "\n${white}${bold}安装 build-essential ...${normal}"  ; DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential > /dev/null 2>&1
[[ ! `dpkg -l | grep build-essential` ]] && { echo -e "\n${red}错误${white}${bold} 安装 build-essential  失败！${normal}" ; exit 1 ; } ; } ; }



# 南琴浪版魔改 BBR 编译安装算法
function _bbr_nanqinlang(){
ver_4_13=`dpkg -l | grep linux-image | awk '{print $2}' | awk -F '-' '{print $3}' | grep "4.13"`
ver_4_14=`dpkg -l | grep linux-image | awk '{print $2}' | awk -F '-' '{print $3}' | grep "4.14"`
ver_4_15=`dpkg -l | grep linux-image | awk '{print $2}' | awk -F '-' '{print $3}' | grep "4.15"`
if   [[ ! -z "${ver_4_13}" ]]; then wget --no-check-certificate -q https://raw.githubusercontent.com/nanqinlang-tcp/tcp_nanqinlang/master/General/Debian/source/kernel-v4.13/tcp_nanqinlang.c
elif [[ ! -z "${ver_4_14}" ]]; then wget --no-check-certificate -q https://raw.githubusercontent.com/nanqinlang-tcp/tcp_nanqinlang/master/General/Debian/source/kernel-v4.14/tcp_nanqinlang.c
elif [[ ! -z "${ver_4_15}" ]]; then wget --no-check-certificate -q https://raw.githubusercontent.com/nanqinlang-tcp/tcp_nanqinlang/master/General/Debian/source/kernel-v4.15/tcp_nanqinlang.c
else wget --no-check-certificate -q https://raw.githubusercontent.com/nanqinlang-tcp/tcp_nanqinlang/master/General/Debian/source/kernel-v4.12andbelow/tcp_nanqinlang.c ; fi

# wget --no-check-certificate -qO Makefile https://raw.githubusercontent.com/nanqinlang-tcp/tcp_nanqinlang/master/Makefile/Makefile-Debian9
# sed -i "s/\/usr\/bin\/gcc-6/\`which gcc\`/" Makefile
# make && make install

echo "obj-m := tcp_nanqinlang.o" > Makefile
make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=`which gcc` > /dev/null 2>&1
cp -rf tcp_nanqinlang.ko /lib/modules/$(uname -r)/kernel/net/ipv4
insmod /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_nanqinlang.ko > /dev/null 2>&1
depmod -a

rm -rf tcp_nanqinlang.c Makefile ; }



# 安装 Yankee 版 魔改 BBR
function _bbr_tsunami() {
wget --no-check-certificate -qO tcp_tsunami.c https://github.com/Aniverse/BitTorrentClientCollection/raw/master/TCP%20Congestion%20Control/tcp_tsunami.c
echo "obj-m:=tcp_tsunami.o" > Makefile
make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=`which gcc` > /dev/null 2>&1
insmod tcp_tsunami.ko > /dev/null 2>&1
cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
depmod -a
modprobe tcp_tsunami > /dev/null 2>&1
rm -rf tcp_tsunami.c Makefile ; }



# 开启 BBR 或 魔改版 BBR
function _enable_bbr() {
sed -i '/net.core.default_qdisc.*/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control.*/d' /etc/sysctl.conf
echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = $bbrname" >> /etc/sysctl.conf
sysctl -p > /dev/null 2>&1 ; }



# 关闭 BBR 或 魔改版 BBR
function _disable_bbr() {
sed -i '/net.core.default_qdisc.*/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control.*/d' /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = cubic" >> /etc/sysctl.conf
[[ ! $bbrname == bbr ]] && rm /lib/modules/`uname -r`/kernel/net/ipv4/tcp_$bbrname.ko
sysctl -p > /dev/null 2>&1 ; }






###################################################################################################################################################################






# 删除其他内核，并更新引导
function _delete_kernel() {
echo -e "\n${bold}${white}卸载多余内核 ... ${normal}\n"
kernel_total=` dpkg -l | grep -E linux-[image,headers] | awk '{print $2}' | grep -v "${kernel_version}" | wc -l `

for ddd in debconf-set-selections debconf-get-selections ; do
[[ ! `command -v $ddd` ]] && wget --no-check-certificate -qO /usr/bin/$ddd https://github.com/Aniverse/inexistence/raw/master/00.Installation/script/$ddd && chmod +x /usr/bin/$ddd ; done

if [ $kernel_total > 1 ]; then
    for (( integer = 1 ; integer <= ${kernel_total} ; integer++ )) ; do
        kernel_tobe_del=` dpkg -l | grep -E linux-[image,headers] | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer} `
        echo -ne "Removing ${kernel_tobe_del} ... "
        echo `debconf-get-selections ${deb_del} | grep removing-running-kernel | grep $running_kernel | sed s/true/false/` | debconf-set-selections
        DEBIAN_FRONTEND=noninteractive apt-get -y purge $kernel_tobe_del > /dev/null 2>&1 && echo "$(tput setaf 2)DONE$(tput sgr0)" || echo "$(tput setaf 1)FAILED$(tput sgr0)"
    done
fi

echo -ne "${bold}更新引导 ...  "
update-grub > /dev/null 2>&1 && echo "${green}DONE${normal}" ; }






# Debian 9 启用 /etc/rc.local
function _stretch_enable_rclocal() {
cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0
EOF
chmod +x /etc/rc.local
systemctl start rc-local ; }







cp -f /etc/default/grub "/etc/default/grub.bak.$(date "+%Y.%m.%d.%H.%M.%S")"
_menu
_read_response

