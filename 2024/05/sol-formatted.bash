f="$1"
grep , "$f" |
  (
  while read I; do
    read n < <(grep -o , <<<"$I"|wc -l)
    read J < <(
      grep -E "^(($(tr ',' '|' <<<"$I"))(\\||$))+$" "$f"|
      grep -o '[0-9]*$'|
      sort -r|
      uniq -c|
      sed 's/^ *//'|
      sort -n|
      tr '\n' _)
    read m < <(
      tr _ '\n' <<<"$J"|
      grep ^$((n/2))|
      cut -d' ' -f2)
    if grep -q "$(
      sed 's/[^_ ]* //g;s/_$//' <<<"$J"|
      tr _ ,)" <<< "$I"
    then
      t1=$((t1+m))
    else
      t2=$((t2+m))
    fi
  done
  echo "$t1 $t2"
)
