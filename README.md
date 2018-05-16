# TrCtrlProToc0l
> WARNING: This script may cause system reboot failure  

This is the choice of Steins;Gate.  

![01](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/01.png)

## Usage

```
bash -c "$(wget --no-check-certificate -qO- https://github.com/Aniverse/TrCtrlProToc0l/raw/master/A)"
```

```
bash <(curl -s https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/A)
```

## Features

- **Less interactive**  
尽可能地减少交互，尽可能地傻瓜化  
本脚本把重启后要执行的操作（安装锐速、编译魔改 BBR）放到临时的 `/etc/rc.local` 中，实现了当前运行内核无法直接安装锐速／BBR 的情况下更换内核重启后自动安装 锐速 / 魔改BBR，无需再次运行脚本  
移除运行内核时会碰到 `abort removing running kernel` 的 对话框，以及 Digital Ocean VPS 安装新内核时可能会出现 `what would you like to do about menu.list` 的对话框，本脚本使用了 `debconf-set-selections` 来避免这个交互  

- **Onekey Install, Onekey Switch**  
本脚本可以安装、卸载 锐速、BBR、Yankee 版魔改 BBR、南琴浪 版魔改 BBR，并支持在以上任意的加速方案中一键切换  

- **Adapt for Linux Kernel 4.13-4.16**  
尝试针对 4.13-4.16 内核适配魔改版 BBR *（尚处于测试阶段，有时候会失败，求稳的话建议还是使用老版本内核比如 4.11.12）*  
针对部分最新的 4.16 内核还需要安装 modules 的情况也做了处理，会先安装 modules  

- **Adapt for Online.net Dedicated Server**  
有一些 Online 独服的 Ubuntu 系统需要补充一些固件才能在更换高版本新内核后不翻车  
有一些 Online 独服的 Ubuntu 和 Debian 系统对于锐速挑内核，用 Ubuntu 的 `4.4.0-47` 和 Debian 的 `3.16.0-4` 容易翻车  
因此对于 Ubuntu 我指定用 `3.16.0-43` ，对于 Debian 8 我指定用 `3.12.1`（Debian 9 还是 `3.16.0-4`，Ubuntu 18.04 是 `4.4.0-47`）  
（据说是驱动问题，菜鸡就只能用这种解决办法了）  

## Drawbacks

- **Only supports Debian 8, Debian 9, Ubuntu 16.04, Ubuntu 18.04**  
本脚本作为 `inexistence` 中 `mingling` 的延伸，我认为不需要去支持原本 `inexistence` 就不支持的系统  
本来这类脚本也有很多，如有需要你可以去用那些适配范围更广的脚本  

- **Author is too young too simple and always naive**  
本脚本在 Vultr Cloud Compute、Digital Ocean Droplet、Hetzner Cloud、Online 的 一些独服 上测试通过，但不保证在所有环境上都能正常工作  

## More screenshots

![02](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/02.png)
![03](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/03.png)
![04](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/04.png)
![05](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/05.png)
![06](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/06.png)

## To Do List

## Known Issues

- **某些情况下编译魔改 BBR 会失败**  
如果碰到编译失败的情况，请先安装 4.11.12 内核并使用这个内核启动（可以把其他内核先删掉），再编译魔改 BBR  

- **某些情况下重启后 锐速 或 BBR 没有安装成功**  
没成功的话只能手动再来一次了……  

- **无法删除 PVE 内核**  
因为这个的包名不太一样……  

## Some references

https://github.com/FunctionClub/YankeeBBR  
https://sometimesnaive.org/article/linux/bash/tcp_nanqinlang  
https://moeclub.org/2017/06/06/249/  
https://moeclub.org/2017/03/08/14/  
https://www.94ish.me/1635.html  
http://xiaofd.win/onekey-ruisu.html  
https://teddysun.com/489.html  
