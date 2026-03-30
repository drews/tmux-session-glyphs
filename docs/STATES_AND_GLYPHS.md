# States and Glyphs

This document outlines the planned state model and default glyph/color mapping. ASCII fallbacks should be available if Nerd Fonts are not present.

## States (per session)
- attached: one or more clients attached to the session
- activity: any window has recent activity flag
- bell: any window has bell flag
- long_job: any pane has a command running longer than a threshold
- zoomed (optional): any window has a zoomed pane
- copy_mode (optional): any pane in copy-mode
- unseen (optional): windows not yet visited

## Default Nerd Font Glyphs (proposed)
- base: `` U+F111 nf-fa-circle (filled) or `` U+F192 nf-fa-dot_circle_o (hollow) variants to show prominence
- activity: `` U+F0E7 nf-fa-bolt or `` U+F46A nf-fa-zap
- bell: `` U+F0F3 nf-fa-bell
- long_job: `` U+F144 nf-fa-play_circle or `` U+F252 nf-fa-hourglass_half
- zoomed: `` U+F065 nf-fa-expand
- copy_mode: `` U+F0C5 nf-fa-copy

Exact combinations will be reduced to a single visible glyph per session using a priority order.

## ASCII Fallbacks (proposed)
- base: `*` attached, `o` unattached
- activity: `!`
- bell: `b`
- long_job: `+`
- zoomed: `Z`
- copy_mode: `C`

## Colors (example palette)
- attached/current: bright fg (e.g., `fg=white`)
- activity: accent color (e.g., `yellow`)
- bell: alert color (e.g., `red`)
- long_job: calm accent (e.g., `cyan`)
- dim/unattached: muted (e.g., `grey`)

## Priority Order (highest → lowest)
1) bell
2) activity
3) long_job
4) attached
5) zoomed
6) copy_mode

This ensures alerts surface first, while attached sessions remain visible.
