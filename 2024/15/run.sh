gprolog --consult-file "$1" --query-goal 'main' < "$2" | tail -n +5 
