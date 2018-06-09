# virtualbox

## 1. ubuntu server安装扩展插件

virtual box菜单 &rArr; [设备] &rArr; [安装增强功能]

此时会在`/dev/`下有一个cdrom,挂在cdrom

```bash
sudo mount /dev/cdrom /mnt
```

执行增强功能包自带的脚本

```bash
sudo ./mnt/VBoxLinuxAdditions.run
```

## 2. ubuntu server共享文件夹

## 3. ubuntu server共享ip和端口

将网络连接模式更改为`桥接网卡`

## 4. 虚拟机之间和主机之间相互传输文件