# Bootstrap

This is my old Bootstrap Script for a WSL 2 Ubuntu development environment and was used in conjunction with [yadm](https://yadm.io/#).
It has since been superseded by an alternative implementation with [ansible](https://www.ansible.com/), but is still very much functioning. It requires dotfiles and a list of vscode extensions at `~/.vscode-server/data/Machine/vscode-extensions.txt`.

The main features of this script are idempotence, logging and cool looking terminal responses, which are achieved by moving the cursor:

![Alt text](pictures/image.png)

## Includes: ##

- **Git**: Most recent version.
- **Utility**: tree, jq, neofetch, and apt-transport-https.
- **Docker.**
- **Terraform.**
- **Azure-CLI.**
- **VSCode Extensions.**
- **ZSH.**
- **Oh-My-Zsh.**
- **Oh-My-Zsh Plugins.**
- **Pyenv.**
- **Python Build Dependencies.**
- **Python.**


