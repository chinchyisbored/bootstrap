#!/bin/bash
# 04-git.sh
# depends on 00-globals.sh and 01-logging.sh

update_git() {
    PPA_NAME="ppa:git-core/ppa"
    PPA_FILE="/etc/apt/sources.list.d/git-core-ubuntu-ppa-${CODENAME}.list"
    PPA_CONTENT="deb https://ppa.launchpadcontent.net/git-core/ppa/ubuntu/ ${CODENAME} main"
    local final_log_line_counter=2

    log_update_status -m "Updating git..."
    if [ ! -f "${PPA_FILE}" ] || ! grep -qF "${PPA_CONTENT}" "${PPA_FILE}"; then
        sudo add-apt-repository "${PPA_NAME}" -y 2>&1 | log_with_date
        sudo apt-get update 2>&1 | log_with_date
        log_update_status -s -i 1 -m "Added PPA git repo to apt."
        log_update_status -i 1 -m "Downloading git..."
        sudo apt-get install git -y 2>&1 | log_with_upgrade_grep
        log_update_status -s -n 2 -i 1 -m "Downloaded git."
        ((final_log_line_counter += 2))
    else
        log_update_status -s -i 1 -m "git PPA already present. Skipped."

    fi
    log_update_status -s -n "${final_log_line_counter}" -m "Updated git."
}
