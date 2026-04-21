# tmux-session-glyphs

A lightweight tmux plugin that renders per-session glyphs in your status line, inspired by `jtmcginty/tmux-session-dots` and tailored to integrate with `drews/dotfiles` tmux session management.

## What it does

Renders a row of per-session glyphs with a priority-based merge of **identity** and **state**:

1. **bell** — any window in the session has a bell → bell glyph, alert color
2. **activity** (background sessions only) → bolt glyph, accent color
3. **identity** — emoji + ROYGBV color from `~/.local/share/tmux/resurrect/session-emoji.json` (maintained by `session-emoji` in `drews/dotfiles`). Current session renders bright+bold; others dimmed. Missing emoji file → default base glyph.

Each glyph is wrapped in `#[range=user|<sess>]...#[norange]` so tmux mouse handlers can resolve `#{mouse_status_range}` to a session name for click-to-switch.

## Requirements

- `tmux` 3.0+ (required)
- `jq` (soft dep — only for reading the identity file; script degrades gracefully if missing)
- [TPM](https://github.com/tmux-plugins/tpm) (for plugin-based install)

## Install (TPM)

Add to `.tmux.conf`:

```tmux
set -g @plugin 'drews/tmux-session-glyphs'
```

Reload tmux config and install with `prefix + I`. The plugin sets `@tsg_script` to the absolute path of the renderer.

### Wire into the status line

```tmux
set -g status-interval 2
set -g status-right '#(#{@tsg_script})'
```

Or reference it directly in a more elaborate `status-format[0]`.

## Configuration

All options are tmux variables; set them in `.tmux.conf` before `run '~/.tmux/plugins/tpm/tpm'`.

Precedence (high → low): environment `TSG_*` → tmux `@tsg_*` options → `~/.config/tmux-session-glyphs.conf` → repo defaults.

| Option | Env var | Default | Meaning |
|---|---|---|---|
| `@tsg_theme` | `TSG_THEME` | `nerd` | `nerd` or `ascii` |
| `@tsg_emoji_file` | `TSG_EMOJI_FILE` | `~/.local/share/tmux/resurrect/session-emoji.json` | identity source (JSON) |
| `@tsg_dim_color` | `TSG_DIM_COLOR` | `#585b70` | inactive/unattached color |
| `@tsg_current_fallback_color` | `TSG_CURRENT_FALLBACK_COLOR` | `#cdd6f4` | current session when no identity color is available |
| `@tsg_bell_color` | `TSG_BELL_COLOR` | `#f38ba8` | bell alert color |
| `@tsg_activity_color` | `TSG_ACTIVITY_COLOR` | `#f9e2af` | activity accent color |
| `@tsg_default_glyph` | `TSG_DEFAULT_GLYPH` | `●` | fallback glyph when no identity |

See `config/glyphs.conf` for the full list including state glyph codepoints.

### Example

```tmux
set -g @plugin 'drews/tmux-session-glyphs'
set -g @tsg_theme 'nerd'
set -g @tsg_bell_color '#ff4444'
set -g status-right '#(#{@tsg_script}) %H:%M'
```

## Manual install (without TPM)

```sh
git clone https://github.com/drews/tmux-session-glyphs ~/.tmux/plugins/tmux-session-glyphs
# In .tmux.conf:
set -g status-right '#(~/.tmux/plugins/tmux-session-glyphs/bin/tmux-session-glyphs)'
```

## Migrating from `drews/dotfiles`'s bundled `session-glyphs`

The dotfiles shipped a predecessor at `~/.tmux/bin/session-glyphs`. Output contract (mouse ranges, ROYGBV sort) is preserved, so migration is a path change:

```tmux
# Before
set -g status-format[0] '... #(~/.tmux/bin/session-glyphs) ...'

# After
set -g status-format[0] '... #(#{@tsg_script}) ...'
```

Rollback: point `status-format` back at `~/.tmux/bin/session-glyphs` and reload tmux.

## Status

**v1 bootstrap** — see `docs/ROADMAP.md`. Bell, activity, and identity states land here; `long_job`, `zoomed`, `copy_mode`, tests, and shellcheck CI ship in v1.1.

## Docs

- `docs/PLAN.md` — architecture and goals
- `docs/ROADMAP.md` — release phases
- `docs/STATES_AND_GLYPHS.md` — state model and glyph mappings
- `docs/INTEGRATION.md` — tmux wiring examples

## License

TBD.
