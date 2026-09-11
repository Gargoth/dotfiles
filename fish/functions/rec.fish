function rec
    set -l recording_dir "$HOME/Documents/asciinema/"
    mkdir -p $recording_dir
    set -l recording_path $recording_dir(date)".cast"
    asciinema rec $recording_path
end
