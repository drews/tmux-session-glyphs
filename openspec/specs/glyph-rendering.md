# Spec: per-session glyph rendering

Canonical behavior contract for `bin/tmux-session-glyphs`. Snapshot tests verify against this spec; vision/motivation lives in `openspec/project.md`.

## Inputs

| Source                          | Required | Used for                                     |
|---------------------------------|----------|----------------------------------------------|
| `tmux list-sessions`            | yes      | session enumeration, current/attached flag   |
| `tmux list-windows -a`          | yes      | bell, activity, zoomed flags (per session)   |
| `tmux list-panes -a`            | yes      | copy_mode (any pane in tmux mode)            |
| `tmux display -p '#S'`          | yes      | current session name                         |
| `$TSG_EMOJI_FILE` (JSON)        | no       | per-session icon + ROYGBV color              |
| `jq`                            | no       | required only when the emoji file is present |

## State detection

| State     | tmux source                                      | Scope                          |
|-----------|--------------------------------------------------|--------------------------------|
| bell      | `#{window_bell_flag} == 1` in any window         | all sessions                   |
| activity  | `#{window_activity_flag} == 1` in any window     | **background sessions only**   |
| zoomed    | `#{window_zoomed_flag} == 1` in any window       | all sessions                   |
| copy_mode | `#{pane_in_mode} == 1` in any pane               | all sessions                   |
| identity  | the default when no higher-priority state holds  | all sessions                   |

`long_job` is reserved and not yet implemented.

## Priority

Per session, exactly one tier wins. The script evaluates top-to-bottom and stops at the first match:

1. bell
2. activity (skipped for the current session)
3. zoomed
4. copy_mode
5. identity

## Output format

A single line written to stdout, no trailing newline. Each session contributes one fragment, joined by a single space; trailing space is trimmed.

Each fragment is exactly:

```
#[range=user|<session>]#[fg=<color>[,<style>]]<glyph>#[norange[,no<style>]]
```

Where `<style>` is `bold` when applied, omitted otherwise. The `#[range=user|...]` markup is **non-negotiable** — it is the click contract that lets host `.tmux.conf` route mouse events back to a session name via `#{mouse_status_range}`.

### Per-tier visual

| Tier      | Glyph (nerd)              | Glyph (ascii) | Color                          | Style                       |
|-----------|---------------------------|---------------|--------------------------------|-----------------------------|
| bell      | nf-fa-bell (U+F0F3)       | `b`           | `$TSG_BELL_COLOR`              | bold                        |
| activity  | nf-fa-bolt (U+F0E7)       | `!`           | `$TSG_ACTIVITY_COLOR`          | normal                      |
| zoomed    | nf-fa-expand (U+F065)     | `Z`           | `$TSG_ZOOMED_COLOR`            | bold on current; else normal |
| copy_mode | nf-fa-copy (U+F0C5)       | `C`           | `$TSG_COPY_COLOR`              | bold on current; else normal |
| identity  | from `$TSG_EMOJI_FILE` or `$TSG_DEFAULT_GLYPH` | `*` | from JSON or `$TSG_CURRENT_FALLBACK_COLOR` (current) / `$TSG_DIM_COLOR` (other) | bold on current; else normal |

Defaults for all glyph and color variables live in `config/glyphs.conf`.

### Sort order

Sessions are emitted in **ROYGBV order** by identity color (Catppuccin Mocha palette):

```
#f38ba8 red  →  #fab387 peach  →  #f9e2af yellow  →  #a6e3a1 green
       →  #89b4fa blue  →  #b4befe lavender  →  (any other / unassigned)
```

Sessions without a JSON entry sort into the final "unassigned" bucket. Order within a tier is the order returned by `tmux list-sessions` (typically insertion order).

## Configuration precedence

Resolved at startup, high → low:

1. Environment variables (`TSG_*`)
2. tmux options (`@tsg_*`) — read only when running inside tmux
3. `~/.config/tmux-session-glyphs.conf` (sourced shell, optional)
4. `config/glyphs.conf` (repo defaults; uses `:=` so it never overrides earlier layers)

Lower layers fill values left unset by higher layers; they do not override.

## Error semantics

The script must never produce a user-visible failure on the status line:

- **Exit code is always 0.** Failures inside tmux subprocesses are swallowed.
- **No tmux available** (e.g., run outside tmux): empty stdout, exit 0.
- **Missing emoji file**: identity falls back to `$TSG_DEFAULT_GLYPH`. Current session uses `$TSG_CURRENT_FALLBACK_COLOR`; others use `$TSG_DIM_COLOR`. Mouse-click contract still satisfied.
- **Missing `jq`**: behaves as if the emoji file is missing, regardless of whether the file exists.
- **Session in the emoji file but missing icon/color fields**: per-field fallback to defaults.

## Performance budget

- Target: **<50ms** wall-clock for a typical session count (≤10).
- Subprocess count per render: 4 tmux calls (`display`, `list-sessions`, `list-windows -a`, `list-panes -a`) + 1 `jq` call when applicable.
- Status-line refresh cadence is driven by `status-interval`; the script is single-shot, never long-lived.
