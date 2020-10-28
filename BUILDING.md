# Building the toolchain

The toolchain build script has only been tested under Ubuntu 20.04.

### Requirements

- root access.
- I am not sure about the exact dependencies yet, they should be quite limited (mostly build-essentials, gawk and curl) but I still have to verify that.

## Getting the source

Clone the main branch and enter the source directory:

```
git clone -b main https://github.com/sebanc/brunch-toolchain.git brunch-toolchain
cd brunch-toolchain
```

## Building the toolchain.

To build the toolchain, you need to have root access and 10 GB of free disk space available.

1. Download the "samus" ChromeOS recovery image from here (https://cros-updates-serving.appspot.com/) and extract it.

2. Launch the build (as a user -> without sudo, it will prompt you for your password when needed):
```
./create_toolchain.sh <path_to_the_samus_recovery_image>
```
3. Make yourself 100 coffees (the build will take several hours, it mostly depends on your cpu and hdd speed).

4. That's it. You should have a "toolchain" directory containing the toolchain tar.gz archive.

