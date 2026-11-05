# opencode
fish_add_path $HOME/.opencode/bin

if status is-interactive
    # Commands to run in interactive sessions can go here

    # Replace standard ls with eza
    alias ls="eza --icons=always --color=always"
    alias l="eza -lbF --icons=always"
    alias ll="eza -la --icons=always"
    alias llm="eza -lbGd --icons=always --sort=modified"
    alias tree="eza --tree --icons=always"
end
