#!/bin/bash

# Listet alle Probleme auf inklusive die Person die diese als erster gelöst hat
# (noch nicht ganz fertig)
# Eventuell ist das Erstellungsdatum des Ordners kein gutes Kriterium

for problem in ./*; do
    if [[ -d ./$problem ]]; then
        firstSolve=$(ls -td ./$problem/*/ | tail -n 1 | grep -o "[a-z0-9]*/$")
        echo -n $(echo $problem | sed "s/ //" | sed "s/-/ /")
        echo " $firstSolve"
    fi
done

