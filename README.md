# TrCtrlProToc0l (AccTCP)
> WARNING: This script may cause system reboot failure  

![01](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/01.png)

## Usage

```shell
bash <(curl -Ls https://git.io/AccTCP)
```

or

```shell
bash -c "$(wget --no-check-certificate -qO- https://github.com/Aniverse/TrCtrlProToc0l/raw/master/A)"
```



## Feature

- **尽可能地减少交互，尽可能地傻瓜化**  

  本脚本把重启后要执行的操作（安装锐速、编译魔改 bbr）放到一个临时的脚本中，并用 systemd 实现开机自动执行脚本，实现了当前运行内核无法直接安装锐速／bbr 的情况下更换内核重启后自动安装 锐速 / 魔改BBR，无需再次运行脚本    

  此外，移除当前正在使用的内核时会碰到 `abort removing running kernel` 的 对话框，以及 Digital Ocean VPS 安装新内核时可能会出现 `what would you like to do about menu.list` 的对话框，本脚本使用了 `debconf-set-selections` 来避免这个交互   

  更进一步的无交互体验（比如说你连选项都不想输入的话）也可以做到，比如：

  ```
  bash <(curl https://git.io/AccTCP) << EOF
  5
  
  EOF
  ```

  这样子就是直接安装 LotServer，复制粘贴后不会有任何需要额外操作的地方，（换内核→删除其他内核→重启→重启后自动装锐速）这四个操作脚本会自动完成   

- **一键安装，一键切换** 

  本脚本可以安装、卸载 锐速（ServerSpeeder 和 LotServer）、原版 bbr、Yankee 版魔改 bbr、南琴浪版魔改 bbr、bbrplus，并支持在以上任意的加速方案中一键切换  

- **最新的内核适配**  

针对 4.13-4.20、5.0-5.5 等更高版本的内核适配了两种魔改版 bbr（原先的魔改 bbr 在高于 4.12 的内核上就不能用了）  

## Drawbacks

- **不支持 CentOS**  

  本脚本作为 `inexistence` 中 `mingling` 的延伸，我认没打算去适配原本 `inexistence` 就不支持的系统  
  本来这类脚本也有很多，如有需要你可以去用那些适配范围更广的脚本  

  非 LTS 的 Ubuntu 系统（比如 Ubuntu 19.10）和比较老旧的系统（比如 Debian 7 和 Ubuntu 14.04）也不受支持

## Known Issues

- **某些情况下编译魔改 bbr 会失败**  
如果碰到编译失败的情况，请先安装 4.11.12 内核并使用这个内核启动（可以把其他内核先删掉），再编译魔改 bbr  

- **某些情况下重启后 锐速 或 BBR 没有安装成功**  
自从换了 systemd 后这个情况很少见了。如果没成功的话只能手动再来一次了……  

- **Debian 9 无法安装普通的 4.16 及以上内核**  
因为依赖的原因装不上，暂时没有解决办法，不过一些第三方内核可以安装  

- **有时候提示卸载内核失败但其实是成功的**  
因为卸载其他内核的时候就把那个内核给卸载了，所以等轮到卸载它的时候没东西可以卸载就提示失败    

![Error01](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/Error01.png)
![Error02](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/Error02.png)

## More screenshots (OLD version)

![02](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/02.png)
![03](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/03.png)
![04](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/04.png)
![05](https://github.com/Aniverse/TrCtrlProToc0l/raw/master/Images/05.png)

## Some references

https://github.com/FunctionClub/YankeeBBR  
https://sometimesnaive.org/article/linux/bash/tcp_nanqinlang  
https://moeclub.org/2017/06/06/249/  
https://moeclub.org/2017/03/08/14/  
https://www.94ish.me/1635.html  
http://xiaofd.win/onekey-ruisu.html  
https://teddysun.com/489.html  
