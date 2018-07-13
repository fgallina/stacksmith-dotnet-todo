#!/bin/bash
# Downloads example application and scripts for building.

set -euo pipefail
read -p "This will overwrite any files in user-scripts or user-uploads. Continue (y/n)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Downloading the example app and scripts..."

    wget https://github.com/bitnami-labs/stacksmith-examples/releases/download/v1/simple-asp-net-core-2-todo-app.zip \
        -O user-uploads/simple-asp-net-core-2-todo-app.zip --quiet
    wget https://raw.githubusercontent.com/bitnami-labs/stacksmith-examples/master/dotnet-core-with-mysql/todo/scripts/boot.sh \
        -O user-scripts/entrypoint.sh --quiet

    echo "Done. You can now build with 'docker-compose build'."
fi

