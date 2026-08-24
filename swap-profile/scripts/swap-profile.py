#!/usr/bin/env python3
"""Move every claude pane in one herdr tab onto another account profile.

Each pane keeps its own herdr slot. The pane exits claude, its transcript is
copied into the target profile, then claude restarts in place with --resume.
Transcripts are per profile, so without the copy --resume finds nothing.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from hashlib import sha256
from pathlib import Path

HOME = Path.home()
FISH_CONFIG = HOME / ".config/fish/config.fish"
# The profile that runs on the plain ~/.claude directory, with no wrapper function.
DEFAULT_PROFILE = os.environ.get("SWAP_PROFILE_DEFAULT", "cl")


def herdr(*args):
    proc = subprocess.run(["herdr", *args], capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"herdr {' '.join(args)} failed: {proc.stderr.strip()}")
    for line in reversed(proc.stdout.strip().splitlines()):
        line = line.strip()
        if line.startswith("{"):
            return json.loads(line).get("result", {})
    return {}


def read_profiles():
    """Map profile name to config dir, from the fish functions that define them."""
    profiles = {}
    text = FISH_CONFIG.read_text()
    for name, body in re.findall(r"^function\s+(\w+)[^\n]*\n(.*?)\n^end$", text, re.S | re.M):
        if "claude" not in body:
            continue
        found = re.search(r"CLAUDE_CONFIG_DIR=(\S+)", body)
        profiles[name] = Path(found.group(1).replace("$HOME", str(HOME))) if found else HOME / ".claude"
    profiles.setdefault(DEFAULT_PROFILE, HOME / ".claude")
    return profiles


def logged_in(config_dir):
    service = "Claude Code-credentials"
    if config_dir != HOME / ".claude":
        service += "-" + sha256(str(config_dir).encode()).hexdigest()[:8]
    return subprocess.run(
        ["security", "find-generic-password", "-s", service],
        capture_output=True,
    ).returncode == 0


def account_of(config_dir):
    for candidate in (config_dir / ".claude.json", HOME / ".claude.json"):
        try:
            data = json.loads(candidate.read_text())
        except Exception:
            continue
        account = data.get("oauthAccount") or {}
        if account.get("emailAddress"):
            return account["emailAddress"]
        break
    return "unknown"


def config_file(config_dir):
    """The profile config. The default profile keeps it outside its config dir."""
    inside = config_dir / ".claude.json"
    return inside if inside.exists() else HOME / ".claude.json"


def preaccept(config_dir, cwd):
    """Answer every startup gate in the target profile before the pane starts.

    Each config dir keeps its own answers, and the target profile has never
    seen this directory. Without this the pane stops on the trust dialog and
    on the bypass-permissions warning, and waits for a keypress.
    """
    done = []
    path = config_file(config_dir)
    try:
        data = json.loads(path.read_text())
    except Exception:
        return done
    project = data.setdefault("projects", {}).setdefault(str(cwd), {})
    dirty = False
    if project.get("hasTrustDialogAccepted") is not True:
        project["hasTrustDialogAccepted"] = True
        dirty = True
    if data.get("bypassPermissionsModeAccepted") is not True:
        data["bypassPermissionsModeAccepted"] = True
        dirty = True
    if dirty:
        path.write_text(json.dumps(data, indent=2))
        done.append(f"config {path}")

    # herdr can restore a pane without the launcher flags, so bypass has to
    # live in settings too, not only in --dangerously-skip-permissions.
    settings = config_dir / "settings.json"
    try:
        conf = json.loads(settings.read_text()) if settings.exists() else {}
    except Exception:
        return done
    perms = conf.setdefault("permissions", {})
    if perms.get("defaultMode") != "bypassPermissions":
        perms["defaultMode"] = "bypassPermissions"
        settings.parent.mkdir(parents=True, exist_ok=True)
        settings.write_text(json.dumps(conf, indent=2))
        done.append(f"defaultMode {settings}")
    return done


def project_slug(cwd):
    return str(cwd).replace("/", "-")


def find_transcript(session_id):
    for projects in sorted(HOME.glob(".claude*/projects")):
        for path in projects.glob(f"*/{session_id}.jsonl"):
            return path
    return None


def panes_in_tab(tab_id, exclude):
    panes = herdr("pane", "list").get("panes", [])
    return [p for p in panes if p.get("tab_id") == tab_id and p["pane_id"] != exclude]


def wait_for_shell(pane_id, timeout=45):
    """Return True once the pane no longer runs an agent."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        pane = herdr("pane", "get", pane_id).get("pane", {})
        if not pane.get("agent"):
            return True
        time.sleep(1)
    return False


def swap_pane(pane, profile, config_dir, message, dry_run):
    pane_id = pane["pane_id"]
    name = pane.get("terminal_title_stripped") or pane_id
    session = (pane.get("agent_session") or {}).get("value")
    if pane.get("agent") != "claude" or not session:
        return {"pane": pane_id, "name": name, "status": "skipped", "why": "no claude session"}

    source = find_transcript(session)
    if source is None:
        return {"pane": pane_id, "name": name, "status": "failed", "why": "transcript not found"}

    cwd = pane.get("foreground_cwd") or pane.get("cwd") or str(HOME)
    target = config_dir / "projects" / project_slug(cwd) / f"{session}.jsonl"
    if dry_run:
        return {"pane": pane_id, "name": name, "status": "dry-run", "session": session,
                "from": str(source), "to": str(target)}

    herdr("pane", "send-text", pane_id, "/exit")
    herdr("pane", "send-keys", pane_id, "enter")
    if not wait_for_shell(pane_id):
        return {"pane": pane_id, "name": name, "status": "failed", "why": "claude did not exit"}

    target.parent.mkdir(parents=True, exist_ok=True)
    if source.resolve() != target.resolve():
        shutil.copy2(source, target)

    preaccepted = preaccept(config_dir, cwd)
    herdr("pane", "run", pane_id, profile, "--resume", session)
    try:
        herdr("agent", "wait", pane_id, "--until", "idle", "--timeout", "180000")
    except RuntimeError as error:
        return {"pane": pane_id, "name": name, "status": "failed", "why": str(error)}

    if message:
        herdr("agent", "prompt", pane_id, message)
    return {"pane": pane_id, "name": name, "status": "swapped", "session": session,
            "profile": profile, "preaccepted": preaccepted}


def main():
    parser = argparse.ArgumentParser(description="Swap a herdr tab onto another claude profile")
    parser.add_argument("--profile", help="target profile name, for example work")
    parser.add_argument("--tab", help="tab id (default: the tab this script runs in)")
    parser.add_argument("--message", default="continue", help='prompt sent after resume ("" for none)')
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--close-self", action="store_true", help="close the calling pane at the end")
    parser.add_argument("--list-profiles", action="store_true")
    args = parser.parse_args()

    profiles = read_profiles()
    if args.list_profiles:
        for name, path in profiles.items():
            state = "logged in" if logged_in(path) else "NOT logged in"
            print(f"{name}\t{path}\t{state}\t{account_of(path)}")
        return 0

    if not args.profile:
        parser.error("--profile is required")
    if args.profile not in profiles:
        print(f"unknown profile {args.profile}; known: {', '.join(profiles)}", file=sys.stderr)
        return 2
    config_dir = profiles[args.profile]
    if not logged_in(config_dir):
        print(f"{args.profile} has no credentials in the keychain; run /login there first",
              file=sys.stderr)
        return 2

    current = herdr("pane", "current").get("pane", {})
    self_pane = current.get("pane_id")
    tab_id = args.tab or current.get("tab_id")
    targets = panes_in_tab(tab_id, self_pane)

    results = [swap_pane(p, args.profile, config_dir, args.message, args.dry_run) for p in targets]
    summary = {"tab": tab_id, "profile": args.profile, "account": account_of(config_dir),
               "self_pane": self_pane, "panes": results}
    print(json.dumps(summary, indent=2))

    if args.close_self and not args.dry_run and self_pane:
        herdr("pane", "close", self_pane)
    return 0


if __name__ == "__main__":
    sys.exit(main())
