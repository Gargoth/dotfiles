function git_stats
    # Define colors using fish natives for better maintainability
    set -l cyan (set_color cyan)
    set -l dim (set_color white --dim)
    set -l reset (set_color normal)
    set -l bold (set_color --bold)

    # We pass the colors into awk using the -v flag
    git log --reverse --date=short --format="DATA#%ad#%s" --shortstat $argv | awk -F'#' \
    -v cyan="$cyan" -v dim="$dim" -v reset="$reset" -v bold="$bold" '
    BEGIN {
        # Print Headers
        printf "%s%sDate       %s|%s %-55s %s|%s %sMessage%s\n", bold, cyan, dim, reset, "Changes", dim, reset, bold, reset;
        printf "%s-----------|----------------------------------------------------|-------------------%s\n", dim, reset;
    }
    /^DATA/ { 
        date=$2; 
        msg=$3; 
        next 
    } 
    /files? changed/ { 
        gsub(/^[ \t]+|[ \t]+$/, "", $0);
        # Align the data rows with the headers
        printf "%s%s%s %s|%s %-55s %s|%s %s\n", cyan, date, reset, dim, reset, $0, dim, reset, msg 
    }'
end
