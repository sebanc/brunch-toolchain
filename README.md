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

**Warning: The below commands will remove any previous Chromebrew or Crouton installation, Crouton can be reinstalled afterwards but you cannot have both Chromebrew and the Brunch toolchain installed.**

1. Remove all data from /usr/local directory:
```
sudo rm -r /usr/local/*
```

2. Ensure that /usr/local is owned by chronos user:
```
sudo chown -R 1000:1000 /usr/local
```

3. Download the brunch toolchain release and extract it in /usr/local:
```
tar zxf <brunch_toolchain_archive> -C /usr/local
```

4. After each reboot, if you want to build something from source or use python, run the below command in crosh shell first:
```
source /usr/local/bin/start-toolchain
```

If you want to have it executed automatically, you can run the below command:
```
echo "source /usr/local/bin/start-toolchain" >> ~/.bashrc
```
