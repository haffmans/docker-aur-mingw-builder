#!/bin/sh

while read pkg; do
    yaourt -S --needed --aur $pkg
done < packages.txt

cd /build/repo
repo-add --new mingw-w64 *.pkg.*
