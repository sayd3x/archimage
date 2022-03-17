FROM archlinux:base as arch_builder

WORKDIR /root
ENV ROOT_DIR=/root/bootstrap
ENV BUILD_DIR=/tmp/build
ENV OUT_DIR=/tmp/packages
ENV PACKAGES_DIR=/root/bootstrap/root/image/packages

# Prepare bootstrap
RUN pacman -Sy --noconfirm awk sed tar && \
	mkdir $BUILD_DIR && \
	(cd $BUILD_DIR;curl -O https://mirror.yandex.ru/archlinux/iso/latest/md5sums.txt) && \
	BOOTSTRAP_IMAGE=$(cat $BUILD_DIR/md5sums.txt | awk '/archlinux-bootstrap/' | awk '{print $2}') && \
	BOOTSTRAP_IMAGE_CHECKSUM=$(cat $BUILD_DIR/md5sums.txt | awk '/archlinux-bootstrap/' | awk '{print $1}') && \
	(cd $BUILD_DIR;curl -O https://mirror.yandex.ru/archlinux/iso/latest/$BOOTSTRAP_IMAGE) && \
	[[ $(echo $BOOTSTRAP_IMAGE_CHECKSUM) == $(md5sum $BUILD_DIR/$BOOTSTRAP_IMAGE | awk '{print $1}') ]] && \
	tar xzf $BUILD_DIR/$BOOTSTRAP_IMAGE && \
	mv $PWD/root.* $ROOT_DIR && \
	sed -i '/^#.*yandex/s/^#//' $ROOT_DIR/etc/pacman.d/mirrorlist && \
	sed -i 's/\$(lsblk -rno UUID/$(blkid -s UUID -o value/g' $ROOT_DIR/sbin/genfstab && \ 
	sed -i 's/\$(lsblk -rno LABEL/$(blkid -s LABEL -o value/g' $ROOT_DIR/sbin/genfstab && \
	echo MAKEFLAGS=\"-j$(nproc)\" >> /etc/makepkg.conf && \
	rm -rf $BUILD_DIR && \
	rm -rf /var/cache/pacman/*

# Build & install yaourt
RUN cp -f $ROOT_DIR/etc/pacman.d/mirrorlist /etc/pacman.d/ && \
	pacman -Sy --noconfirm base-devel git && \
	echo "nobody ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	mkdir -p $BUILD_DIR $OUT_DIR $PACKAGES_DIR && \
	chmod 777 -R $BUILD_DIR $OUT_DIR && \
	(cd $BUILD_DIR;curl https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz | sudo -u nobody tar xzf -;cd ./package-query;sudo -u nobody HOME=$BUILD_DIR PKGDEST=$OUT_DIR makepkg -si --noconfirm) && \
	(cd $BUILD_DIR;curl https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz | sudo -u nobody tar xzf -;cd ./yaourt;sudo -u nobody HOME=$BUILD_DIR PKGDEST=$OUT_DIR makepkg -si --noconfirm) && \
	cp -r $OUT_DIR/* $PACKAGES_DIR/ && \
	rm -rf $BUILD_DIR $OUT_DIR /var/cache/pacman/*

# Install disk utilities
RUN pacman -Sy --noconfirm qemu-headless && \
	rm -rf /var/cache/pacman/*

ENV ROOT_PASSWD=change_me
ENV PERMIT_ROOT_LOGIN=no
ENV IMAGE_SIZE=3G
ENV BOOT_PARTITION_SIZE=100M
ENV SWAP_PARTITION_SIZE=1G
ENV INITRAMFS_MODULES=""
ENV INSTALL_PACKAGES="docker docker-machine openssh ntp sudo unzip which xfsprogs haveged cloud-init"
ENV AUTOSTART_SERVICES="ntpd.service sshd.service haveged.service docker.service cloud-init.service systemd-resolved.service"

COPY ./start.sh 				/root/
COPY ./prepare_image.sh 		/root/bootstrap/root/
COPY ./setup_environment.sh		/root/bootstrap/root/image/
COPY ./image-root.tar.bz2 		/root/bootstrap/root/image/
