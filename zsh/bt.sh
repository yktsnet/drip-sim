# 人間の対話利用向け。.zshrc等でこのファイルをsourceすると `bt`/`bt-py` が使える。
# AI/スクリプトから非対話で叩く場合は `bin/bt <stage> [args]`（シェル非依存の実行可能スクリプト）を使う。
#
# 使い方:
#   echo 'source /path/to/drip-sim/zsh/bt.sh' >> ~/.zshrc

DRIP_SIM_DIR="${${(%):-%x}:A:h:h}"   # このファイル自身のパスから2階層上(repoルート)を求める

bt-py() {
  emulate -L zsh
  local py
  py=$("$DRIP_SIM_DIR/bin/bt-python") || return 1
  PYTHONPATH="$DRIP_SIM_DIR" "$py" "$@"
}

bt() {
  emulate -L zsh
  if (( $# == 0 )); then
    bt-py "$DRIP_SIM_DIR/bt.py" flow
  else
    bt-py "$DRIP_SIM_DIR/bt.py" "$@"
  fi
}

_bt() {
  local -a stages
  stages=(s1b s1c s2 s3 s4 s5 s6 s7 s8 monthly monthly-backfill all flow)
  _describe 'bt stage' stages
}

if (( $+functions[compdef] )); then
  compdef _bt bt
else
  autoload -Uz add-zsh-hook
  _bt_register_compdef() {
    add-zsh-hook -d precmd _bt_register_compdef
    (( $+functions[compdef] )) && compdef _bt bt
  }
  add-zsh-hook precmd _bt_register_compdef
fi
