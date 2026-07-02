#!/usr/bin/env python3
"""
Script to create symlinks from repository directories to ~/.config/
"""

import argparse
import os
import sys
from pathlib import Path


def get_available_configs(repo_path):
    """Get list of available configuration directories in the repository."""
    configs = []
    # Directories to exclude
    excluded_dirs = {'freelancer', 'themes'}
    
    for item in os.listdir(repo_path):
        item_path = os.path.join(repo_path, item)
        if os.path.isdir(item_path) and not item.startswith('.') and item not in excluded_dirs:
            configs.append(item)
    return sorted(configs)


def create_symlink(source_dir, target_dir):
    """Create a symlink from source to target, handling existing files/directories."""
    target_path = Path(target_dir)
    
    # Remove existing file/directory if it exists
    if target_path.exists() or target_path.is_symlink():
        print(f"Removing existing {target_path}")
        if target_path.is_symlink():
            target_path.unlink()
        elif target_path.is_dir():
            # For non-empty directories, we need to use shutil.rmtree
            # but that might be dangerous, so warn the user
            import shutil
            if any(target_path.iterdir()):  # Check if directory is not empty
                response = input(f"Directory {target_path} exists and is not empty. Remove it? (y/N): ")
                if response.lower() == 'y':
                    shutil.rmtree(target_path)
                else:
                    print(f"Skipping {target_path}")
                    return False
            else:
                # Directory is empty, safe to remove
                target_path.rmdir()
        else:
            # It's a regular file
            target_path.unlink()
    
    # Create parent directory if it doesn't exist
    target_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Create the symlink
    try:
        target_path.symlink_to(source_dir)
        print(f"Created symlink: {target_path} -> {source_dir}")
        return True
    except OSError as e:
        print(f"Failed to create symlink {target_path} -> {source_dir}: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Create symlinks from repository directories to ~/.config/",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s nvim fish          # Create symlinks for nvim and fish configs
  %(prog)s --all              # Create symlinks for all available configs
  %(prog)s tmux wezterm       # Create symlinks for tmux and wezterm configs
        """
    )
    
    parser.add_argument(
        'configs',
        nargs='*',
        help='Configuration directories to create symlinks for. Use --all to link all available configs.'
    )
    
    parser.add_argument(
        '--all',
        action='store_true',
        help='Create symlinks for all available configuration directories'
    )
    
    parser.add_argument(
        '--list',
        action='store_true',
        help='List available configuration directories and exit'
    )
    
    parser.add_argument(
        '--config-dir',
        default=os.path.expanduser('~/.config'),
        help='Target directory for symlinks (default: ~/.config)'
    )
    
    args = parser.parse_args()
    
    # Get the current repository path
    repo_path = Path(__file__).parent.resolve()
    
    # Get available configs
    available_configs = get_available_configs(repo_path)
    
    if args.list:
        print("Available configuration directories:")
        for config in available_configs:
            print(f"  - {config}")
        return 0
    
    # Determine which configs to process
    configs_to_process = []
    
    if args.all:
        configs_to_process = available_configs
    elif args.list:
        return 0  # Already handled above
    elif not args.configs:
        print("Error: Please specify configuration directories or use --all")
        parser.print_help()
        return 1
    else:
        configs_to_process = args.configs
    
    # Validate that specified configs exist
    invalid_configs = []
    for config in configs_to_process:
        config_path = os.path.join(repo_path, config)
        if not os.path.isdir(config_path):
            invalid_configs.append(config)
    
    if invalid_configs:
        print(f"Error: The following configuration directories do not exist: {', '.join(invalid_configs)}")
        print("Available configurations:")
        for config in available_configs:
            print(f"  - {config}")
        return 1
    
    # Create symlinks
    successful = 0
    for config in configs_to_process:
        source_path = os.path.join(repo_path, config)
        target_path = os.path.join(args.config_dir, config)
        
        if create_symlink(source_path, target_path):
            successful += 1
    
    print(f"\nSuccessfully created {successful}/{len(configs_to_process)} symlinks.")
    
    return 0 if successful == len(configs_to_process) else 1


if __name__ == "__main__":
    sys.exit(main())