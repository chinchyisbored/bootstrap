#!/bin/bash
# 11-pyenv.sh
# depends on 00-globals.sh and 01-logging.sh

install_pyenv() {
    PYENV_INSTALL_URL="https://pyenv.run"
    local final_log_line_counter=1
    log_update_status -m "Installing pyenv..."
    if command -v pyenv >/dev/null 2>&1; then
        log_update_status -s -n "${final_log_line_counter}" -m "pyenv is already installed. Skipped."
    else
        curl -fsSL "${PYENV_INSTALL_URL}" | bash 2>&1 | log_with_date
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init --path)"
        log_update_status -s -i 1 -m "Temporarily added pyenv to path"
        ((final_log_line_counter++))
        log_update_status -s -n "${final_log_line_counter}" -m "Installed pyenv."
    fi
}

install_python_builddep() {
    PYTHON_DEPENDENCIES=(
        build-essential
        libssl-dev
        zlib1g-dev
        libbz2-dev
        libreadline-dev
        libsqlite3-dev
        curl
        libncursesw5-dev
        xz-utils
        tk-dev
        libxml2-dev
        libxmlsec1-dev
        libffi-dev
        liblzma-dev
    )
    log_update_status -m "Installing python build dependencies..."
    sudo apt-get install -y "${PYTHON_DEPENDENCIES[@]}" 2>&1 | tee >(log_with_date) | grep -oP "${UPGRADE_GREP}" | sed "${SED_NO_IDENT}" #bigger ident so no log_with_upgrade_grep
    log_update_status -s -n 2 -m "Installed python build dependencies."
}

install_python_version() {
    local final_log_line_counter=1
    if ! command -v pyenv &>/dev/null; then
        log_update_status -f -n 1 -m "Error: pyenv is not installed. Exiting..."
        exit 1
    fi
    python_pref=$(log_request_input "Would you like to install a certain python version? (Y/n):")
    if [[ "${python_pref}" =~ ^[Yy]$ || -z "${python_pref}" ]]; then
        desired_python_version=$(log_request_input "Please enter the desired Python version (e.g., 3.10.2):")
        if pyenv versions --bare | grep -q "^${desired_python_version}$"; then
            log_update_status -s -n 1 -m "Python ${desired_python_version} is already installed. Skipped."
        else
            pyenv install "${desired_python_version}" 2>&1 | tee >(log_with_date) | sed "${SED_IDENT}"
            pyenv global "${desired_python_version}" 2>&1 | log_with_date
            log_update_status -s -m "Python ${desired_python_version} has been installed and set as global."
        fi
    else
        log_update_status -s -n 1 -m "Skipped Python preinstallation."
    fi
}
