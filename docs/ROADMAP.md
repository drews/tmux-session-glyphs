# Roadmap

Phase tracking for `tmux-session-glyphs`. Vision and behavior contract are tracked separately — see [`openspec/project.md`](../openspec/project.md) and [`openspec/specs/glyph-rendering.md`](../openspec/specs/glyph-rendering.md). Behavioral changes go through OpenSpec proposals (`openspec/changes/`); checkbox progress on planned phases lives here.

## v1 — bootstrap + plugin distribution

Functional, drop-in replacement for the live `~/.tmux/bin/session-glyphs`, packaged as a TPM plugin.

- [x] `bin/tmux-session-glyphs` — single-script renderer (bash)
- [x] State detection: `bell`, `activity` via tmux format flags
- [x] Identity input: optional `session-emoji.json` (graceful fallback)
- [x] ROYGBV session sort order
- [x] `#[range=user|<sess>]...#[norange]` mouse-click markup
- [x] ASCII fallback theme
- [x] Config precedence: env → `@tsg_*` → user file → repo defaults
- [x] TPM plugin layout (`session_glyphs.tmux`, `@tsg_script`)
- [x] README with TPM install + configuration docs

## v1.1

- [x] Extra states: `zoomed`, `copy_mode`
- [x] JSON parse optimization (single jq call → assoc arrays)
- [x] `shellcheck --severity=warning` clean
- [x] Docs restructure: vision in `openspec/project.md`, behavior in `openspec/specs/`
- [ ] `long_job` state (pane runtime threshold) + optional 1–2s cache
- [ ] CI: shellcheck on push
- [ ] Snapshot tests with mocked tmux output
- [ ] Demo script showing all themes

## v1.2

- [ ] Additional built-in themes and color palettes
- [ ] Performance profiling notes and tunables
- [ ] Auto-detect Nerd Font availability; fall back to ASCII when absent

## Backlog (open issues, phase TBD)

- [#1](https://github.com/drews/tmux-session-glyphs/issues/1) — opt-in window count suffix per glyph (`@tsg_show_window_count`).
- [#2](https://github.com/drews/tmux-session-glyphs/issues/2) — additional pane-level signals:
  - `dead pane` / non-zero exit status — proposed slot between `bell` and `activity`
  - `silence` (`#{window_silence_flag}`) — structural state, near `zoomed`/`copy_mode`
  - `linked` window (`#{window_linked}`) — niche, may stay deferred
  - (`zoomed` is already shipped in v1.1; `long_job` is already planned in v1.1)

Any change to the priority chain requires an OpenSpec proposal updating `openspec/specs/glyph-rendering.md`.
