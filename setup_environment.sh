#/bin/bash
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen &&
locale-gen &&
echo "LANG=en_US.UTF-8" > /etc/locale.conf &&
pacman -Sy --noconfirm grub sudo tar &&
echo "Installing additional packages..." &&
pacman -Sy --noconfirm ${INSTALL_PACKAGES} &&
echo "Installing extra packages..." &&
(cd $(dirname $0)/packages;pacman -U --noconfirm *.pkg.tar.zst) &&
echo "Extracting config files..." &&
tar xJvf $(dirname $0)/image-root.tar.bz2 -C / &&
echo -e "${ROOT_PASSWD}\n${ROOT_PASSWD}" | passwd &&
echo "PermitRootLogin $PERMIT_ROOT_LOGIN" >> /etc/ssh/sshd_config &&
systemctl enable $AUTOSTART_SERVICES &&
echo "Installing mkinitcpio..." &&
pacman -Sy --noconfirm mkinitcpio &&
sed -i "s/MODULES=()/MODULES=($INITRAMFS_MODULES)/g" /etc/mkinitcpio.conf &&
echo "Installing linux kernel..." &&
pacman -Sy --noconfirm linux &&
echo "Setup grub" &&
grub-install --target=i386-pc /dev/loop0 &&
grub-mkconfig -o /boot/grub/grub.cfg &&
rm -rf /var/cache/pacman/* &&
echo "done"
