# Arch Linux Kernel Builder (alkb)

Tiny bash script to build Arch Linux kernel

## Configure the Linux kernel

Patch [PKGBUILD](https://wiki.archlinux.fr/PKGBUILD)
from [linux package](https://github.com/archlinux/svntogit-packages/tree/packages/linux) to create a custom kernel
config file based on modules provided by [modprobed](https://wiki.archlinux.org/title/Modprobed-db)

```sh
bash tasks.sk prepare
```

## Build the kernel

```sh
bash tasks.sk build
```

## Install the packages

```sh
bash tasks.sk install
```
