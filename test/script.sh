#!/bin/bash

# Chemin vers le script Perl (ajuster si nécessaire)
PERL_SCRIPT="./script.pl"
# PERL_SCRIPT="./script_gpt.pl"

# Fichier à analyser (passé en argument)
# INPUT_FILE="./lib.rs"
INPUT_FILE="./lib_empty.rs"
# INPUT_FILE="./.env_empty"

# Pattern regex avec groupe de capture (passé en argument)
PATTERN="impl(?:\s*)ServicesName.*as_str.*match *self *\{(?: *\n(.*?)\n *|())\}" # lib.rs
# PATTERN="impl +ServicesNName +\{\s*fn +as_str.*\{\s*match +self +\{\n((?:.*\n)*?)^\s*\}" # lib.rs
# PATTERN="#(?:\s*)Services(?:\s*)ports(?:\s*)\n((?:SERVICE_[A-Z_]+_PORT=\d+\n?)*)" # .env

if [ ! -f "$INPUT_FILE" ]; then
    echo "Erreur: Fichier $INPUT_FILE introuvable" >&2
    exit 1
fi

# Appel du script Perl (version optimisée qui lit directement le fichier)
"$PERL_SCRIPT" "$INPUT_FILE" "$PATTERN"