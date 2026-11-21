# Shell aliases shared across machines. Sourced from ~/.bashrc by install.sh.
# shellcheck shell=bash
alias n='nvim'
alias lg='lazygit'
cricri-auto() {
  claude --dangerously-skip-permissions "/cricri --auto $*"
}
