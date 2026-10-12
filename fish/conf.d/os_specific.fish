# OS-specific configuration
switch (uname)
    case Linux
        # WSL
        # abbr --add pc 'cd /mnt/c/Users/Gargo'
        # abbr --add here 'explorer.exe .'
        # abbr --add open wslview
    case Darwin
        # macOS
        if type -q python3
            alias python=python3
        end
    case '*'
end
