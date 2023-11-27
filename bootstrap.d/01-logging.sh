#!/bin/bash
# 01-logging.sh

#COLORS
C_ERROR=$(tput setaf 9)
C_SUCCESS=$(tput setaf 10)
C_INPUT=$(tput setaf 11)
C_STOP=$(tput sgr0)
#SYMBOLS
INFO="[i]"
AWAIT="[?]"
SUCCESS="[${C_SUCCESS}✓${C_STOP}]"
ERROR="[${C_ERROR}✗${C_STOP}]"
#CONFIG
INDENT_WIDTH=4

LOGSDIR="${HOME}/.config/yadm/logs"
mkdir -p "${LOGSDIR}"
LOGFILE="${LOGSDIR}/$(date '+%Y-%m-%d_%H-%M-%S')_logfile.log"

indent_spaces() {
    local indent_count="$1"
    local total_width=$((indent_count * INDENT_WIDTH))
    printf '%*s' "$total_width" ''
}

log_with_date() {
    while IFS= read -r line; do
        echo "$(date +%Y-%m-%d-%H:%M:%S) $line"
    done >>"${LOGFILE}" 2>&1
}

log_with_upgrade_grep() {
    tee >(log_with_date) | grep -oP "${UPGRADE_GREP}" | sed "${SED_IDENT}"
}

log_update_status() {
    local indent_count=0
    local message=""
    local lines_to_jump=0
    local symbol="${INFO}"
    local OPTIND flag
    local is_update=0

    while getopts "sfm:n:i:" flag; do
        case "${flag}" in
        s)
            symbol="${SUCCESS}"
            ;;
        f)
            symbol="${ERROR}"
            ;;
        m) message="${OPTARG}" ;;
        n) lines_to_jump="${OPTARG}" ;;
        i) indent_count="${OPTARG}" ;;
        *)
            echo "Unknown argument: -${OPTARG}" >&2
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    if ((lines_to_jump > 0)); then
        is_update=1
    fi

    local spaces
    spaces=$(indent_spaces "${indent_count}")

    if ((is_update)); then
        # Update logic: Move the cursor, overwrite the line, then move the cursor back
        echo -ne "\033[${lines_to_jump}A"                # Move cursor up
        echo -ne "\r\033[K${spaces}${symbol} ${message}" # Overwrite the line
        echo -ne "\033[${lines_to_jump}B"                # Move cursor down
        echo "${symbol} ${message}" | perl -pe 's/\e[\[\(][0-9;]*[mGKFB]//g' | log_with_date
    else
        echo -e "\r\033[K${spaces}${symbol} ${message}"
        echo "${symbol} ${message}" | perl -pe 's/\e[\[\(][0-9;]*[mGKFB]//g' | log_with_date
    fi

    # Reset cursor to the start of the line
    echo -ne "\r"
}

log_request_input() {
    local prompt="$1"
    echo -ne "${AWAIT} ${C_INPUT}${prompt}${C_STOP} " >&2
    read -r response
    echo "${response}"
    echo "Prompt: ${prompt}" | log_with_date
    echo "Response: ${response}" | log_with_date
}
