# ArchLinux custom HDD image

Use the build_image.sh script to build your image.

Some variables that may be useful to fit your needs.

ROOT_PASSWD - root password
PERMIT_ROOT_LOGIN - yes/no - ability for the root user to login via ssh
IMAGE_SIZE - size of the HDD image. Make sure the size is enough to install everything you need
BOOT_PARTITION_SIZE - boot partition size. 100m should be enough as default value
SWAP_PARTITION_SIZE - size of the swap partition
INSTALL_PACKAGES - packages to install via pacman
AUTOSTART_SERVICES - services to autostart

