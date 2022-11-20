repodir="/tmp/repodir"
mkdir "$repodir"
mkdir ~/.config
browser="firefox"
terminal="kitty"
root="sudo"
host="$USER"
installqemukvm=false
installvirtbox=false


neededpkgs=(
    jq
    reflector
)

"$root" pacman -Syy
for i in "${neededpkgs[@]}"
do
    "$root" pacman -S "$i" --noconfirm
done

qemukvmpkgs=(
    libvirt
    virt-viewer
    dnsmasq
    vde2
    bridge-utils
    openbsd-netcat
    ebtables
    libguestfs
    qemu-arch-extra
    ovmf
    edk2-armvirt
)
qemukvmcmds=(
    "$root modprobe -r kvm_intel"
    "$root modprobe kvm_intel nested=1"
    "$root systemctl enable --now libvirtd"
    "echo \"options kvm-intel nested=1\" | sudo tee /etc/modprobe.d/kvm-intel.conf"
    "$root usermod -a -G libvirt $host"
    "$root echo \"unix_sock_group = \"libvirt\"\" >> /etc/libvirt/libvirtd.conf"
    "$root echo \"unix_sock_rw_perms= \"0770\"\" >> /etc/libvirt/libvirtd.conf"
    "$root systemctl restart libvirtd"
    "$root systemctl enable virtlogd"
    "$root systemctl start virtlogd"
    "$root virt net-start default"
    "$root virsh net-autostart default"
)

virtboxpkgs=(
    virtualbox
    virtualbox-guest-iso
)
virtboxcmds=(
    "$root modprobe -a vboxguest vboxsf vboxvideo"
)

aurpkgs=(
    vim-plug
    yay
    picom-pijulius-git
)
pacmanpkgs=(
    feh
    emacs
    cmake
    ttf-inconsolata
    vim
    neovim
    "$browser"
    "$terminal"
    doas
    networkmanager
    imlib2
    xorg
    xorg-xinit
    base-devel
    bluez
    bluez-utils
    blueman
    pulseaudio
    pulseaudio-bluetooth
    pavucontrol
    dunst
    libnotify
    flameshot
    rofi
    openssh
    openssl
)
xinitlines=(
    "picom --experimental-backends &"
    "emacs --daemon &"
    "dwmblocks &"
    "dunst &"
    "flameshot &"
    "~/.fehbg"
    "exec dwm"
)
makeinit() {
    for i in "${xinitlines[@]}"
    do
        echo "$i" >> "$1"
    done
}
cleartmpdir() {
    if [ -d "$repodir" ]
    then
        rm -rf "$repodir"
    fi
}

manualinstall() {
    git clone "https://aur.archlinux.org/$1.git" "$repodir/$1"
    if [ -d "$repodir/$1" ]
    then
        cd "$repodir/$1"
        echo "Building package: $1"
        makepkg --noconfirm -si || return 1
    else
        echo "Error cloning $1 to directory $repodir/$1"
    fi
}

makeinstall() {
    git clone "https://github.com/$1/$2" "$repodir/$1/$2"
    cd "$repodir/$1/$2"
    "$root" make clean install
}

installdotfile() {
    mkdir "$3"
    git clone "https://github.com/$1/$2" "$repodir/$1/$2"
    cd "$repodir/$1/$2"
    mv * "$3"
}

updatemirrorlist() {
    cc=$(sed -e 's/^"//' -e 's/"$//' <<<$(curl -s ipinfo.io/ | jq ".country"))
    reflector --country "$cc" > "$repodir/mirrorlist"
    cp "$repodir/mirrorlist /etc/pacman.d/mirrorlist"
}
updatemirrorlist
"$root" pacman -S git --noconfirm
for i in "${aurpkgs[@]}"
do
    manualinstall "$i"
done
for i in "${pacmanpkgs[@]}"
do
    "$root" pacman -S "$i" --noconfirm
done
# install my dotfiles



makeinstall kavulox dwm
makeinstall kavulox dwmblocks
installdotfile kavulox emacs ~/.emacs.d
installdotfile kavulox nvim ~/.config/nvim
installdotfile kavulox picom ~/.config/picom

cleartmpdir
makeinit ~/.xtmp

if [ "$installvirtbox" = true ]
then
    for i in "${virtboxpkgs[@]}"
    do
        "$root" pacman -S "$i" --noconfirm
    done
    for i in "${virtboxcmds[@]}"
    do
         /bin/sh -c "$i"
    done
fi
if [ "$installqemukvm" = true ]
then
    for i in "${qemukvmpkgs[@]}"
    do
        "$root" pacman -S "$i" --noconfirm
    done
    for i in "${qemukvmcmds[@]}"
    do
         /bin/sh -c "$i"
    done
fi

# trigger emacs installation
emacs --daemon
