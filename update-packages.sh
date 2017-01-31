#!/bin/sh

echo mingw-w64-freetype2-bootstrap > packages.txt
yaourt -Ssqm mingw-w64 >> packages.txt
