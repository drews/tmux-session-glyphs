# Integration with drews/dotfiles

This project is designed to plug into your existing tmux setup without altering session management.

## Expected Wiring
- Status: add to `status-right` or `status-left` in `.tmux.conf`.
- Refresh: rely on your existing `status-interval` (recommended 2s).
- Theme/thresholds: pass via env or tmux options.

## Example Snippet
```
# recommended status refresh
set -g status-interval 2

# example: pass long job threshold via an option
set -g @tsg_longjob_secs 60

# wire the script (assuming in PATH)
set -g status-right '#(TSG_LONGJOB_SECS=#{@tsg_longjob_secs} tmux-session-glyphs) %a %H:%M'
```

## Variables
- TSG_THEME: theme name (e.g., `nerd`, `ascii`).
- TSG_LONGJOB_SECS: seconds threshold for long-running job state.
- TSG_ONLY_ATTACHED: only show sessions attached to any client.
- TSG_HIDE_EMPTY: hide sessions with 0 windows (if possible by your utilities).

## Palette Hooks
If your dotfiles expose palette options (e.g., `@palette_fg`, `@palette_alert`), the script can prefer those when present. Fallback to internal defaults otherwise.

## Notes
- This component does not create/rename/kill sessions; it reads state only.
- If Nerd Fonts are unavailable, the script should detect and fall back to ASCII.
- For debugging, run the script in a shell outside tmux to inspect raw output.
