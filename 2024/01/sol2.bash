grep -o ' *[0-9]*' | sort | uniq -c | sort -k2 | tr -s ' ' | uniq -f1 -D | grep -o '[0-9]*' | paste -sd'***\n' | cut -d'*' -f1-3 | paste -sd+ | bc
