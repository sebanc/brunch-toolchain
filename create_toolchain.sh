#!/bin/bash

BUILDPATH=$(dirname $(realpath "$0"))

build_all=1

mkdir -p ./bootstrap/usr/local

if [ ! -z $build_all ] || [ ! -z $build_gcc ]; then

mkdir -p ./gcc/out
curl -L https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz -o ./gcc.tar.gz
tar zxf ./gcc.tar.gz -C ./gcc --strip 1
rm ./gcc.tar.gz
cd ./gcc
./contrib/download_prerequisites
cd ./out
../configure --prefix=/usr/local --libdir=/usr/local/lib64 --enable-languages=c,c++ --with-glibc-version=2.27 --disable-multilib --disable-nls --disable-libssp --disable-host-shared
make -j$(($(nproc)-1))
make DESTDIR="$BUILDPATH"/bootstrap install-strip
ln -v -sf gcc "$BUILDPATH"/bootstrap/usr/local/bin/cc
ln -v -sf cpp "$BUILDPATH"/bootstrap/usr/local/bin/x86_64-pc-linux-gnu-cpp
cd ../..
rm -rf ./gcc
read -p "Press any key to resume ..."

fi

if [ ! -z $build_all ] || [ ! -z $build_binutils ]; then

mkdir -p ./binutils/out
curl -L https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.gz -o ./binutils.tar.gz
tar zxf ./binutils.tar.gz -C ./binutils --strip 1
rm ./binutils.tar.gz
cd ./binutils/out
../configure --prefix=/usr/local --libdir=/usr/local/lib64 --enable-gold --enable-gold=default --disable-nls --disable-libssp --disable-host-shared
make -j$(($(nproc)-1))
make DESTDIR="$BUILDPATH"/bootstrap install-strip
ln -v -sf ld "$BUILDPATH"/bootstrap/usr/local/bin/x86_64-pc-linux-gnu-ld
ln -v -sf ld.bfd "$BUILDPATH"/bootstrap/usr/local/bin/x86_64-pc-linux-gnu-ld.bfd
ln -v -sf ld.gold "$BUILDPATH"/bootstrap/usr/local/bin/x86_64-pc-linux-gnu-ld.gold
cd ../..
rm -rf ./binutils
read -p "Press any key to resume ..."

fi

if [ ! -z $build_all ] || [ ! -z $build_linux_headers ]; then

mkdir -p ./linux_headers
curl -L https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/refs/heads/chromeos-5.10.tar.gz -o ./chromiumos_kernel.tar.gz
tar zxf ./chromiumos_kernel.tar.gz -C ./linux_headers
rm ./chromiumos_kernel.tar.gz
cd ./linux_headers
make headers_install INSTALL_HDR_PATH="$BUILDPATH"/bootstrap/usr/local
cd ..
rm -rf ./linux_headers
read -p "Press any key to resume ..."

fi

if [ ! -z $build_all ] || [ ! -z $build_glibc ]; then

mkdir -p ./glibc/out
curl -L https://ftp.gnu.org/gnu/glibc/glibc-2.27.tar.gz -o ./glibc.tar.gz
tar zxf ./glibc.tar.gz -C ./glibc --strip 1
rm ./glibc.tar.gz
curl -L https://dev.gentoo.org/~dilfridge/distfiles/glibc-2.27-patches-3.tar.bz2 -o ./glibc-patches.tar.gz
tar xjf ./glibc-patches.tar.gz -C ./glibc
rm ./glibc-patches.tar.gz
cd ./glibc
for glibc_patch in ./patches/*.patch
do
echo $glibc_patch
patch -p1 --no-backup-if-mismatch -N < $glibc_patch
done
cd ./out
../configure --prefix=/usr/local --libdir=/usr/local/lib64 --enable-kernel=3.2 --with-headers="$BUILDPATH"/bootstrap/usr/local/include --without-selinux --disable-nls libc_cv_slibdir=/lib64 --disable-sanity-checks CFLAGS="-O2 -Wno-maybe-uninitialized -Wno-error=missing-attributes -Wno-error=array-bounds -Wno-error=zero-length-bounds"
make -j$(($(nproc)-1))
make DESTDIR="$BUILDPATH"/bootstrap install
cd ../..
rm -rf ./glibc
read -p "Press any key to resume ..."

fi

if [ ! -z $build_all ] || [ ! -z $build_make ]; then

mkdir -p ./make
curl -L https://ftp.gnu.org/gnu/make/make-4.3.tar.gz -o ./make.tar.gz
tar zxf ./make.tar.gz -C ./make --strip 1
rm ./make.tar.gz
cd ./make
./configure --prefix=/usr/local --libdir=/usr/local/lib64 --without-guile
make -j$(($(nproc)-1))
make DESTDIR="$BUILDPATH"/bootstrap install
cd ..
rm -rf ./make
read -p "Press any key to resume ..."

fi

if mountpoint -q ./chroot/usr/include; then sudo umount ./chroot/usr/include; fi
if mountpoint -q ./chroot/dev/shm; then sudo umount ./chroot/dev/shm; fi
if mountpoint -q ./chroot/dev; then sudo umount ./chroot/dev; fi
if mountpoint -q ./chroot/sys; then sudo umount ./chroot/sys; fi
if mountpoint -q ./chroot/proc; then sudo umount ./chroot/proc; fi
if mountpoint -q ./chroot/out; then sudo umount ./chroot/out; fi

if [ -d ./chroot ]; then sudo rm -r ./chroot; fi
if [ -d ./toolchain ]; then sudo rm -r ./toolchain; fi

mkdir -p ./chroot/out ./toolchain

if [ ! -z $1 ]; then
if [ ! -f "$1" ]; then echo "ChromeOS recovery image $1 not found"; exit 1; fi
if [ ! $(dd if="$1" bs=1 count=4 status=none | od -A n -t x1 | sed 's/ //g') == '33c0fa8e' ] || [ $(cgpt show -i 12 -b "$1") -eq 0 ] || [ $(cgpt show -i 13 -b "$1") -gt 0 ] || [ ! $(cgpt show -i 3 -l "$1") == 'ROOT-A' ]; then echo "$1 is not a valid ChromeOS recovery image"; fi
recovery_image=$(sudo losetup --show -fP "$1")
sudo mount -o ro "$recovery_image"p3 ./toolchain
sudo cp -a ./toolchain/* ./chroot/
sudo umount ./toolchain
sudo losetup -d "$recovery_image"
else
git clone -b master https://github.com/cyxx/extract_android_ota_payload.git rootfs
cd rootfs
curl -L http://dl.google.com/chromeos/rammus/13729.56.0/stable-channel/chromeos_13729.56.0_rammus_stable-channel_full_mp-v2.bin-gyydkmbxge3gkllfg6xnqvegcbnkkykn.signed -o ./update.signed
python3 extract_android_ota_payload.py ./update.signed
cd ..
if [ ! -f ./rootfs/root.img ]; then echo "ChromeOS rootfs could not be extracted"; rm -r ./rootfs; exit 1; fi
sudo mount -o ro ./rootfs/root.img ./toolchain
sudo cp -a ./toolchain/* ./chroot/
sudo umount ./toolchain
sudo rm -r ./rootfs
fi

sudo chown 1000:1000 ./chroot/usr/local
cp -r ./bootstrap/usr/local/* ./chroot/usr/local/
rm -r ./bootstrap

sudo chmod 0777 ./chroot/home/chronos
sudo rm ./chroot/etc/resolv.conf
echo 'nameserver 8.8.4.4' | sudo tee ./chroot/etc/resolv.conf
echo 'chronos ALL=(ALL) NOPASSWD: ALL' | sudo tee ./chroot/etc/sudoers.d/95_cros_base

sudo mount --bind ./toolchain ./chroot/out
sudo mount -t proc none ./chroot/proc
sudo mount -t sysfs none ./chroot/sys
sudo mount -t devtmpfs none ./chroot/dev
sudo mount -t tmpfs -o mode=1777,nosuid,nodev,strictatime tmpfs ./chroot/dev/shm
sudo mount -o bind ./chroot/usr/local/include ./chroot/usr/include

sudo cp ./toolchain_chroot ./chroot/init
sudo chroot --userspec=1000:1000 ./chroot /init

sudo umount ./chroot/usr/include
sudo umount ./chroot/dev/shm
sudo umount ./chroot/dev
sudo umount ./chroot/sys
sudo umount ./chroot/proc
sudo umount ./chroot/out
sudo rm -r ./chroot

