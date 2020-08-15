#!/bin/bash
#
# https://github.com/Aniverse/TrCtrlProToc0l
# Author: Aniverse
#
script_update=2020.08.15
script_version=r11009
########################################################################################################

usage_guide() {
apt-get install -y libelf-dev build-essential
bash <(curl -s https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/compile_tcp_cc.sh) tsunami nanqinlang bbrplus
}
########################################################################################################


tcp_cc=$1
#[[ -n $Outputs ]] && OutputLOG=">> $OutputLOG 2>&1"
[[ ! $tcp_cc =~ (tsunami|nanqinlang|bbrplus|tsunamio) ]] && echo -e "不支持！" && exit 1
function version_ge(){ test "$(echo "$@" | tr " " "\n" | sort -rV | head -1)" == "$1" ; }
filename=tcp_$tcp_cc.c
kernel_v=$(uname -r | cut -d- -f1)
kernel_v2=$(uname -r | cut -d- -f1 | cut -d. -f1-2)

version_ge $kernel_v 4.9.3 && [[ $tcp_cc == nanqinlang ]] && supported_list="4.9 4.10 4.11 4.12 4.13 4.14 4.15 4.16 4.17 4.18 4.19 4.20 5.0 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8"
version_ge $kernel_v 4.9.3 && [[ $tcp_cc == tsunami    ]] && supported_list="4.9 4.10 4.11 4.12 4.13 4.14 4.15 4.16 4.17 4.18 4.19 4.20 5.0 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8"
version_ge $kernel_v 4.14  && [[ $tcp_cc == bbrplus    ]] && supported_list="4.14 4.15 4.16 4.17 4.18 4.19 4.20 5.0"
version_ge $kernel_v 5.4   && [[ $tcp_cc == tsunamio   ]] && supported_list="5.4"

mkdir -p compile_tcp_cc
cd compile_tcp_cc

for supported_kernel in $supported_list ; do
    if [[ $kernel_v2 == $supported_kernel ]]; then
        if   [[ $kernel_v2 =~ (4.9|4.10|4.11|4.12) ]]; then
            supported_kernel="4.12_and_below"
        elif [[ $kernel_v2 == 5.8 ]]; then
            supported_kernel="5.8-rc"
        fi
        wget https://raw.githubusercontent.com/KozakaiAya/TCP_BBR/master/code/v${supported_kernel}/$filename -O $filename --no-check-certificate
    fi
done

[[ ! -f $filename ]] && echo -e "下载源码失败！" && exit 1

########################################################################################################################
# [[ $gcc_ver == 7.3 ]] && [[ $kernel_v2 == 4.15 ]] && echo "ccflags-y=-I/usr/lib/gcc/x86_64-linux-gnu/7/include" >> Makefile

gcc_version=$(gcc --version | grep ^gcc | sed 's/^.* //g')
include_path="ccflags-y=-I/usr/lib/gcc/x86_64-linux-gnu/$gcc_version/include"

echo "obj-m:=tcp_$tcp_cc.o"  >  Makefile
echo "$include_path"        >>  Makefile
mkdir -p  /lib/modules/$(uname -r)/build
make  -C  /lib/modules/$(uname -r)/build  M=$(pwd)  modules  CC=$(which gcc)

if [ ! -f ./tcp_$tcp_cc.ko ]; then
    echo "编译 $tcp_cc 失败"
fi

cp -f tcp_$tcp_cc.ko /lib/modules/$(uname -r)/kernel/net/ipv4
insmod /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_$tcp_cc.ko
modprobe tcp_$tcp_cc

if [ ! $? -eq 0 ]; then
    echo "载入 $tcp_cc 失败"
fi

depmod -a

#   cp -f tcp_$tcp_cc.ko /lib/modules/$(uname -r)/kernel/drivers/
#   echo "tcp_$tcp_cc" | tee -a /etc/modules
#   depmod
#   modprobe tcp_$tcp_cc

cd ..
rm -rf compile_tcp_cc
echo
