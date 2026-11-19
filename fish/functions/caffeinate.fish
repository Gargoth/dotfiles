function caffeinate
    echo "Now preventing sleep on closed lid. Press Ctrl+C to stop."
    systemd-inhibit --what=handle-lid-switch --why="Temporary lid override" sleep infinity
end
