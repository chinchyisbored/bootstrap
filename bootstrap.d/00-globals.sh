#!/bin/bash
# 00-globals.sh

#GLOBALS
UPGRADE_GREP="^\d+ upgraded, \d+ newly installed, \d+ to remove and \d+ not upgraded\."
SED_IDENT="s/^/     └> /"
SED_NO_IDENT="s/^/ └> /"
CODENAME=$(lsb_release -cs)
