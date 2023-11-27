#!/bin/bash
# 07-terraform.sh
# depends on 00-globals.sh and 01-logging.sh

install_terraform() {
    TERRAFORM_KEY_FILE="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
    TERRAFORM_GPG_URL="https://apt.releases.hashicorp.com/gpg"
    TERRAFORM_URL="https://apt.releases.hashicorp.com"
    TERRAFORM_SOURCE="/etc/apt/sources.list.d/hashicorp.list"
    local final_log_line_counter=4

    log_update_status -m "Installing terraform..."
    #gpg key
    if [ ! -f "${TERRAFORM_KEY_FILE}" ]; then
        curl -fsSL "${TERRAFORM_GPG_URL}" | gpg --dearmor | sudo tee "${TERRAFORM_KEY_FILE}" >/dev/null
        log_update_status -s -i 1 -m "Added terraform gpg key."
    else
        log_update_status -s -i 1 -m "terraform gpg key alread present. Skipped."
    fi
    #apt repo
    if ! repo_exists "${TERRAFORM_URL}" "${TERRAFORM_SOURCE}"; then
        echo \
            "deb [signed-by=${TERRAFORM_KEY_FILE}]" \
            "${TERRAFORM_URL} ${CODENAME} main" |
            sudo tee "${TERRAFORM_SOURCE}" >/dev/null
        sudo apt-get update 2>&1 | log_with_date
        log_update_status -s -i 1 -m "Added terraform repo to apt."
    else
        log_update_status -s -i 1 -m "terraform repo already present in apt. Skipped."
    fi
    #tf install
    log_update_status -i 1 -m "Installing terraform packages..."
    if ! is_package_installed "terraform"; then
        sudo apt-get install -y terraform 2>&1 | log_with_upgrade_grep
        log_update_status -s -i 1 -n 2 -m "Installed terraform packages."
        ((final_log_line_counter++))
    else
        log_update_status -s -i 1 -n 1 -m "terraform is already installed. Skipped."
    fi
    log_update_status -s -n "${final_log_line_counter}" -m "Installed terraform."
}
