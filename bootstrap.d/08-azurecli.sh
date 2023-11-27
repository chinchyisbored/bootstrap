#!/bin/bash
# 08-azurecli.sh
# depends on 00-globals.sh and 01-logging.sh

install_azure_cli() {
    AZCLI_KEY_FILE="/etc/apt/keyrings/microsoft.gpg"
    AZCLI_GPG_URL="https://packages.microsoft.com/keys/microsoft.asc"
    AZCLI_URL="https://packages.microsoft.com/repos/azure-cli/"
    AZCLI_SOURCE="/etc/apt/sources.list.d/azure-cli.list"
    local final_log_line_counter=4

    log_update_status -m "Installing Azure-CLI..."
    #gpg key
    if [ ! -f "${AZCLI_KEY_FILE}" ]; then
        curl -sLS "${AZCLI_GPG_URL}" | gpg --dearmor | sudo tee "${AZCLI_KEY_FILE}" >/dev/null
        log_update_status -s -i 1 -m "Added Azure-CLI gpg key."
    else
        log_update_status -s -i 1 -m "Azure-CLI gpg key alread present. Skipped."
    fi
    #repo
    if ! repo_exists "${AZCLI_URL}" "${AZCLI_SOURCE}"; then
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=${AZCLI_KEY_FILE}]" \
            "${AZCLI_URL} ${CODENAME} main" |
            sudo tee "${AZCLI_SOURCE}" >/dev/null
        sudo apt-get update 2>&1 | log_with_date
        log_update_status -s -i 1 -m "Added Azure-CLI repo to apt."
    else
        log_update_status -s -i 1 -m "Azure-CLI repo already present in apt. Skipped."
    fi
    #install
    log_update_status -i 1 -m "Installing Azure-CLI packages..."
    if ! is_package_installed "azure-cli"; then
        sudo apt-get install -y azure-cli 2>&1 | log_with_upgrade_grep
        log_update_status -s -i 1 -n 2 -m "Installed Azure-CLI."
        ((final_log_line_counter++))
    else
        log_update_status -s -i 1 -n 1 -m "Azure-CLI is already installed. Skipped."
    fi
    log_update_status -s -n "${final_log_line_counter}" -m "Installed Azure-CLI."
}
