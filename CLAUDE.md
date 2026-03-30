# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**tmux-session-glyphs** is a lightweight, shell-first utility that renders per-session glyphs in tmux status lines. It integrates with `drews/dotfiles` tmux session management as a read-only display component — it never creates or kills sessions.

- **Language**: POSIX shell (no external dependencies beyond tmux CLI)
- **Entry point**: `bin/tmux-session-glyphs` (not yet implemented)
- **Performance target**: <10ms typical render, single-shot execution per status refresh

## Architecture

### State Model (priority order)
bell → activity → long_job → attached → zoomed → copy_mode

Each session is mapped to exactly one glyph based on highest-priority active state. State is read from `tmux list-sessions`, `list-windows`, `list-panes`.

### Configuration Precedence
1. Environment variables (`TSG_*`)
2. `~/.config/tmux-session-glyphs.conf`
3. `config/glyphs.conf` (repo defaults)

Key env vars: `TSG_THEME`, `TSG_LONGJOB_SECS`, `TSG_ONLY_ATTACHED`, `TSG_HIDE_EMPTY`

### Theming
- Default: Nerd Font glyphs (nf-fa-circle, nf-fa-bolt, nf-fa-bell, nf-fa-hourglass_half, nf-fa-expand, nf-fa-copy)
- ASCII fallback: `*`, `o`, `!`, `b`, `+`, `Z`, `C`
- Auto-detect Nerd Fonts; fall back to ASCII if unavailable

## Build & Test

No build system yet. Planned:
- `shellcheck` for linting
- Snapshot tests with mocked tmux output
- Demo script for visual verification across themes

## Key Documentation

- `docs/PLAN.md` — detailed architecture and implementation plan
- `docs/ROADMAP.md` — release phases v0 through v1.2
- `docs/STATES_AND_GLYPHS.md` — state model, glyph mappings, color palette
- `docs/INTEGRATION.md` — tmux status-line integration examples

## Roadmap Phases

- **v0 (MVP)**: Script skeleton, default theme, ASCII fallback
- **v1**: Real state detection, config precedence, cache, snapshot tests
- **v1.1**: Extra states (zoomed, copy_mode), shellcheck/CI
- **v1.2**: TPM plugin layout, additional themes, performance profiling
