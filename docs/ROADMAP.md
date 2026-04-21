# Roadmap

## v1 (bootstrap + plugin distribution)
Functional, drop-in replacement for the live `~/.tmux/bin/session-glyphs`, packaged as a TPM plugin. Merges per-session identity (emoji + ROYGBV color from `session-emoji.json`) with state-driven glyph/color modulation on a priority order.

- [x] `bin/tmux-session-glyphs` — single-script renderer, bash.
- [x] State detection: `bell`, `activity`, `attached` via tmux format flags.
- [x] Priority merge: bell > activity > identity (current bright / others dim).
- [x] Identity input: read `~/.local/share/tmux/resurrect/session-emoji.json` if present; fall back to default base glyph otherwise.
- [x] ROYGBV session sort order (ported from live script).
- [x] Mouse-click markup: wrap each glyph in `#[range=user|<sess>]...#[norange]` — preserves `.tmux.conf` click contract.
- [x] ASCII fallback theme (`TSG_THEME=ascii`).
- [x] Config precedence: env > tmux `@tsg_*` options > `~/.config/tmux-session-glyphs.conf` > `config/glyphs.conf` defaults.
- [x] TPM plugin layout (`session_glyphs.tmux` entry, `@tsg_script` path variable).
- [x] README with TPM install + `@tsg_*` configuration docs.

## v1.1
- [ ] Extra states: `long_job` (pane runtime threshold), `zoomed`, `copy_mode`.
- [ ] Optional 1–2s cache for long-job checks.
- [ ] JSON parse optimization (single read, bash assoc array) to cut jq subprocess overhead.
- [ ] `shellcheck` pass + simple CI.
- [ ] Snapshot tests with mocked tmux output.
- [ ] Demo script showing all themes.

## v1.2
- [ ] Additional built-in themes and color palettes.
- [ ] Performance profiling notes and tunables.
- [ ] Auto-detect Nerd Font availability; fall back to ASCII when absent.
