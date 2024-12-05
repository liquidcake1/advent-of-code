join -j 3 <(grep '|' "$1") <(grep ',' "$1") |
    grep '^ \([0-9][0-9]\).\([0-9][0-9]\) .*\(\1.*\2\|\2.*\1\)' |
    sed 's/..|//' |
    sort -k2 -k1n |
    uniq -c |
    sort -k3 -k1n |
    tr , \  |
    awk '{ if ($2 == $($1+3)) print (NF-3) " " $((NF+3)/2) " " $_ }' |
    uniq -cf4  |
    grep '^ *\([^ ][^ ]*\) \1 ' | 
    tr -s ' ' |
    cut -d' ' -f4 |
    paste -sd+ |
    bc
