repodir="/tmp/repodir"
mkdir "$repodir"
browser="firefox"
terminal="kitty"
root="sudo"
aurpkgs=(
    vim-plug
    yay
    picom-pijulius-git
)
pacmanpkgs=(
    feh
    emacs
    vim
    neovim
    "$browser"
    "$terminal"
    doas
    networkmanager
    imlib2
    xorg-xinit
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
)    
xinitlines=(
    "picom -b"
    "emacs --daemon &"
    "dwmblocks &"
    "dunst &"
    "flameshot &"
    "~/.fehbg"
)
makeinit() {
    for i in "${array[@]}"
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
        makepkg --noconfirm -si >/dev/null || return 1
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
