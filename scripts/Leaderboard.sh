#!/bin/bash

printf "┌───────┬────────────┬──────────┐\n"
printf "│ ${CYAN}%5s${WHITE} │ ${GREEN}%10s${WHITE} │ ${RED}%8s${WHITE} │ \n" "Rank" "Solver" "Solves"
printf "├───────┼────────────┼──────────┤\n"
\ls -R "$UVA_HOME" | \grep -Eo "/[a-z]{2}[0-9]{1,5}:" | cut -c 2- | sort | uniq -c | sort -nr | nl | while read line; do
    rank=$(echo $line | cut -f1 -d\ )
    solves=$(echo $line | cut -f2 -d\ )
    name=$(echo $line | cut -f3 -d\  | sed "s/:/ /" | sed "s/$KUERZEL/-> &/")
    printf "│ ${CYAN}%5d${WHITE} │ ${GREEN}%10s${WHITE} │ ${RED}%8d${WHITE} │ \n" "$rank" "$name" "$solves"
done
printf "└───────┴────────────┴──────────┘\n"
