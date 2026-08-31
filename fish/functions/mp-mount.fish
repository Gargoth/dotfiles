function mp-mount -d "Mount a Multipass instance root filesystem via SSHFS"
    # Parse arguments
    set -l instance $argv[1]
    set -l mountpoint $argv[2]

    # Show help if arguments are missing
    if test -z "$instance" -o -z "$mountpoint"
        echo "Usage: mount-multipass <instance-name> <local-mount-path>"
        return 1
    end

    # Check if sshfs is installed
    if not command -v sshfs >/dev/null
        echo "Error: sshfs is not installed on host."
        return 1
    end

    # Get instance IPv4
    set -l vm_ip (multipass info $instance --format csv 2>/dev/null | awk -F',' 'NR==2 {print $3}')

    if test -z "$vm_ip"
        echo "Error: Could not retrieve IP for instance '$instance'. Is it running?"
        return 1
    end

    # Auto-push host SSH key if not already authorized
    if test -f ~/.ssh/id_ed25519.pub
        set -l pub_key (cat ~/.ssh/id_ed25519.pub)
        multipass exec $instance -- bash -c "mkdir -p ~/.ssh && grep -qF '$pub_key' ~/.ssh/authorized_keys 2>/dev/null || echo '$pub_key' >> ~/.ssh/authorized_keys" 2>/dev/null
    else if test -f ~/.ssh/id_rsa.pub
        set -l pub_key (cat ~/.ssh/id_rsa.pub)
        multipass exec $instance -- bash -c "mkdir -p ~/.ssh && grep -qF '$pub_key' ~/.ssh/authorized_keys 2>/dev/null || echo '$pub_key' >> ~/.ssh/authorized_keys" 2>/dev/null
    end

    # Create mount directory if it doesn't exist
    mkdir -p $mountpoint

    # Mount instance root (/) to local directory
    echo "Mounting $instance ($vm_ip:/) to $mountpoint..."
    sshfs ubuntu@$vm_ip:/ $mountpoint

    if test $status -eq 0
        echo "Successfully mounted! To unmount later, run:"
        echo "  umount $mountpoint (or fusermount -u $mountpoint)"
    end
end
