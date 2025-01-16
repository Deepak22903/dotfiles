function fzf_select_and_copy
    set file (find . -type f -print0 | xargs -0 realpath | fzf --height 40% --border --preview 'bat --style=numbers --color=always {} | head -100')
    if test -n "$file"
        echo -n "$file" | wl-copy
    end
    commandline -f execute
end
