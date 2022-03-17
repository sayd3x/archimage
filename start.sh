#/bin/bash

$ROOT_DIR/bin/arch-chroot $ROOT_DIR /root/prepare_image.sh
echo "Converting RAW image to qcow2..."
qemu-img convert -O qcow2 $ROOT_DIR/hdd.image $ROOT_DIR/hdd.qcow2
rm -f $ROOT_DIR/hdd.image
echo "done"
