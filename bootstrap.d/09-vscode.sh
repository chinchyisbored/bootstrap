#!/bin/bash
# 09-vscode.sh
# depends on 00-globals.sh and 01-logging.sh

install_vscode_extensions() {
    EXTENSIONFILEPATH="${HOME}/.vscode-server/data/Machine/vscode-extensions.txt"
    local final_log_line_counter=1
    log_update_status -m "Installing vscode extensions..."
    if ! command -v code &>/dev/null; then
        log_update_status -f -m "bootstrap-vscode: Error: 'code' command not found."
        exit 1
    fi

    installed_extensions=$(code --list-extensions 2>/dev/null | tail -n +2 2>/dev/null)
    while IFS= read -r extension; do
        if echo "$installed_extensions" | grep -q "^$extension$"; then
            log_update_status -s -i 1 -m "Extension $extension is already installed. Skipped."
        else
            code --install-extension "$extension" 2>&1 | log_with_date
            log_update_status -s -i 1 -m "Installed $extension"
        fi
        ((final_log_line_counter++))
    done <"${EXTENSIONFILEPATH}"
    log_update_status -s -n "${final_log_line_counter}" -m "Installed vscode extensions."
}
