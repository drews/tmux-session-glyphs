# CLAUDE.md

Project context for AI assistants. Vision and behavior live elsewhere; this file is conventions + pointers.

## Pointers

- **Vision, pillars, anti-goals** → `openspec/project.md`
- **Behavior contract** → `openspec/specs/glyph-rendering.md`
- **Stack, rules, perf budget** → `openspec/config.yaml`
- **Release phases** → `docs/ROADMAP.md`
- **User-facing usage** → `README.md`

## Conventions

- Language: **bash** (not strict POSIX — uses arrays and `printf -v`).
- Hard deps: `tmux` only. `jq` is an optional accelerator.
- `shellcheck --severity=warning` must pass on `bin/*` and `*.tmux`.
- The script must always exit 0; a failing status-line component is a UX bug.
- The output contract `#[range=user|<sess>]...#[norange]` is non-negotiable — every glyph wraps in it.
- No comments unless the *why* is non-obvious. Don't narrate *what*.
- Defaults flow through `:=` in `config/glyphs.conf`; never use plain `=` there.

## Quick commands

```bash
./bin/tmux-session-glyphs                                 # render once
TSG_THEME=ascii ./bin/tmux-session-glyphs                 # force ASCII theme
shellcheck --severity=warning bin/tmux-session-glyphs session_glyphs.tmux
time ./bin/tmux-session-glyphs >/dev/null                 # perf check (<50ms target)
```

## When in doubt

If a proposed change conflicts with the design pillars in `openspec/project.md`, push back. The pillars are the project's preferred direction — restate them and ask before working around them.
