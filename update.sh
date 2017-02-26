#!/bin/sh

function sanitize_name() {
    echo $1 | sed 's/\(!\|^[*\^]\{1,2\}\)//'
}

# Import keys
awk '{ print $1; }' pubkeys.txt | while read key; do
    sudo pacman-key -r $key
    gpg --keyserver keys.gnupg.net --recv $key
done

# Install packages
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
        environment="OVERRIDE_NOCONFIRM=0 OVERRIDE_PU_NOCONFIRM=0"
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

echo "Updating repository database..."
cd /build/repo

if [ -n "${GPGKEY}" ]; then
    repoadd_args="-s -k \"${GPGKEY}\""
fi
repo-add ${repoadd_args} --new mingw-w64.db.tar.gz *.pkg.*
