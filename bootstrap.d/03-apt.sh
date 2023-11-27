#!/bin/bash
# 03-apt.sh
# depends on 00-globals.sh and 01-logging.sh

apt_update_upgrade() {
    log_update_status -m "Initial apt-get update & upgrade."
    sudo apt-get update 2>&1 | log_with_date
    log_update_status -s -i 1 -m "Updated."
    log_update_status -i 1 -m "Upgrading..."
    sudo apt-get upgrade -y 2>&1 | log_with_upgrade_grep
    log_update_status -s -n 2 -i 1 -m "Upgraded."
    log_update_status -s -n 4 -m "Finished apt-get update & upgrade."
}
