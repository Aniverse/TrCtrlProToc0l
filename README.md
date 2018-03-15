# TrCtrlProToc0l

![01](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/01.png)

## Usage

```
bash -c "$(wget --no-check-certificate -qO- https://github.com/Aniverse/TrCtrlProToc0l/raw/master/TrCtrlProToc0l.sh)"
```

## Features

- **Less interactive**  
安装 锐速 或者魔改版 BBR，在当前内核无法适配的情况下，大多数脚本都需要在安装完新内核后先重启一次，重启完后再次运行脚本以安装 锐速 或 魔改版 BBR  
本脚本把重启后要执行的操作放到 `/etc/rc.local` 中，从而实现重启后自动安装 锐速 / 魔改BBR，无需再次运行脚本  
此外，移除内核时有时候会碰到 `abort removing running kernel` 的 "弹窗"，本脚本使用 `debconf-set-selections` 与 `DEBIAN_FRONTEND=noninteractive` 避免了这个情况  
总之就是尽可能地减少交互，尽可能地傻瓜化  

- **Onekey Install, Onekey Switch**  
本脚本可以安装、卸载 锐速、BBR、Yankee 版魔改 BBR、南琴浪 版魔改 BBR，并支持在以上任意的加速方案中一键切换    

- **Adapt for Online.net Dedicated Server**  
Online 独服的 Ubuntu 系统需要补充一些固件才能在更换高版本新内核后不翻车  
Online 独服的 Ubuntu 和 Debian 系统对于锐速挑内核，用 Ubuntu 的 `4.4.0-47` 和 Debian 的 `3.16.0-4` 容易翻车  
因此对于 Ubuntu 我指定用 `3.16.0-43` ，对于 Debian 8 我指定用 `3.12.1`（Debian 9 还是 `3.16.0-4`）  

## Drawbacks

- **Only supports Debian 8, Debian 9, Ubuntu 16.04 **  
本脚本作为 `inexistence` 中 `mingling` 的延伸，我认为不需要去支持原本 `inexistence` 就不支持的系统  
本来这类脚本也有很多，如有需要你可以去用那些适配范围更广的脚本  

- **Author is too young too simple and always naive**  
本脚本在 Vultr Cloud Compute 上测试通过，但不保证在别的环境上都能正常工作  

## More screenshots

![02](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/02.png)
![03](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/03.png)
![04](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/04.png)
![05](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/05.png)

## To Do List

- **允许自定义内核版本**  
目前指定 4.11.12  

## Known Issues

- **某些情况下多余内核可能会移除失败**  

## Some references

https://github.com/FunctionClub/YankeeBBR  
https://sometimesnaive.org/article/linux/bash/tcp_nanqinlang  
https://moeclub.org/2017/06/06/249/  
https://moeclub.org/2017/03/08/14/  
https://www.94ish.me/1635.html  
http://xiaofd.win/onekey-ruisu.html  
https://teddysun.com/489.html  
