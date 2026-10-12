#!/usr/bin/env python3
"""
Script to create symlinks from repository directories to ~/.config/
"""

import argparse
import os
import sys
from pathlib import Path


CONFIGS = ("fish", "ghostty", "jrnl", "nvim", "tmux", "wezterm")


def get_available_configs(repo_path: Path) -> list[str]:
    """Get list of available configuration directories in the repository."""
    return [name for name in CONFIGS if (repo_path / name).is_dir()]


def backup_path(target_path: Path) -> Path:
    """Choose an unused sibling path for an existing target."""
    candidate = target_path.with_name(f"{target_path.name}.backup")
    suffix = 1
    while candidate.exists() or candidate.is_symlink():
        candidate = target_path.with_name(f"{target_path.name}.backup-{suffix}")
        suffix += 1
    return candidate


def create_symlink(source_dir: Path, target_dir: Path, dry_run: bool = False) -> bool:
    """Create a symlink, preserving any conflicting target as a backup."""
    target_path = target_dir
    if target_path.is_symlink() and target_path.resolve() == source_dir.resolve():
        print(f"Already linked: {target_path} -> {source_dir}")
        return True

    backup = None
    if target_path.exists() or target_path.is_symlink():
        backup = backup_path(target_path)
        if dry_run:
            print(f"Would move existing {target_path} to {backup}")
        else:
            try:
                target_path.replace(backup)
            except OSError as error:
                print(f"Failed to back up {target_path}: {error}")
                return False

    if dry_run:
        print(f"Would create symlink: {target_path} -> {source_dir}")
        return True

    try:
        target_path.parent.mkdir(parents=True, exist_ok=True)
        target_path.symlink_to(source_dir)
        print(f"Created symlink: {target_path} -> {source_dir}")
        return True
    except OSError as error:
        rollback_error = None
        if backup is not None and not target_path.exists() and not target_path.is_symlink():
            try:
                backup.replace(target_path)
            except OSError as restore_error:
                rollback_error = restore_error
        print(f"Failed to create symlink {target_path} -> {source_dir}: {error}")
        if rollback_error is not None:
            print(f"Also failed to restore backup {backup}: {rollback_error}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Create symlinks from repository directories to ~/.config/",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s nvim fish          # Create symlinks for nvim and fish configs
  %(prog)s --all              # Create symlinks for all available configs
  %(prog)s --all --dry-run    # Preview changes without modifying files
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
        default=None,
        help='Target directory for symlinks (default: $XDG_CONFIG_HOME or ~/.config)'
    )

    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show planned changes without modifying files'
    )
    
    args = parser.parse_args()
    
    # Get the current repository path
    repo_path = Path(__file__).parent.resolve()
    xdg_config_home = os.environ.get("XDG_CONFIG_HOME")
    if not xdg_config_home:
        xdg_config_home = str(Path.home() / ".config")
    config_dir = Path(args.config_dir or xdg_config_home).expanduser().resolve()
    
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
    elif not args.configs:
        print("Error: Please specify configuration directories or use --all")
        parser.print_help()
        return 1
    else:
        configs_to_process = args.configs
    
    # Validate that specified configs exist
    invalid_configs = []
    available_set = set(available_configs)
    for config in configs_to_process:
        if config not in available_set:
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
        source_path = repo_path / config
        target_path = config_dir / config

        try:
            linked = create_symlink(source_path, target_path, args.dry_run)
        except OSError as error:
            print(f"Failed to prepare symlink {target_path}: {error}")
            linked = False
        if linked:
            successful += 1
    
    result = "Would create" if args.dry_run else "Created or verified"
    print(f"\n{result} {successful}/{len(configs_to_process)} symlinks.")
    
    return 0 if successful == len(configs_to_process) else 1


if __name__ == "__main__":
    sys.exit(main())
