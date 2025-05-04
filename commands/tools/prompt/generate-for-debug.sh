#!/bin/bash

##############################################
# CONFIGURATION TO BE FILLED
##############################################

INTRODUCTION="Hello ! j'ai besoin de ton aide pour une question concernant un projet que je développe.
Je vais d'abord te poser le contexte général de mon projet avant de t'exposer ma problématique."

APP_GOAL="Le but de l'application est de créer un jeu de role en ligne dans lequel l'histoire est comptée par un MJ qui est gérée par une IA (un LLM). Cette application est architecturée en micro service; elle contient pour l'instant 5 principales briques : 
- [frontend] la brique Web ; qui permettra d'offrir une interface web ergonomique pour les joueurs
- [backend] la brique Universe ; qui a pour but de fournir des informations structurées relative à un univers imaginaire (donjon et dragon, warhammer, ...)
- [backend] la brique Adventure ; qui gèrera des instance d'univers, une aventure se passe dans un univers et cette brique stoquera et exposera l'état d'avancement du joueur dans l'univers initialement choisi
- [backend] la brique IA ; qui permettra de générer les prochaines étapes narratives du joueur en fonction de l'univers choisi et de l'état d'avancement de l'aventure
- [backend] la brique Game ; qui fait office de point d'entrée côté backend après la brique Web, et qui fait office de chef d'orchestre avec les autres brique de mon architecture

Chaque brique est gérée via un container docker, les containers dockers sont définis dans le dossier \`./dockers\`, et pour terminer j'utiliser un système de commande fait maison (je peux lancer des commandes de type \`./commands.sh tools/docker/ls\`)"

TECHNOLOGIES="rust | docker | ia (llm ?)"

EXPERIENCE="Je suis un ingénieur développeur/QA depuis ~10 ans, et je souhaite apprendre à utiliser des IA dans mes projet. Ce projet me permet justement de m'entrainer à utiliser/intégrer des ia."

##############################################
# PARAMETERS AND OPTIONS
##############################################

TREE_PATH=""
FILES_TO_PROCESS=()

show_help() {
  echo "Usage: ./generate-prompt.sh [OPTIONS] [files_or_directories...]"
  echo
  echo "This script generates a structured prompt to help describe a technical problem in your project."
  echo
  echo "Options:"
  echo "  --tree <directory>   Display the structure of the given directory using 'tree'."
  echo "                       Overrides the default root-level structure display."
  echo "  -h, --help           Show this help message and exit."
  echo
  echo "Arguments:"
  echo "  files_or_directories   A list of files or directories to include in the"
  echo "                         'RELEVANT FILE CONTENTS' section."
  exit 0
}


# Parse des arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tree)
      TREE_PATH="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      ;;
    *)
      FILES_TO_PROCESS+=("$1")
      shift
      ;;
  esac
done

##############################################
# PROMPT GENERATION
##############################################

echo "$INTRODUCTION"
echo
echo "====================================="
echo "### GENERAL PROJECT CONTEXT ###"
echo
echo "Application goal:"
echo "$APP_GOAL"
echo
echo "Technologies used:"

# Display technologies as a list
IFS='|' read -ra TECH_LIST <<< "$TECHNOLOGIES"
for tech in "${TECH_LIST[@]}"; do
  echo "- $(echo "$tech" | xargs)"
done

echo
echo "My experience level:"
echo "$EXPERIENCE"
echo

# Show project structure
if command -v tree &> /dev/null; then
  echo "====================================="
  echo "## GENERAL PROJECT STRUCTURE"
  echo
  echo '```'
  if [ -n "$TREE_PATH" ]; then
    tree -a "$TREE_PATH"
  else
    tree -I 'target|node_modules|.git|dist|build|venv|__pycache__|.vscode' -a
  fi
  echo '```'
  echo
fi

# Function to display file content
display_file_content() {
  local file="$1"
  if [ -f "$file" ]; then
    echo
    echo "Here is the content of the file \`$file\` :"
    echo
    echo '```'
    cat "$file"
    echo '```'
  fi
}

# Function to process files or directories
process_path() {
  local path="$1"
  if [ -f "$path" ]; then
    display_file_content "$path"
  elif [ -d "$path" ]; then
    find "$path" -type f | while read -r file; do
      display_file_content "$file"
    done
  else
    echo "❌ Invalid path: $path"
    exit 1
  fi
}

# If file paths were provided, display their contents
if [ "${#FILES_TO_PROCESS[@]}" -gt 0 ]; then
  echo "====================================="
  echo "## RELEVANT FILE CONTENTS FOR MY ISSUE"
  for path in "${FILES_TO_PROCESS[@]}"; do
    process_path "$path"
  done
  echo
fi

echo "====================================="
echo "### NOW, HERE IS THE DETAIL OF MY PROBLEM"
echo "(To be completed manually)"
echo
