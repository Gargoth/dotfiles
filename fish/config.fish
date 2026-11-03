if status is-interactive
    # Keep vi mode global and remove any older universal default.
    fish_vi_key_bindings
    set --erase --universal fish_key_bindings
end
