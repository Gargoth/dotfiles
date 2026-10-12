function wifi_restart
    if not command -q nmcli
        echo "wifi_restart requires NetworkManager's nmcli." >&2
        return 127
    end
    nmcli radio wifi off && nmcli radio wifi on
end
