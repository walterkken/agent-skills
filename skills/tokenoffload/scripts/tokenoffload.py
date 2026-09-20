#!/usr/bin/env python3
"""TokenOffload local capability helper.

Read-only utility. Uses only Python standard library.
It inventories common deterministic tools so an AI agent can route work locally
before spending model context.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
from collections import Counter
from pathlib import Path

TOOLS = {
    "search": ["rg", "grep", "fd", "find"],
    "data": ["jq", "sqlite3", "csvkit"],
    "documents": ["pdftotext", "pdfinfo", "pandoc"],
    "media": ["ffmpeg", "ffprobe", "magick", "convert"],
    "dev": ["git", "python", "python3", "node", "npm"],
    "archive": ["tar", "zip", "unzip", "7z"],
}

def doctor() -> int:
    found = {}
    for group, commands in TOOLS.items():
        present = []
        for cmd in commands:
            path = shutil.which(cmd)
            if path:
                present.append({"command": cmd, "path": path})
        found[group] = present
    print(json.dumps(found, ensure_ascii=False, indent=2))
    return 0

def scan(path: str, max_files: int) -> int:
    root = Path(path).expanduser().resolve()
    if not root.exists():
        raise SystemExit(f"Path not found: {root}")

    ext = Counter()
    files = 0
    dirs = 0
    total_bytes = 0

    for current, dirnames, filenames in os.walk(root):
        dirs += len(dirnames)
        for name in filenames:
            p = Path(current) / name
            files += 1
            ext[p.suffix.lower() or "<none>"] += 1
            try:
                total_bytes += p.stat().st_size
            except OSError:
                pass
            if files >= max_files:
                break
        if files >= max_files:
            break

    out = {
        "root": str(root),
        "files_scanned": files,
        "directories_seen": dirs,
        "bytes_seen": total_bytes,
        "top_extensions": ext.most_common(20),
        "truncated": files >= max_files,
    }
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Inventory local capabilities before escalating work to an LLM."
    )
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("doctor", help="Show useful local deterministic tools already installed.")

    p_scan = sub.add_parser("scan", help="Summarize a directory without reading file contents.")
    p_scan.add_argument("path")
    p_scan.add_argument("--max-files", type=int, default=10000)

    args = parser.parse_args()
    if args.command == "doctor":
        return doctor()
    if args.command == "scan":
        return scan(args.path, args.max_files)
    return 2

if __name__ == "__main__":
    raise SystemExit(main())
