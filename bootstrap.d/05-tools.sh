#!/bin/bash
# 05-tools.sh
# depends on 00-globals.sh and 01-logging.sh

install_small_apt_tools() {
    declare -a tools=("tree" "jq" "neofetch" "apt-transport-https") #apt-transport-https is for azure cli
    local final_log_line_counter=1
    log_update_status -m "Installing utility tolls via apt..."
    for tool in "${tools[@]}"; do
        log_update_status -i 1 -m "Installing ${tool}..."
        if ! is_package_installed "$tool"; then
            sudo apt-get install -y "${tool}" 2>&1 | log_with_upgrade_grep
            log_update_status -s -i 1 -n 2 -m "Installed ${tool}."
            ((final_log_line_counter++))
        else
            log_update_status -s -i 1 -n 1 -m "${tool} is already installed. Skipped."
        fi
    done
    log_update_status -s -n $((final_log_line_counter + ${#tools[@]})) -m "Installed utility tools."
}
