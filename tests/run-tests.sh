#!/usr/bin/env bash
# Snapshot test driver for tmux-session-glyphs.
# Iterates tests/fixtures/<case>/ directories, runs bin/tmux-session-glyphs
# in a hermetic env (isolated HOME, controlled PATH, mock tmux), and
# byte-compares stdout against each case's `expected` file.

set -u

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$repo_root/tests"
fixtures_dir="$test_dir/fixtures"
mock_bin="$test_dir/mock-bin"
script="$repo_root/bin/tmux-session-glyphs"

[[ -d "$fixtures_dir" ]] || { echo "no fixtures at $fixtures_dir"; exit 1; }
[[ -x "$script"        ]] || { echo "renderer not executable: $script"; exit 1; }
[[ -x "$mock_bin/tmux" ]] || { echo "mock tmux not executable: $mock_bin/tmux"; exit 1; }

# Ensure mock-bin contains a bash symlink so `#!/usr/bin/env bash` resolves
# even when no-jq strips the directory that holds the modern bash.
if [[ ! -e "$mock_bin/bash" ]]; then
  ln -s "$(command -v bash)" "$mock_bin/bash" 2>/dev/null || \
    ln -s "$BASH" "$mock_bin/bash"
fi

pass=0
fail=0
failures=()

# Iterate in name order for deterministic output.
for case_dir in $(printf '%s\n' "$fixtures_dir"/*/ | sort); do
  case_name="$(basename "$case_dir")"

  # Hermetic HOME so any local ~/.config/tmux-session-glyphs.conf can't leak in.
  tmp_home="$(mktemp -d)"

  # PATH: mock-bin always wins for tmux. Include system dirs (and homebrew
  # locations so `#!/usr/bin/env bash` resolves to bash 4+ on macOS).
  base_path="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
  # The no-jq sentinel installs a failing jq stub at the FRONT of PATH so
  # `command -v jq` succeeds but every jq invocation exits non-zero with
  # no output — observably equivalent to jq being absent. (Stripping jq's
  # dir from PATH would also remove dirname/grep/env on systems where
  # they're co-located.)
  jq_stub_dir=""
  if [[ -f "$case_dir/no-jq" ]]; then
    jq_stub_dir="$(mktemp -d)"
    printf '%s\n%s\n' '#!/bin/sh' 'exit 1' > "$jq_stub_dir/jq"
    chmod +x "$jq_stub_dir/jq"
    test_path="$jq_stub_dir:$mock_bin:$base_path"
  else
    test_path="$mock_bin:$base_path"
  fi

  # Run the renderer in a subshell to isolate env vars.
  actual="$(
    set +u
    export HOME="$tmp_home"
    export PATH="$test_path"
    export MOCK_TMUX_FIXTURE_DIR="$case_dir"
    set -a
    # shellcheck disable=SC1090,SC1091
    [[ -f "$case_dir/env" ]] && . "$case_dir/env"
    set +a
    "$script"
  )"

  expected=""
  [[ -f "$case_dir/expected" ]] && expected="$(cat "$case_dir/expected")"

  rm -rf "$tmp_home"
  [[ -n "$jq_stub_dir" ]] && rm -rf "$jq_stub_dir"

  if [[ "$actual" == "$expected" ]]; then
    pass=$((pass + 1))
    printf '  \033[32m✓\033[0m %s\n' "$case_name"
  else
    fail=$((fail + 1))
    failures+=("$case_name")
    printf '  \033[31m✗\033[0m %s\n' "$case_name"
    printf '    expected: %s\n' "$expected" | sed 's/$/\\n/' | head -c 400
    printf '\n    actual:   %s\n' "$actual"   | sed 's/$/\\n/' | head -c 400
    printf '\n'
  fi
done

total=$((pass + fail))
printf '\n%d/%d passed' "$pass" "$total"
if (( fail > 0 )); then
  printf ', %d failed: %s\n' "$fail" "${failures[*]}"
  exit 1
fi
printf '\n'
exit 0
