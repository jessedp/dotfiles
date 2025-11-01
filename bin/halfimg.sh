#!/bin/bash

files=( "$@" )
for arg;do
	if [ -f "$arg" ]; then
		filename=$(basename -- "$arg")
		extension="${filename##*.}"
		filename="${filename%.*}"

		echo creating "$filename.half.$extension"
		convert -quality 50 -resize 50% "$arg" "$filename.half.$extension"
	else
		echo "invalid file $arg"
	fi
done
