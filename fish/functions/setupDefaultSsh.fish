function setupDefaultSsh
    set -l agent_usable 0
    if set -q SSH_AUTH_SOCK
        ssh-add -l >/dev/null 2>&1
        if test $status -le 1
            set agent_usable 1
        end
    end
    if test $agent_usable -eq 0
        if not command -q ssh-agent
            echo "ssh-agent is not installed." >&2
            return 127
        end
        set -l agent_output (ssh-agent -c); or return
        set -gx SSH_AUTH_SOCK (string match -r "SSH_AUTH_SOCK='([^']+)';" -- "$agent_output")[2]
        set -gx SSH_AGENT_PID (string match -r "SSH_AGENT_PID=([0-9]+);" -- "$agent_output")[2]
        if test -z "$SSH_AUTH_SOCK"; or test -z "$SSH_AGENT_PID"
            echo "Failed to read ssh-agent environment." >&2
            return 1
        end
    end
    ssh-add
end
