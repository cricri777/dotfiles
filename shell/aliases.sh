# Shell aliases shared across machines. Sourced from ~/.bashrc by install.sh.
# shellcheck shell=bash
alias n='nvim'
alias lg='lazygit'
cricri-auto() {
  mkdir -p ~/.cache/cricri
  claude -p "/cricri --auto $*" --dangerously-skip-permissions \
    2>&1 | tee ~/.cache/cricri/"$(basename "$PWD")-$(date +%Y%m%d-%H%M).log"
}
