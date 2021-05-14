
## Webvirtmgr Dockerfile

1. Install [Docker](https://www.docker.com/).

2. Pull the image from Docker Hub

```
$ docker build -t harbor.ui-tech.cn/webvirtmgr:4.8.9 .
$ docker push harbor.ui-tech.cn/webvirtmgr:4.8.9
$ docker pull harbor.ui-tech.cn/webvirtmgr:4.8.9
```

### Usage

```
$ docker run -d -p 8080:8080 -p 6080:6080 --name webvirtmgr -v /data/webvirtmgr:/data/webvirtmgr harbor.ui-tech.cn/webvirtmgr:4.8.9
```

### libvirtd configuration on the host

Centos7

```
sudo yum -y install qemu-kvm libvirt bridge-utils

sudo sed -i 's/#LIBVIRTD_ARGS/LIBVIRTD_ARGS/g' /etc/sysconfig/libvirtd
sudo sed -i 's/#listen_tls/listen_tls/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#listen_tcp/listen_tcp/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#auth_tcp/auth_tcp/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#vnc_listen/vnc_listen/g' /etc/libvirt/qemu.conf

sudo systemctl stop libvirtd.service > /dev/null 2>&1
sudo systemctl start libvirtd.service
sudo systemctl stop libvirt-guests.service > /dev/null 2>&1
sudo systemctl start libvirt-guests.service

sudo usermod -G libvirtd -a service

sudo chown service:service /etc/polkit-1/localauthority/50-local.d/50-libvirt-remote-access.pkla
sudo vim /etc/polkit-1/localauthority/50-local.d/50-libvirt-remote-access.pkla
[Remote libvirt SSH access]
Identity=unix-user:service
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
```

免密码登陆

### on system where WebVirtMgr is installed

```
sudo su - webvirtmgr -s /bin/bash
ssh-keygen
touch ~/.ssh/config && echo -e "StrictHostKeyChecking=no\nUserKnownHostsFile=/dev/null" >> ~/.ssh/config
chmod 0600 ~/.ssh/config
ssh-copy-id service@qemu-kvm-libvirt-host
```
