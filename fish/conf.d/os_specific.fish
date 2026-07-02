# OS-specific configuration
switch (uname)
    case Linux
        # WSL
        # abbr --add pc 'cd /mnt/c/Users/Gargo'
        # abbr --add here 'explorer.exe .'
        # abbr --add open wslview
    case Darwin
        # MacOs
        alias python="python3.11"     # To get around janky pip installs
    case '*'
end

