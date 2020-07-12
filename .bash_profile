#!/bin/bash

for file in ~/.{bashrc,exports}; do
    if [[ -r "$file" ]] && [[ -f "$file" ]]; then
	source "$file"
    fi
done
unset file
