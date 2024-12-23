# Define a global variable for excluded directories
set -g EXCLUDED_DIRS ".git .cache node_modules .rustup"

# Helper function to generate exclusion pattern
function _generate_exclude_pattern
    set exclude_pattern ""
    for dir in $EXCLUDED_DIRS
        set exclude_pattern "$exclude_pattern -not -path \"./$dir/*\""
    end
    echo $exclude_pattern
end

# Function to perform directory navigation with fzf
function _fzf_change_directory
    if [ (count $argv) -gt 0 ]
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

# Main function to list directories and invoke _fzf_change_directory
function fzf_change_directory
    begin
        # Use find with exclusion pattern
        eval find . -type d (_generate_exclude_pattern) | sed -e 's|^\./||'
    end | _fzf_change_directory $argv
    commandline -f execute
end
