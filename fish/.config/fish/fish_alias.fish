alias ls "eza -lh -g --icons"
alias ll "ls -a"
alias tree "ls --level 2 --tree --icons --git"
alias cat bat
# alias htop btop
alias ripman tldr
alias anime "ani-cli -q 1080 -v"
alias hotspot="sudo create_ap --no-virt wlan0 eno1 'Deepak\'s Arch' password"
#alias hotspot=" nmcli dev wifi hotspot ifname wlan0 ssid test password "test1234" "
alias timet "open /home/deepak/Downloads/class_TY-Div2.pdf"
alias gp "/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/git/git_push.sh"
alias v nvim
alias gs "git status"
# alias bluec "/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/kde_connect/bluetooth_connect_headphones.sh"
# alias blued "/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/kde_connect/bluetooth_disconnect_headphones.sh"
# alias hotspot_off "/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/global/hotspot_stop.sh"
alias cd z
alias ydl="yt-dlp"
alias ydlmp4='yt-dlp -f "bestvideo&#91;ext=mp4]+bestaudio&#91;ext=m4a]/best&#91;ext=mp4]/best"'
alias ydlmkv='yt-dlp -f "bestvideo&#91;ext=mkv]+bestaudio&#91;ext=mka]/best&#91;ext=mkv]/best"'
alias back="/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/global/backup_data.sh"
alias batt="cat /sys/class/power_supply/BAT0/capacity"
alias unet="/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/global/connect_internet.sh"
alias dnet="/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/global/disconnect_internet.sh"
alias load="source ~/.config/fish/config.fish"
alias blue="/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/global/blue.sh"
alias offhotspot="/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/kde_connect/offhotspot.sh"
alias peekdeepftp="/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/global/ftp_mount.sh"
alias rnetm="sudo /home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/misc/NetworkManagerConfAddComment.sh /etc/NetworkManager/NetworkManager.conf 6"
alias tt="xdg-open /home/deepak/Downloads/class_TY-Div2-2.pdf"
alias clock="tty-clock -c -C 5 -t"
alias system_maintain="/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/global/clear_arch_cache.sh"
# alias cl=clear
# alias comp="g++ src/main.cpp src/functions.cpp src/fb_pages.cpp -o my_program -lcurl -lPocoFoundation"
alias copyf="/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/global/copyf.fish"
alias findd="/home/deepak/ghq/github.com/Deepak22903/My_Shell_Scripts/global/findd.fish"
alias stl="mupdf -I -C FFFAF0 /home/deepak/Downloads/Cpp_STL_ReferenceManual.pdf"
alias mountPhone="sshfs kdeconnect@10.1.234.89:/storage/emulated/0 /home/deepak/Realme\ 6Pro/ -p 1739 \
            -o IdentityFile=/home/deepak/.config/kdeconnect/privateKey.pem \
            -o uid=1000 -o gid=1000 -o allow_other"
alias umountPhone="sudo umount -l /home/deepak/Realme\ 6Pro/"
alias f=yazi

function ce
    $argv 2>&1 | wl-copy
end

function nst
    set_color green
    for interface in (nmcli -t connection show --active | cut -d':' -f4 | grep -v '^lo$')
        set name (nmcli -t connection show --active | grep $interface | cut -d':' -f1)
        echo -n "$name - "

        # Get network statistics using ifstat and format the output
        ifstat | awk -v iface=$interface '$1 == iface {
            down = $6 / 1024  # Convert to MB/s
            up = $8 / 1024    # Convert to MB/s
            printf "%s %.2f MB/s, %s %.2f MB/s\n", 
                   (down ? ("\033[0;32m↓\033[0m") : ""), down, 
                   (up ? ( "\033[0;32m↑\033[0m") : ""), up
        }'
    end
    set_color normal
end
