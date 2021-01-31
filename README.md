# Brunch toolchain

## Overview

This project consists in providing ChromeOS with a dedicated toolchain and more native utilities. It notably contains:
- build-essentials (binutils, gcc, make, ...)
- compression tools (bzip2, xz, lz4, gzip, ...)
- utilities (diffutils, patch, gawk, ...)
- git
- perl
- python
- lxc

Why do I need it ?
You don't necessarily need it, currently it would mostly be useful for developers or if there is a specific app / kernel module that you need to build from source.

How is that different from Chromebrew ?
Chromebrew is a package manager, you can create a toolchain with it by installing all the necessary packages but I needed to have one more adapted to my use.

So that's all there is ?
Not necessarily, the first project based on the brunch-toolchain is brioche: https://github.com/sebanc/brioche

## Install instructions

The toolchain has to be installed to /usr/local (which is actually on the data partition) and takes about 2GB of space.

**Warning: The below commands will remove any previous Chromebrew installation and you cannot have both Chromebrew and the Brunch toolchain installed.**

If you have Crouton installed , execute the following first:
```shell
mkdir ~/tmp
sudo cp /usr/local/bin/start* ~/tmp
sudo cp /usr/local/bin/enter-chroot ~/tmp
```
1. Remove all data from /usr/local directory:
```
sudo rm -rf /usr/local/*
```

2. Ensure that /usr/local is owned by chronos user:
```
sudo chown -R 1000:1000 /usr/local
```

3. Download the brunch toolchain release and extract it in /usr/local:
```
tar zxf <brunch_toolchain_archive> -C /usr/local
```
4. Recover the Crouton installation (if installed previously)
```shell
sudo install -Dt /usr/local/bin -m 755 ~/tmp/* && sudo rm -rf ~/tmp
sudo ln -s /mnt/stateful_partition/crouton/chroots /usr/local/
```

5. After each reboot, before using the brunch toolchain run the below command:
```
start-toolchain
```

If you want to execute `start-toolchain` automatically, you can run the below command:
```
echo "start-toolchain" >> ~/.bashrc
```
