#!/bin/bash
# 99-finish.sh
# depends on 00-globals.sh and 01-logging.sh

set_zsh_default() {
    if [ "${SHELL}" != "$(which zsh)" ]; then
        sudo chsh -s "$(which zsh)" "${USER}"
        log_update_status -s -m "Set zsh as the default shell."
    else
        log_update_status -s -m "zsh is already the default shell. Skipped."
    fi
}

switch_to_zsh() {
    user_response=$(log_request_input "Would you like to restart the shell? (Y/n). This concludes the bootstrap script:")
    if [[ "${user_response}" =~ ^[Yy]$ || -z "${user_response}" ]]; then
        unset ZSH_STARTED
        exec zsh
    else
        log_update_status -s -n 1 -m "Finished bootstrap. You can manually restart the shell whenever you'd like. \n"
    fi
}
