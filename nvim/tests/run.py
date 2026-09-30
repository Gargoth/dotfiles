"""Run real Neovim configuration checks in a project-local XDG sandbox."""

import json
import os
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
sandbox = root / ".task"
for kind in ("config", "data", "state", "cache"):
    (sandbox / kind).mkdir(parents=True, exist_ok=True)
config = sandbox / "config" / "nvim-config-test"
if not config.exists():
    config.symlink_to(root, target_is_directory=True)
if config.resolve() != root:
    raise SystemExit(f"Unexpected test config location: {config}")

env = os.environ.copy()
env.update(
    {f"XDG_{kind.upper()}_HOME": str(sandbox / kind) for kind in ("config", "data", "state", "cache")}
)
env["NVIM_APPNAME"] = "nvim-config-test"
env["NVIM_TEST_MODE"] = sys.argv[1] if len(sys.argv) > 1 else "test"
lockfile = root / "lazy-lock.json"
pins = json.loads(lockfile.read_text())
result = subprocess.run(
    [os.environ.get("NVIM", "nvim"), "--headless", "-i", "NONE", "-u", str(root / "tests" / "init.lua")],
    cwd=root,
    env=env,
    text=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    timeout=600,
)
print(result.stdout, end="")
restored_pins = json.loads(lockfile.read_text())
for name, pin in pins.items():
    if name not in restored_pins or restored_pins[name]["commit"] != pin["commit"]:
        raise SystemExit(f"Verification unexpectedly changed the plugin pin for {name}")
# Neovim may exit successfully after an asynchronous callback error.
errors = ("Error in", "Error executing", "E5113:", "Failed to run `config`", "Failed to load", "stack traceback:")
raise SystemExit(result.returncode or (1 if any(error in result.stdout for error in errors) else 0))
