function _auto_venv --on-variable PWD
    if type -q deactivate
        deactivate
    end
    if test -e "./.venv/bin/activate.fish"
        source ./.venv/bin/activate.fish
    end
end
