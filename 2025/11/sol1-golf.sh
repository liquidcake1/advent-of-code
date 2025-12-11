bash <(yes "sed -E 's/(.*): ([^ ]*)/\1+\2\n\1:/'|"|head -n50;echo "sed -E '/:/d;s/((.*)\+(.*))/\2 \1\n\1 \3/'")|tsort|(echo you=1;sed 's/.*+\(.*\)/\1=&/';echo out)|bc
