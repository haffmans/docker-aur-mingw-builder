#!/bin/bash

# Early install package list (to fix cyclic dependencies) and some real basic common packages
# Prefix with '*' to force install (ignore conflicts; Pacman --force option),
#             '^' to ignore dependencies (Pacman --nodeps option) and
#             '!' to uninstall the package
preinstall=(
    mingw-w64-configure
    mingw-w64-bzip2
    mingw-w64-zlib

    mingw-w64-freetype2-bootstrap
    mingw-w64-cairo-bootstrap
    mingw-w64-glib2
    mingw-w64-harfbuzz
    *mingw-w64-freetype2
    *mingw-w64-cairo
    *mingw-w64-glib2
    *mingw-w64-harfbuzz

    mingw-w64-x264-bootstrap
    mingw-w64-ffmpeg
    mingw-w64-x264
)

exclude=(
    -git$
    -git-vslib$
    -svn$
    -samples$

    ^mingw-w64-python-bin$
    ^mingw-w64-python2-bin$
    ^mingw-w64-python26-bin$
    ^mingw-w64-python33-bin$
    ^mingw-w64-python34-bin$
    ^mingw-w64-python35-bin$
)

function sanitize_name() {
    echo $1 | sed 's/\(!\|^[*\^]\{1,2\}\)//'
}

# First inject early install packages (and exclude them further on)
truncate -s 0 packages.txt
for package in ${preinstall[@]}; do
    echo $package >> packages.txt
    excludepackage=$(sanitize_name ${package})
    exclude=( ${exclude[@]} "^${excludepackage}$" )
done

# Get list of mingw-w64 packages and write them in packages.txt
yaourt -Ssqm mingw-w64 | while read package; do
    excl=0
    for pattern in ${exclude[@]}; do
        if [[ ${package} =~ ${pattern} ]]; then
            excl=1
        fi
    done

    if [[ $excl -gt 0 ]]; then
        continue;
    fi

    echo $package >> packages.txt
done
