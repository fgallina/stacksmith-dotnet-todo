#!/bin/bash

set -euo pipefail

readonly uploads_dir=${UPLOADS_DIR:?Uploads directory not provided. Please set the UPLOADS_DIR environment variable}

installDependencies() {
    yum install -y unzip mariadb libunwind libicu libxml2
}

installDotnet() {
    # Add the MS repo for dotnet core
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sh -c 'echo -e "[packages-microsoft-com-prod]\nname=packages-microsoft-com-prod \nbaseurl= https://packages.microsoft.com/yumrepos/microsoft-rhel7.3-prod\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/dotnetdev.repo'

    # Refresh the index and install dotnet
    yum update -y
    yum install -y dotnet-sdk-2.1.4 dotnet-host-2.1.0 dotnet-runtime-deps-2.1.0
}

stripParentDirectories() {
    local directory=${1:?No directory specified}
    local tmpname="__tmp__$$__"

    # strip all elements that only have a single child directory and no other items
    # i.e. when an application is packaged as bin/Release/publish/..., strip bin/Release/publish
    while [ "$(find "${directory}" -mindepth 1 -maxdepth 1 -type d | wc -l)" -eq "1" ] && [ "$(find "${directory}" -mindepth 1 -maxdepth 1 -not -type d | wc -l)" -eq "0" ] ; do
        mv "${directory}" "${directory}.${tmpname}"
        mv "$(find "${directory}.${tmpname}" -mindepth 1 -maxdepth 1 -type d)" "${directory}"
    done
}

unpackApplication() {
    # unpack application if it has been uploaded and there is only one zip file present
    if [ "$(find "${uploads_dir}" -maxdepth 1 -type f \( -name '*.zip' -o -name '*.ZIP' \) | wc -l)" -eq "1" ]; then
        local zipfile="$(find "${uploads_dir}" -maxdepth 1 -type f \( -name '*.zip' -o -name '*.ZIP' \))"
        local appdir="/opt/app"
        mkdir -p "${appdir}"
        unzip -q "${zipfile}" -d "${appdir}"
        stripParentDirectories "${appdir}"
        chown -R root:root "${appdir}"
    fi
}

main() {
    installDependencies
    installDotnet
    unpackApplication
}

main "$@"
