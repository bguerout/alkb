# Arch Linux Kernel Builder (alkb)

Automate most of the manual tasks described in
the [Arch Build System](https://wiki.archlinux.org/title/Kernel/Arch_Build_System#:~:text=The%20Arch%20Build%20System%20can,configuration%20or%20add%20additional%20patches.)
to build a custom kernel.

## Build the kernel

```sh
make
```

Once build is finished, you can install the kernel packages with the following commands:

```sh
cd build/package
pacman -U *.tar.zst
```

## Build the kernel only with the modules needed by your system

Before running this script, you need to install and configure [modprobed](https://wiki.archlinux.org/title/Modprobed-db)
, then run

```sh
make modprobed
```

## Build kernel with custom config

Add configuration in file `patches/config`, then just run

```sh
make
```

Note that you can also use custom config with `modprobed` task



