#!/bin/bash

# Replaces spaces in the names of solution folders, the git mv's them
# Run in the solutions folder

for folder in ./*; do
    if [[ -d $folder ]]; then
        newFoldername=$(echo $folder | sed "s/ /_/g")
        if [[ $folder != $newFoldername ]]; then
            git mv "$folder" $newFoldername
        fi
    fi
done
