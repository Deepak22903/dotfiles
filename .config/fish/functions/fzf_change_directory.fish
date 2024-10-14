function _fzf_change_directory
    if [ (count $argv) ]
        set fzf_flags --height 40% --border --query "$argv "
    else
        set fzf_flags --height 40% --border
    end

    fzf $fzf_flags | perl -pe 's/([ ()])/\\\\$1/g' | read foo

    if [ $foo ]
        builtin cd $foo
    else
        commandline ''
    end
end

function fzf_change_directory
    begin
        # List directories recursively from current directory
        find . -type d | grep -v '\.git' | sed -e 's/^\.\///'
    end | _fzf_change_directory $argv
    commandline -f execute
end
