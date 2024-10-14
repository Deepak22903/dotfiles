set -g fish_greeting ""

zoxide init fish | source

set -gx PATH ~/.local/bin $PATH

source ~/.config/fish/config-linux.fish

# Source custom peco change directory function
source ~/.config/fish/functions/fzf_change_directory.fish

# Bind Ctrl+F to the _peco_change_directory function
bind \cf fzf_change_directory

# Source custom peco select history function
source ~/.config/fish/functions/fzf_select_history.fish

# Bind Ctrl+R to the peco_select_history function
bind \cr fzf_select_history

# Source fzf select and copy function
source ~/.config/fish/functions/fzf_select_and_copy.fish

# Bind the function to Ctrl+S
bind \cs fzf_select_and_copy

if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fzf_open_file
    set file (find . -type f -print0 | xargs -0 realpath | fzf --height 40% --border --preview 'bat --style=numbers --color=always {} | head -100')
    if test -n "$file"
        nvim "$file"
    end
    commandline -f execute
end

# Bind Ctrl+o to open file
bind \co fzf_open_file


# Created by `pipx` on 2024-08-24 15:51:49
set PATH $PATH /home/deepak/.local/bin

# set -l idle_time 5  # Set inactivity time in seconds (300 seconds = 5 minutes)
# #
# # function run_pipes
# #     pipes.sh
# # end
# #
# # function check_inactivity
# #     while true
# #         read -t 5 -P 'Press any key to cancel pipes.sh from running...' -n 1
# #         if test $status -eq 142
# #             run_pipes
# #         end
# #     end
# # end
# #
# # check_inactivity &
# #
#
# set marker_file ~/.last_terminal_start
#
# # Check if the marker file exists and is older than the current session
# if test ! -f $marker_file
#     touch $marker_file
#     fortune -s | cowsay -f tux
#     echo ""
#     # pokemon-colorscripts -sr | cat || true
# else if test (date +%s -r $marker_file) -lt (date +%s -r /proc/uptime)
#     # Update the marker file
#     touch $marker_file
#     fortune -s | cowsay -f tux
#     echo ""
#     # pokemon-colorscripts -sr | cat || true
# end

set -Ux fish_user_paths /var/lib/snapd/snap/bin $fish_user_paths

source /opt/miniconda3/etc/profile.d/conda.fish

set BAT_THEME "Catppuccin Mocha"
