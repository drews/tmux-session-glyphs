# tmux-session-glyphs

A tmux plugin that renders per-session glyphs in your status line. **A glance tells you which sessions need your attention and which can wait** — color is identity, shape is state, brightness is hierarchy.

Inspired by `jtmcginty/tmux-session-dots`; built to plug into `drews/dotfiles` tmux session management.

## What it does

Per session, one glyph renders, chosen by priority:

1. **bell** — any window has a bell → bell glyph, alert color
2. **activity** (background sessions only) — bolt glyph, accent color
3. **zoomed** — any window has a zoomed pane → expand glyph
4. **copy_mode** — any pane in a tmux mode → copy glyph
5. **identity** — emoji + ROYGBV color from `session-emoji.json`; current bright+bold, others dim

Each glyph wraps in `#[range=user|<sess>]...#[norange]` so tmux mouse handlers can resolve `#{mouse_status_range}` for click-to-switch.

Full behavior contract: [`openspec/specs/glyph-rendering.md`](openspec/specs/glyph-rendering.md). Why it's shaped this way: [`openspec/project.md`](openspec/project.md).

## Requirements

- `tmux` 3.0+
- `jq` (optional — identity file is parsed only when both `jq` and the file are present)
- [TPM](https://github.com/tmux-plugins/tpm) for plugin install

## Install (TPM)

```tmux
set -g @plugin 'drews/tmux-session-glyphs'
```

Reload tmux config and install with `prefix + I`. The plugin's `.tmux` entry sets `@tsg_script` to the absolute path of the renderer.

### Wire into the status line

```tmux
set -g status-interval 2
set -g status-right '#(#{@tsg_script})'
```

Or interpolate it inside a richer `status-format[0]`.

## Configuration

Precedence (high → low): environment `TSG_*` → tmux `@tsg_*` options → `~/.config/tmux-session-glyphs.conf` → repo defaults in `config/glyphs.conf`.

| Option | Env var | Default | Meaning |
|---|---|---|---|
| `@tsg_theme` | `TSG_THEME` | `nerd` | `nerd` or `ascii` |
| `@tsg_emoji_file` | `TSG_EMOJI_FILE` | `~/.local/share/tmux/resurrect/session-emoji.json` | identity source (JSON) |
| `@tsg_dim_color` | `TSG_DIM_COLOR` | `#585b70` | inactive/unattached color |
| `@tsg_current_fallback_color` | `TSG_CURRENT_FALLBACK_COLOR` | `#cdd6f4` | current session when no identity color available |
| `@tsg_bell_color` | `TSG_BELL_COLOR` | `#f38ba8` | bell alert |
| `@tsg_activity_color` | `TSG_ACTIVITY_COLOR` | `#f9e2af` | activity accent |
| `@tsg_zoomed_color` | `TSG_ZOOMED_COLOR` | `#89dceb` | zoomed pane |
| `@tsg_copy_color` | `TSG_COPY_COLOR` | `#cba6f7` | copy/view mode |
| `@tsg_default_glyph` | `TSG_DEFAULT_GLYPH` | `●` | fallback when no identity |

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
# .tmux.conf:
set -g status-right '#(~/.tmux/plugins/tmux-session-glyphs/bin/tmux-session-glyphs)'
```

## Debugging

Run the script outside tmux to inspect the raw tmux-format markup:

```sh
~/.tmux/plugins/tmux-session-glyphs/bin/tmux-session-glyphs | cat
```

The script always exits 0; if you see empty output, it means no tmux server was reachable or no sessions exist.

## Tests

```sh
./tests/run-tests.sh                       # snapshot tests (mock tmux on PATH)
shellcheck --severity=warning bin/* *.tmux tests/run-tests.sh tests/mock-bin/tmux
```

Add new behaviors? Add a fixture directory under `tests/fixtures/` with the appropriate inputs and an `expected` golden file. CI (`.github/workflows/ci.yml`) runs both on every push.

## Status

See [`docs/ROADMAP.md`](docs/ROADMAP.md) for current phase and what's next.

## License

TBD.
