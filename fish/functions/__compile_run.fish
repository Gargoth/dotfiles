function __compile_run --argument-names compiler
    set -l compiler_args $argv[2..-1]
    if test (count $compiler_args) -lt 1
        echo "Usage: $compiler <source-file> [compiler-options...]" >&2
        return 2
    end
    if not command -q "$compiler"
        echo "Required compiler not found: $compiler" >&2
        return 127
    end

    set -l temp_dir /tmp
    if set -q TMPDIR; and test -n "$TMPDIR"
        set temp_dir "$TMPDIR"
    end
    set -l binary (command mktemp "$temp_dir/dotfiles-compile.XXXXXX")
    or return
    command rm -f -- "$binary"
    command "$compiler" $compiler_args -o "$binary"
    set -l compile_status $status
    if test $compile_status -ne 0
        command rm -f -- "$binary"
        return $compile_status
    end

    chmod +x "$binary"; or begin
        command rm -f -- "$binary"
        return 1
    end
    "$binary"
    set -l program_status $status
    command rm -f -- "$binary"
    return $program_status
end
