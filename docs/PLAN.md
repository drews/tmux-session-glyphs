# Project Plan: tmux-session-glyphs

## Overview
Render compact, per-session glyphs for tmux status, inspired by tmux-session-dots, integrated with drews/dotfiles session utilities. Focus on speed, portability, and easy drop-in wiring to existing configs.

## Goals
- Minimal, POSIX-shell implementation using `tmux` CLI only.
- Integrate cleanly with drews/dotfiles (no duplication of session management).
- Theming for glyphs and colors; ASCII fallback if Nerd Fonts unavailable.
- Single-shot output suitable for `status-right`/`status-left`.

## Non-Goals
- Replacing existing session creation/management tools.
- Heavy dependencies or long-running daemons.

## Architecture
- Entry point: `bin/tmux-session-glyphs` (single script, bash).
- Config sources (precedence):
  1) Environment variables (e.g., `TSG_*`).
  2) User config `~/.config/tmux-session-glyphs.conf` (optional).
  3) Repo defaults `config/glyphs.conf` (optional).
- Data collection: `tmux list-sessions`, `list-windows`, `list-panes` with format fields to derive states.
- State model (per session): attached, activity, bell, long-job, zoomed/copy (optional), unseen windows (optional).
- Identity source (optional): `~/.local/share/tmux/resurrect/session-emoji.json` (maintained by `session-emoji` script) — provides per-session icon + ROYGBV color. Parsed via `jq` when present. Absent → all sessions render the default base glyph.
- Priority merge per session: state glyph (bell/activity/long_job) surfaces when active; otherwise the identity emoji renders (bright+bold for current session, dim for others). Priority order defined in `STATES_AND_GLYPHS.md`.
- Output: single line of per-session glyphs, each wrapped in `#[range=user|<sess>]...#[norange]` so tmux mouse handlers can resolve `#{mouse_status_range}` to a session name for click-to-switch.

## Integration with drews/dotfiles
- Read palette/timing options if exposed via tmux options (e.g., `@palette_*`, refresh interval).
- Support wrapper/shim in dotfiles to pass theme and thresholds via env.
- Avoid changing naming or lifecycle; treat dotfiles utilities as the source of truth.

## Performance
- Minimize `tmux` calls; prefer a single pass + parse.
- Optional tiny cache (1–2s) for expensive checks (long-job detection).
- Target <10ms typical render on modern machines.

## Testing
- Snapshot tests for parsing/mapping with mocked `tmux` outputs.
- Demo script to show sample output across themes.
- Optional shellcheck lint in CI.

## Deliverables (v0)
- Script skeleton that prints deterministic placeholder glyphs.
- Default theme + ASCII fallback.
- Basic integration snippet for tmux.
- README and docs updated with usage.
