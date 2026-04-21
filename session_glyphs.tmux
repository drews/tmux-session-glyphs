#!/usr/bin/env bash
# tmux-session-glyphs — TPM entry point.
#
# Exposes the @tsg_script option with the absolute path to the renderer
# binary so users can reference it in their status-format without hard-coding
# the plugin path:
#
#   set -g status-right '#(#{@tsg_script})'
#
# All runtime configuration is read directly by bin/tmux-session-glyphs
# from tmux @tsg_* options (see README).

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux set-option -g @tsg_script "$CURRENT_DIR/bin/tmux-session-glyphs"
