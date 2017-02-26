#!/bin/sh

function sanitize_name() {
    echo $1 | sed 's/\(!\|^[*\^]\{1,2\}\)//'
}

while read pkg; do
    params=""
    doyes="0"
    environment=""
    # '!' means remove
    if [[ "$pkg" =~ ^\! ]]; then
        echo "Removing $(sanitize_name $pkg)!"
        params="-R"
    else
        echo "Installing $(sanitize_name $pkg)..."
        params="-S --needed --aur"
    fi

    # '*' means force install
    if [[ "$pkg" =~ ^\^?\* ]]; then
        echo "Forcing $(sanitize_name $pkg)!"
        # Also remove 'needed' option; add --confirm to make sure we can explicitly answer 'yes' to conflict resolutions
        params="${params//--needed/} --force --confirm"
        doyes="1"
        environment="NOCONFIRM=0 PU_NOCONFIRM=0"
    fi
    # '^' means --nodeps
    if [[ "$pkg" =~ ^\*?\^ ]]; then
        echo "Ignoring dependencies for $(sanitize_name $pkg)!"
        params="$params --nodeps"
    fi

    pkg=${pkg#[\\!\*]}
    if [[ "$doyes" == "1" ]]; then
        echo "Answering yes to all Pacman confirmations!"
        yes | env ${environment} yaourt $params $pkg
    else
        env ${environment} yaourt $params $pkg
    fi
done < packages.txt

cd /build/repo
repo-add --new mingw-w64 *.pkg.*
