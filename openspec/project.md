# Project: tmux-session-glyphs

## North Star

A glance at the status bar should tell me **which sessions need my attention** and **which can wait**. Color carries identity (which session); shape carries state (what's happening); brightness carries hierarchy (here vs over there).

## Design pillars

1. **Calm by default.** State glyphs only surface when attention is warranted — bell rings, activity in a background session, an in-progress mode. Steady state shows identity, nothing else.
2. **Identity is sacred.** Per-session color (ROYGBV) and emoji come from the user's `session-emoji.json` and are never overridden by state glyphs except briefly and for cause.
3. **Mouse contract is non-negotiable.** Every glyph wraps in `#[range=user|<sess>]...#[norange]` so click-to-switch works regardless of the host `.tmux.conf` layout.
4. **Zero-config works.** Defaults render correctly for the `drews/dotfiles` target out of the box. Configuration is opt-in via `@tsg_*` tmux options, environment variables, or a user config file.
5. **Performance is invisible.** Render budget is <50ms wall-clock. The script exits 0 unconditionally — a status-line component must never fail user-visibly.

## Anti-goals

- We do **not** create, rename, or kill sessions. Read-only display only.
- We do **not** duplicate session management from `drews/dotfiles`; we read its state.
- We do **not** require daemons, long-running processes, or background caches beyond a short-lived in-script cache.
- We do **not** introduce hard dependencies beyond `tmux`. `jq` is an optional accelerator.

## Priority order (intent)

Per session, exactly one glyph renders. Higher rows pre-empt lower:

| Tier      | Reason it pre-empts                                 |
|-----------|-----------------------------------------------------|
| bell      | the loudest alert; surface even on the current session |
| activity  | background change worth noticing; suppress on the current session (you can already see it) |
| long_job  | something has been running a while (planned)         |
| zoomed    | structural state; surfaces on any session            |
| copy_mode | structural state; surfaces on any session            |
| identity  | the resting state — emoji + ROYGBV color             |

The full behavioral contract (which tmux flags map to which tier, how the output is shaped) lives in `openspec/specs/glyph-rendering.md`.

## Architecture (high level)

- **Entry point**: `bin/tmux-session-glyphs` (single bash script).
- **TPM plugin shim**: `session_glyphs.tmux` exposes `@tsg_script` so users can wire `#(#{@tsg_script})` without hard-coding paths.
- **Inputs**: `tmux list-sessions`, `tmux list-windows -a`, `tmux list-panes -a`, and optionally `~/.local/share/tmux/resurrect/session-emoji.json` (parsed in one pass when `jq` is present).
- **Config precedence (high → low)**: env `TSG_*` → tmux `@tsg_*` options → `~/.config/tmux-session-glyphs.conf` → `config/glyphs.conf` defaults.
- **Output**: a single line of tmux format markup, one glyph per session in ROYGBV order, each click-routable.

## Integration with `drews/dotfiles`

This plugin is read-only against state produced by the dotfiles' session management (`session-emoji`, session resurrect). It is not a replacement for those tools — it is the display layer on top of them.

## What changes how

- **Vision shifts** → this file. Changes here are rare and deliberate.
- **Behavior shifts** → a proposal under `openspec/changes/`, ultimately landing in `openspec/specs/`.
- **Phase / release planning** → `docs/ROADMAP.md`.
- **User-facing usage** → `README.md`.
