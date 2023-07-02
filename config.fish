if status is-interactive
    # Commands to run in interactive sessions can go here
end

eval (/opt/homebrew/bin/brew shellenv)

set PATH /usr/local/bin $PATH
set PATH /opt/homebrew/bin/ $PATH
fish_add_path ~/.cargo/bin/

alias vi="nvim"

direnv hook fish | source
starship init fish | source
