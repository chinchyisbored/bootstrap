#!/bin/bash
# 10-zsh.sh
# depends on 00-globals.sh and 01-logging.sh

install_zsh() {
    log_update_status -m "Installing zsh..."
    if ! is_package_installed "zsh"; then
        sudo apt-get install -y zsh 2>&1 | log_with_upgrade_grep
        log_update_status -s -n 2 -m "Installed zsh."
    else
        log_update_status -s -n 1 -m "zsh is already installed. Skipped."
    fi
}

install_omz() {
    OMZ_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    PRE_OMZ_ZSHRC="${HOME}/.zshrc.pre-oh-my-zsh"
    local final_log_line_counter=1

    log_update_status -m "Installing oh-my-zsh..."
    if [ ! -d "${HOME}/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL ${OMZ_INSTALL_URL} 2>&1)" "" --unattended 2>&1 | log_with_date
        yadm restore .zshrc 2>&1 | log_with_date
        log_update_status -s -i 1 -m "Restored .zshrc from yadm."
        ((final_log_line_counter++))
        if [ -f "${PRE_OMZ_ZSHRC}" ]; then
            rm "${PRE_OMZ_ZSHRC}" 2>&1 | log_with_date
            log_update_status -s -i 1 -m "Deleted ${PRE_OMZ_ZSHRC}."
            ((final_log_line_counter++))
        fi
        log_update_status -s -n "${final_log_line_counter}" -m "Installed oh-my-zsh."
    else
        log_update_status -s -n "${final_log_line_counter}" -m "oh-my-zsh is already installed. Skipped."
    fi

}

install_omz_plugins() {
    declare -A plugins
    plugins["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    plugins["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    plugins["zsh-shift-select"]="https://github.com/jirutka/zsh-shift-select.git"
    plugins["powerlevel10k"]="https://github.com/romkatv/powerlevel10k.git"
    local final_log_line_counter=1

    log_update_status -m "Installing omz-plugins..."
    for plugin in "${!plugins[@]}"; do
        plugin_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
        if [ "$plugin" == "powerlevel10k" ]; then
            plugin_dir+="/themes/${plugin}"
        else
            plugin_dir+="/plugins/${plugin}"
        fi

        if [ ! -d "${plugin_dir}" ]; then
            git clone "${plugins[$plugin]}" "${plugin_dir}" 2>&1 | log_with_date
            log_update_status -s -i 1 -m "Installed ${plugin}."
        else
            log_update_status -s -i 1 -m "${plugin} is already installed. Skipped."
        fi
        ((final_log_line_counter++))
    done
    log_update_status -s -n "${final_log_line_counter}" -m "Installed omz-plugins."
}
