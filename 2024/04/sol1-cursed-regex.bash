(read first; L="${#first}"; regex="$(for cat in cat tac; do i=0; read X M A S < <(echo XMAS | grep -o . | $cat | tr '\n' ' '); for x in 4 $((L*5-4)) $((L*5+1)) $((L*5+6)); do echo "(?<=:$X{$i})$X(?=.{$x}$M.{$x}$A.{$x}$S{$((4-i))}:)"; i=$((i+1)); done; done|paste -sd'|'|tee /dev/stderr)"; (echo "$first"; cat) | sed 's/\(.\)/:\1\1\1\1/g;s/$/:/' | xargs | grep -Po "$regex") | wc -l
