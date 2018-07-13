#!/bin/bash

set -euo pipefail

readonly appdir="/opt/app"

determineDotNetEntrypoint() {
    local directory=${1:?Application directory not provided}
    local entrypoint=""

    if [ -f "${directory}/web.config" ] &&
      xmllint --xpath '/configuration/system.webServer/aspNetCore/@arguments' "${directory}/web.config" >/dev/null ; then
        # determine entrypoint from web.config file
        entrypoint=$(xmllint --xpath '/configuration/system.webServer/aspNetCore/@arguments' "${directory}/web.config" | \
          sed -E 's#^\s*arguments\s*=\s*"##;s#"$##;s#^\.[/\\]##')
    elif [ "$(find "${directory}" -maxdepth 1 -type f \( -name '*.deps.json' -o -name '*.runtimeconfig.json' \) | \
      sed -E 's#\.(deps|runtimeconfig)\.json$#.dll#' | uniq | wc -l)" -eq "1" ]; then
        # determine entrypoint based on .deps.json or .runtimeconfig.json filename
        entrypoint="$(basename "$(find "${directory}" -maxdepth 1 -type f \( -name '*.deps.json' -o -name '*.runtimeconfig.json' \) | \
          sed -E 's#\.(deps|runtimeconfig)\.json$#.dll#' | uniq)")"
    fi

    if (echo "${entrypoint}" | grep >/dev/null -E '\.dll$') && [ -f "${directory}/${entrypoint}" ]; then
        echo "${entrypoint}"
        return 0
    else
        return 1
    fi
}

main() {
    if [ -d "${appdir}" ]; then
        local entrypoint
        entrypoint="$(determineDotNetEntrypoint "${appdir}")"

        cd "${appdir}"
        exec dotnet "${entrypoint}"
    fi
}

main "$@"
