function neorg
    set -l notes_dir "$HOME/Neorg"
    mkdir -p "$notes_dir"; or return
    cd -- "$notes_dir"
end
