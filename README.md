# tmux-session-glyphs

A lightweight utility to render per-session glyphs in your tmux status line, inspired by jtmcginty/tmux-session-dots, but tailored to integrate cleanly with drews/dotfiles tmux session management utilities and configurations.

## Goals
- Minimal, fast, shell-first implementation (no heavy deps)
- Friendly integration with existing tmux.conf and helpers from drews/dotfiles
- Customizable glyph sets, colors, and session states
- Works in status-left/right or window status formats

## High-Level Idea
- Enumerate tmux sessions and compute a compact state per session (e.g., attached, has activity, has bell, running long job, etc.)
- Map state to a configurable glyph/color theme
- Output a single line for use in tmux `status-right` (or `status-left`) and optionally per-window decorations

## Integration with drews/dotfiles
- Provide a small shim function/script that your dotfiles can source or call
- Respect your existing tmux options (e.g., prefix vars, color palette, refresh interval)
- Avoid duplicating session management; treat dotfiles utilities as the source of truth

## Next Steps
- Finalize requirements (glyphs, colors, states) based on your tmux usage
- Implement a portable script in `bin/` and add config in `config/`
- Wire into tmux status via your dotfiles
- Add a few snapshots and a quick test harness

## License
TBD (add when ready).
