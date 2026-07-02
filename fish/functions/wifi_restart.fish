function wifi_restart
    nmcli radio wifi off && nmcli radio wifi on
end
