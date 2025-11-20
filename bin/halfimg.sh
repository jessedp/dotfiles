#!/bin/bash

files=( "$@" )
for arg;do
	if [ -f "$arg" ]; then
		dirname=$(dirname -- "$arg")
		filename=$(basename -- "$arg")
		extension="${filename##*.}"
		filename="${filename%.*}"
		output_file="$dirname/$filename.half.$extension"

		echo creating "$output_file"
		convert -quality 50 -resize 50% "$arg" "$output_file"
	else
		echo "invalid file $arg"
	fi
done
