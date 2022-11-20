#!/bin/bash
echo -e "d\nd\nd\nd\n\n\nw" | fdisk /dev/sda
echo -e "n\np\n1\n\n+1G\nw" | fdisk /dev/sda
echo -e "n\np\n2\n\n\nw" | fdisk /dev/sda
mkdir /mnt
mkfs.fat -F32 /dev/sda1
mkfs.xfs /dev/sda2
mount /dev/sda2 /mnt
timedatectl set-timezone Canada/Eastern
pacstrap /mnt base linux linux-firmware nano neofetch
genfstab -U /mnt >> /mnt/etc/fstab
cat << EOF | arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Canada/Eastern /etc/localtime
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo cuckold-desktop > /etc/hostname
touch /etc/hosts
echo "127.0.0.1     localhost" > /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1     cuckold-desktop" >> /etc/hosts
echo -e "cuckmcfuck\ncuckmcfuck" | passwd root
yes | pacman -S grub efibootmgr
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m cuck
echo -e "cuck\ncuck" | passwd art
yes | pacman -S sudo nano
sed -i '80i cuck ALL=(ALL) ALL' /etc/sudoers
pacman -S --noconfirm xorg-xinit xorg git base-devel networkmanager emacs imlib2
cd /usr/src
git clone github.com/kavulox/dwm
systemctl enable NetworkManager.service
cd dwm
make clean install
cd ..
pacman -S dmenu --noconfirm
pacman -Syy alacritty feh firefox nvidia --noconfirm
echo "exec dwm" > /home/art/.xinitrc 
sudo pacman -S bluez --noconfirm
sudo pacman -S bluez-utils --noconfirm
sudo pacman -S blueman --noconfirm
sudo systemctl enable bluetooth.service
sudo pacman -S pulseaudio --noconfirm
sudo pacman -S pulseaudio-bluetooth --noconfirm
sudo systemctl start pulseaudio
sudo pacman -S pavucontrol --noconfirm
EOF
