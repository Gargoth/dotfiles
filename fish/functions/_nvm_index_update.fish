function _nvm_index_update
    test -d "$nvm_data"; or command mkdir -p "$nvm_data"; or return

    set --local index "$nvm_data/.index"
    set --local download "$index.download"
    set --local formatted "$index.formatted"

    if not command curl --fail --location --silent --show-error "$nvm_mirror/index.tab" > "$download"
        command rm -f "$download" "$formatted"
        echo "nvm: Can't update index, host unavailable: \"$nvm_mirror\"" >&2
        return 1
    end
    if not command awk 'NR == 1 { valid = ($1 == "version") } END { exit !valid }' "$download"
        command rm -f "$download" "$formatted"
        echo "nvm: Downloaded Node index is invalid." >&2
        return 1
    end

    command awk -v OFS=\t '
        /v0.9.12/ { exit } # Unsupported
        NR > 1 {
            print $1 (NR == 2  ? " latest" : $10 != "-" ? " lts/" tolower($10) : "")
        }
    ' "$download" > "$formatted"; or begin
        command rm -f "$download" "$formatted"
        return 1
    end

    if not command mv -f "$formatted" "$index"
        command rm -f "$download" "$formatted"
        return 1
    end
    command rm -f "$download"
end
