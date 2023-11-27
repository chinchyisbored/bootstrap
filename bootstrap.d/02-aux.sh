#!/bin/bash
# 02-aux.sh

## AUX

is_package_installed() {
    local package_name=$1
    dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -q "install ok installed"
}

repo_exists() {
    local repo_url="$1"
    local source_path="$2"
    grep -q "${repo_url}" "${source_path}" 2>/dev/null
}

print_asci() {
    if ! is_package_installed "figlet"; then
        sudo apt-get install -y figlet 2>&1 | log_with_date
    fi
    figlet "Bootstrap" -t
    echo "by Max Lautner"
}
