function git_stats
    # Define colors using fish natives for better maintainability
    set -l cyan (set_color cyan)
    set -l dim (set_color white --dim)
    set -l reset (set_color normal)
    set -l bold (set_color --bold)

    set -l revision_args $argv
    if test (count $revision_args) -eq 0
        set revision_args --all
    end
    git log --reverse --date=short --format="DATA#%ad#%s" --shortstat $revision_args | awk -F'#' \
    -v cyan="$cyan" -v dim="$dim" -v reset="$reset" -v bold="$bold" '
    BEGIN {
        # Print Headers
        printf "%s%sDate       %s|%s %-55s %s|%s %sMessage%s\n", bold, cyan, dim, reset, "Changes", dim, reset, bold, reset;
        printf "%s-----------|----------------------------------------------------|-------------------%s\n", dim, reset;
    }
    /^DATA/ { 
        date=$2;
        msg="";
        for (field = 3; field <= NF; field++) {
            msg = msg (field == 3 ? "" : "#") $field;
        }
        stat="";
        next 
    } 
    /files? changed/ { 
        gsub(/^[ \t]+|[ \t]+$/, "", $0);
        stat=$0;
        # Align the data rows with the headers
        printf "%s%s%s %s|%s %-55s %s|%s %s\n", cyan, date, reset, dim, reset, $0, dim, reset, msg;
        next;
    }
    /^$/ {
        if (date != "" && stat == "") {
            printf "%s%s%s %s|%s %-55s %s|%s %s\n", cyan, date, reset, dim, reset, "0 files changed", dim, reset, msg;
            date="";
            msg="";
        }
    }
    END {
        if (date != "" && stat == "") {
            printf "%s%s%s %s|%s %-55s %s|%s %s\n", cyan, date, reset, dim, reset, "0 files changed", dim, reset, msg;
        }
    }'
end
