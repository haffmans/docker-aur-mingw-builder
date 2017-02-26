This Docker image can be used to easily build packages from the ArchLinux User Repository (AUR). By
default it is prepared to build mingw-w64 packages.

## Building Packages

To build the packages, start a terminal in the container and run update.sh.

    docker run --name aur-mingw-build haffmans/aur-mingw-builder:latest /build/update.sh

The packages will end up in the `/build/repo` directory inside the container; the `/build` directory
is a Docker volume.

Building will take a while but can be interrupted at any time. Just restart the container later
with `docker start` to update packages or build missing ones.

## Updating the package list

A default package list is part of the image. To update this list inside the previously made
`aur-mingw-build` container, run the `update-packages.sh` script:

    docker run --rm --volumes-from=aur-mingw-build haffmans/aur-mingw-builder:latest /build/update-packages.sh

You can run this script outside the docker environment too, if you have yaourt installed.
