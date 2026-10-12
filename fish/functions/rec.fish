function rec
    if not command -q asciinema
        echo "rec requires asciinema." >&2
        return 127
    end
    set -l recording_dir "$HOME/Documents/asciinema"
    command mkdir -p "$recording_dir"; or return
    set -l timestamp (date '+%Y-%m-%d_%H-%M-%S'); or return
    set -l recording_path "$recording_dir/$timestamp.cast"
    set -l suffix 1
    while test -e "$recording_path"
        set recording_path "$recording_dir/$timestamp-$suffix.cast"
        set suffix (math $suffix + 1)
    end
    asciinema rec "$recording_path"
end
