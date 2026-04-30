#!/usr/bin/env python3
"""Check Arabic/English localization resources for structural parity."""

from __future__ import annotations

import argparse
import json
import plistlib
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


ARABIC_RE = re.compile(r"[\u0600-\u06ff]")
LATIN_RE = re.compile(r"[A-Za-z]")
PLACEHOLDER_RE = re.compile(
    r"%(?:\d+\$)?(?:[-+#0 ]*)?(?:\d+|\*)?(?:\.(?:\d+|\*))?[hlLzjtq]?[A-Za-z@]"
    r"|\{[A-Za-z_][A-Za-z0-9_]*\}"
    r"|%\([A-Za-z_][A-Za-z0-9_]*\)[A-Za-z@]"
)


@dataclass(frozen=True)
class Entry:
    source: str
    key: str
    value: str


@dataclass(frozen=True)
class Finding:
    severity: str
    source: str
    key: str
    message: str


def decode_quoted(value: str) -> str:
    if "\\" not in value:
        return value
    try:
        return bytes(value, "utf-8").decode("unicode_escape")
    except UnicodeDecodeError:
        return value


def parse_strings_file(path: Path) -> dict[str, Entry]:
    text = path.read_text(encoding="utf-8-sig", errors="replace")
    pattern = re.compile(
        r'"(?P<key>(?:\\.|[^"\\])*)"\s*=\s*"(?P<value>(?:\\.|[^"\\])*)"\s*;',
        re.MULTILINE,
    )
    entries: dict[str, Entry] = {}
    for match in pattern.finditer(text):
        key = decode_quoted(match.group("key"))
        value = decode_quoted(match.group("value"))
        entries[key] = Entry(str(path), key, value)
    return entries


def parse_stringsdict_file(path: Path) -> dict[str, Entry]:
    try:
        data = plistlib.loads(path.read_bytes())
    except Exception as error:  # Keep script dependency-free and report parse failures.
        return {
            "__parse_error__": Entry(
                str(path),
                "__parse_error__",
                f"Could not parse stringsdict: {error}",
            )
        }

    entries: dict[str, Entry] = {}
    if isinstance(data, dict):
        for key, value in data.items():
            entries[str(key)] = Entry(str(path), str(key), json.dumps(value, sort_keys=True))
    return entries


def parse_xcstrings_file(path: Path, locale: str) -> dict[str, Entry]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        return {
            "__parse_error__": Entry(
                str(path),
                "__parse_error__",
                f"Could not parse xcstrings: {error}",
            )
        }

    strings = data.get("strings", {})
    entries: dict[str, Entry] = {}
    if not isinstance(strings, dict):
        return entries

    for key, payload in strings.items():
        if not isinstance(payload, dict):
            continue
        localizations = payload.get("localizations", {})
        if not isinstance(localizations, dict) or locale not in localizations:
            continue
        localized = localizations.get(locale, {})
        value = ""
        if isinstance(localized, dict):
            unit = localized.get("stringUnit", {})
            if isinstance(unit, dict):
                value = str(unit.get("value", ""))
        entries[str(key)] = Entry(f"{path}#{locale}", str(key), value)
    return entries


def collect_lproj_resources(root: Path, locale: str) -> dict[str, dict[str, Entry]]:
    resources: dict[str, dict[str, Entry]] = {}
    for lproj in root.rglob(f"{locale}.lproj"):
        if not lproj.is_dir() or ".git" in lproj.parts:
            continue
        parent = lproj.parent
        relative_parent = parent.relative_to(root)
        for path in lproj.iterdir():
            if str(relative_parent) == ".":
                resource_name = path.name
            else:
                resource_name = str(relative_parent / path.name)
            if path.suffix == ".strings":
                resources[resource_name] = parse_strings_file(path)
            elif path.suffix == ".stringsdict":
                resources[resource_name] = parse_stringsdict_file(path)
    return resources


def collect_xcstrings_resources(root: Path, locale: str) -> dict[str, dict[str, Entry]]:
    resources: dict[str, dict[str, Entry]] = {}
    for path in root.rglob("*.xcstrings"):
        if ".git" in path.parts:
            continue
        resources[str(path.relative_to(root))] = parse_xcstrings_file(path, locale)
    return resources


def placeholders(value: str) -> list[str]:
    return sorted(PLACEHOLDER_RE.findall(value))


def starts_with_placeholder(value: str) -> bool:
    stripped = value.strip()
    return bool(stripped and PLACEHOLDER_RE.match(stripped))


def comparable_value(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip()).casefold()


def compare_entries(
    source: str,
    base_entries: dict[str, Entry],
    target_entries: dict[str, Entry],
    base_locale: str,
    target_locale: str,
) -> list[Finding]:
    findings: list[Finding] = []

    for key in sorted(set(base_entries) - set(target_entries)):
        findings.append(Finding("error", source, key, f"Missing {target_locale} key"))

    for key in sorted(set(target_entries) - set(base_entries)):
        findings.append(Finding("warning", source, key, f"Extra {target_locale} key"))

    for key in sorted(set(base_entries) & set(target_entries)):
        base_value = base_entries[key].value
        target_value = target_entries[key].value

        if key == "__parse_error__":
            findings.append(Finding("error", source, key, target_value or base_value))
            continue

        if not target_value.strip():
            findings.append(Finding("error", source, key, f"Empty {target_locale} value"))

        if target_value.strip() and comparable_value(base_value) == comparable_value(target_value):
            findings.append(
                Finding("warning", source, key, f"{target_locale} value matches {base_locale}")
            )

        base_placeholders = placeholders(base_value)
        target_placeholders = placeholders(target_value)
        if base_placeholders != target_placeholders:
            findings.append(
                Finding(
                    "error",
                    source,
                    key,
                    f"Placeholder mismatch: {base_placeholders} vs {target_placeholders}",
                )
            )

        if target_value.strip() and LATIN_RE.search(target_value) and not ARABIC_RE.search(target_value):
            findings.append(
                Finding("warning", source, key, f"{target_locale} value appears to be English")
            )

        if ARABIC_RE.search(base_value):
            findings.append(
                Finding("warning", source, key, f"{base_locale} value contains Arabic text")
            )

        if ARABIC_RE.search(target_value) and starts_with_placeholder(target_value):
            findings.append(
                Finding(
                    "warning",
                    source,
                    key,
                    "Arabic value starts with a placeholder; review bidi isolation marks",
                )
            )

    return findings


def compare_resources(
    base_resources: dict[str, dict[str, Entry]],
    target_resources: dict[str, dict[str, Entry]],
    base_locale: str,
    target_locale: str,
) -> list[Finding]:
    findings: list[Finding] = []
    for source in sorted(set(base_resources) - set(target_resources)):
        findings.append(Finding("error", source, "*", f"Missing {target_locale} resource file"))

    for source in sorted(set(base_resources) & set(target_resources)):
        findings.extend(
            compare_entries(
                source,
                base_resources[source],
                target_resources[source],
                base_locale,
                target_locale,
            )
        )

    return findings


def print_findings(findings: Iterable[Finding]) -> int:
    count = 0
    for finding in findings:
        count += 1
        print(f"[{finding.severity}] {finding.source} :: {finding.key}")
        print(f"  {finding.message}")
    return count


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check Arabic/English .strings, .stringsdict, and .xcstrings parity."
    )
    parser.add_argument("repo", nargs="?", default=".", help="Path to the Xcode project repo")
    parser.add_argument("--base", default="en", help="Base locale, usually en")
    parser.add_argument("--target", default="ar", help="Target locale, usually ar")
    args = parser.parse_args()

    root = Path(args.repo).resolve()
    if not root.exists():
        print(f"error: path does not exist: {root}", file=sys.stderr)
        return 2

    base_resources = collect_lproj_resources(root, args.base)
    target_resources = collect_lproj_resources(root, args.target)
    base_resources.update(collect_xcstrings_resources(root, args.base))
    target_resources.update(collect_xcstrings_resources(root, args.target))

    findings = compare_resources(base_resources, target_resources, args.base, args.target)

    print(f"=== Localization Parity: {root} ({args.base} -> {args.target}) ===")
    print(f"Resources checked: {len(base_resources)} base, {len(target_resources)} target")
    print("")

    if not base_resources and not target_resources:
        print("No localization resources found.")
        return 0

    if not findings:
        print("No parity issues found.")
        return 0

    issue_count = print_findings(findings)
    print("")
    print(f"=== {issue_count} issue(s) found ===")
    return 1 if any(finding.severity == "error" for finding in findings) else 0


if __name__ == "__main__":
    raise SystemExit(main())
