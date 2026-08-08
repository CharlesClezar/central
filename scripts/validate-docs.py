#!/usr/bin/env python3
"""Validate local Markdown file links and heading anchors without third-party packages."""

from __future__ import annotations

import re
import sys
import urllib.parse
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
IGNORED_PARTS = {".git", "node_modules", "vendor"}
LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
HEADING_RE = re.compile(r"^#{1,6}\s+(.+?)\s*#*\s*$")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
SCHEMES = ("http://", "https://", "mailto:", "tel:", "data:")


def markdown_files() -> list[Path]:
    return sorted(
        path
        for path in ROOT.rglob("*.md")
        if not any(part in IGNORED_PARTS for part in path.relative_to(ROOT).parts)
    )


def slugify(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text.strip().lower())
    text = re.sub(r"[^\w\- ]", "", text, flags=re.UNICODE)
    return re.sub(r"[\s-]+", "-", text).strip("-")


def anchors(path: Path) -> set[str]:
    found: set[str] = set()
    counts: Counter[str] = Counter()
    in_fence = False
    for line in path.read_text(encoding="utf-8").splitlines():
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        match = HEADING_RE.match(line)
        if not match:
            continue
        base = slugify(match.group(1))
        if not base:
            continue
        suffix = counts[base]
        found.add(base if suffix == 0 else f"{base}-{suffix}")
        counts[base] += 1
    return found


def normalize_target(raw: str) -> str:
    target = raw.strip()
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1]
    if " " in target and not target.startswith("#"):
        target = target.split(maxsplit=1)[0]
    return urllib.parse.unquote(target)


def main() -> int:
    failures: list[str] = []
    anchor_cache: dict[Path, set[str]] = {}

    for source in markdown_files():
        in_fence = False
        for line_number, line in enumerate(source.read_text(encoding="utf-8").splitlines(), 1):
            if FENCE_RE.match(line):
                in_fence = not in_fence
                continue
            if in_fence:
                continue
            for match in LINK_RE.finditer(line):
                target = normalize_target(match.group(1))
                if not target or target.startswith(SCHEMES) or "<" in target or ">" in target:
                    continue

                path_part, separator, anchor = target.partition("#")
                destination = source if not path_part else (source.parent / path_part).resolve()

                try:
                    destination.relative_to(ROOT)
                except ValueError:
                    failures.append(f"{source.relative_to(ROOT)}:{line_number}: link escapes repository: {target}")
                    continue

                if not destination.exists():
                    failures.append(f"{source.relative_to(ROOT)}:{line_number}: missing local target: {target}")
                    continue

                if separator and anchor and destination.is_file() and destination.suffix.lower() == ".md":
                    available = anchor_cache.setdefault(destination, anchors(destination))
                    if anchor.lower() not in available:
                        failures.append(f"{source.relative_to(ROOT)}:{line_number}: missing heading anchor: {target}")

    if failures:
        for failure in failures:
            print(f"ERROR: {failure}", file=sys.stderr)
        return 1

    print("Markdown link validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
