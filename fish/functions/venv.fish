function venv
    set -l activation_file
    if test -r .venv/bin/activate.fish
        set activation_file .venv/bin/activate.fish
    else if test -r venv/bin/activate.fish
        set activation_file venv/bin/activate.fish
    else
        echo "No .venv/bin/activate.fish or venv/bin/activate.fish in the current directory." >&2
        return 1
    end
    source "$activation_file"
end
