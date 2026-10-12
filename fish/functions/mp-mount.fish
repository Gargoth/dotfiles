function mp-mount -d "Mount a Multipass instance root filesystem via SSHFS"
    if test (count $argv) -ne 2
        echo "Usage: mp-mount <instance-name> <local-mount-path>" >&2
        return 2
    end
    set -l instance $argv[1]
    set -l mountpoint $argv[2]

    # Check if sshfs is installed
    if not command -q sshfs; or not command -q multipass
        echo "Error: sshfs is not installed on host."
        return 127
    end

    # Get instance IPv4
    set -l info (multipass info "$instance" --format csv 2>/dev/null)
    if test $status -ne 0
        echo "Error: Could not inspect Multipass instance '$instance'." >&2
        return 1
    end
    set -l vm_ip (printf '%s\n' $info | awk -F',' 'NR==2 {print $3}')

    if test -z "$vm_ip"
        echo "Error: Could not retrieve IP for instance '$instance'. Is it running?"
        return 1
    end

    # Install a selected public key as data, never as shell source.
    set -l key_path
    if test -r "$HOME/.ssh/id_ed25519"; and test -r "$HOME/.ssh/id_ed25519.pub"
        set key_path "$HOME/.ssh/id_ed25519"
    else if test -r "$HOME/.ssh/id_rsa"; and test -r "$HOME/.ssh/id_rsa.pub"
        set key_path "$HOME/.ssh/id_rsa"
    else
        echo "Error: No supported SSH key pair found." >&2
        return 1
    end
    set -l pub_key (command cat "$key_path.pub")
    or return
    multipass exec "$instance" -- bash -c 'set -eu; IFS= read -r key; mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"; touch "$HOME/.ssh/authorized_keys"; chmod 600 "$HOME/.ssh/authorized_keys"; if ! grep -Fqx -- "$key" "$HOME/.ssh/authorized_keys"; then printf "%s\n" "$key" >> "$HOME/.ssh/authorized_keys"; fi' \
        < (printf '%s\n' "$pub_key") \
        || begin
            echo "Error: Failed to install public key on '$instance'." >&2
            return 1
        end

    # Create mount directory if it doesn't exist
    if string match -q -- '-*' "$mountpoint"
        set mountpoint "./$mountpoint"
    end
    mkdir -p "$mountpoint"; or return

    # Mount instance root (/) to local directory
    echo "Mounting $instance ($vm_ip:/) to $mountpoint..."
    sshfs -o "IdentityFile=$key_path" "ubuntu@$vm_ip:/" "$mountpoint"

    or return
    echo "Successfully mounted! To unmount later, run:"
    echo "  umount $mountpoint (or fusermount -u $mountpoint)"
end
