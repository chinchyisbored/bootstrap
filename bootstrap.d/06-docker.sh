#!/bin/bash
# 06-docker.sh
# depends on 00-globals.sh and 01-logging.sh

install_docker() {
    packages_to_uninstall=(
        docker.io
        docker-doc
        docker-compose
        docker-compose-v2
        podman-docker
        containerd
        runc
    )
    packages_to_install=(
        docker-ce
        docker-ce-cli
        containerd.io
        docker-buildx-plugin
        docker-compose-plugin
    )
    DOCKER_KEY_FILE="/etc/apt/keyrings/docker.gpg"
    DOCKER_GPG_URL="https://download.docker.com/linux/ubuntu/gpg"
    DOCKER_URL="https://download.docker.com/linux/ubuntu"
    DOCKER_SOURCE_PATH="/etc/apt/sources.list.d/docker.list"
    local final_log_line_counter=1

    log_update_status -m "Installing docker..."
    sleep 2
    #uninstall conflicting preinstalled stuff
    local uninstallcounter=0
    log_update_status -i 1 -m "Uninstalling conflicting packages..."
    sleep 2
    for pkg in "${packages_to_uninstall[@]}"; do
        if is_package_installed "${pkg}"; then
            sudo apt-get remove -y "${pkg}" 2>&1 | log_with_date

            ((uninstallcounter++))
        fi
    done

    if [ "${uninstallcounter}" -ne 0 ]; then
        log_update_status -s -i 1 -n 1 -m "Uninstalled ${uninstallcounter} conflicting packages."
    else
        log_update_status -s -i 1 -n 1 -m "No conflicting packages installed."
    fi
    ((final_log_line_counter++))
    #gpg key and repo to apt
    sudo install -m 0755 -d /etc/apt/keyrings 2>&1 | log_with_date
    if [ ! -f "${DOCKER_KEY_FILE}" ]; then
        curl -fsSL "${DOCKER_GPG_URL}" | sudo gpg --dearmor -o "${DOCKER_KEY_FILE}"
        log_update_status -s -i 1 -m "Added docker gpg key."
    else
        sleep 2
        log_update_status -s -i 1 -m "docker gpg key already present. Skipped."
    fi
    ((final_log_line_counter++))

    perms=$(stat -c "%a" "${DOCKER_KEY_FILE}")
    if [ "$perms" != "755" ]; then
        sudo chmod a+r "${DOCKER_KEY_FILE}"
    fi

    if ! repo_exists "${DOCKER_URL}" "${DOCKER_SOURCE_PATH}"; then
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=${DOCKER_KEY_FILE}] ${DOCKER_URL}" \
            "$(. /etc/os-release && echo "${VERSION_CODENAME}") stable" |
            sudo tee "${DOCKER_SOURCE_PATH}" >/dev/null
        sudo apt-get update 2>&1 | log_with_date
        log_update_status -s -i 1 -m "Added docker repo to apt."
    else
        log_update_status -s -i 1 -m "docker repo already present in apt. Skipped."
    fi
    ((final_log_line_counter++))

    #docker packages install
    packages_needed=()
    log_update_status -i 1 -m "Installing docker packages..."
    for pkg in "${packages_to_install[@]}"; do
        if ! is_package_installed "${pkg}"; then
            packages_needed+=("${pkg}")
        fi
    done
    ((final_log_line_counter++))

    if [ "${#packages_needed[@]}" -ne 0 ]; then
        sudo apt-get install -y "${packages_needed[@]}" 2>&1 | log_with_upgrade_grep
        log_update_status -s -i 1 -n 2 -m "Installed docker packages."
        ((final_log_line_counter++))
    else
        log_update_status -s -i 1 -n 1 -m "docker already installed. Skipped."
    fi

    #group stuff
    if ! getent group docker &>/dev/null; then
        sudo groupadd docker
        log_update_status -s -i 1 -m "Added docker group"
    else
        log_update_status -s -i 1 -m "docker group already present. Skipped."
    fi
    ((final_log_line_counter++))

    if ! id -nG "${USER}" | grep -qw docker; then
        sudo usermod -aG docker "${USER}"
        log_update_status -s -i 1 -m "Added user to docker group."
    else
        log_update_status -s -i 1 -m "User already added to docker group. Skipped"
    fi
    ((final_log_line_counter++))
    log_update_status -s -n "${final_log_line_counter}" -m "Installed docker."
}
