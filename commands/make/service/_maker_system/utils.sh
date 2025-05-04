insert_sorted_entry_in_block() {
    local file_path="$1"
    local start_pattern="$2"
    local end_pattern="$3"
    local new_entry="$4"

    # Extraire le bloc puis enlever la première et dernière ligne
    members_block=$(sed -n "/$start_pattern/,/$end_pattern/p" "$file_path" | sed '1d;$d')

    # Vérification de la récupération du bloc
    if [[ -z "$members_block" ]]; then
        echo "Erreur : bloc introuvable entre les motifs '$start_pattern' et '$end_pattern' dans le fichier '$file_path'." >&2
        return 1
    fi

    # Corriger la dernière ligne si elle ne se termine pas par une virgule (éventuellement avec espaces)
    members_block=$(echo "$members_block" | sed '$s/\([^,[:space:]]\)[[:space:]]*$/\1,/' )

    original_count=$(echo "$members_block" | wc -l)

    # Ajouter la nouvelle entrée à la fin
    members_block="$members_block"$'\n'"$new_entry"

    members_block=$(echo "$members_block" | sort)

    # Étape 1 : Trouver la ligne où commence le bloc
    member_begin_line=$(grep -n "$start_pattern" "$file_path" | head -n1 | cut -d: -f1)

    # Étape 2 : Compter le nombre de lignes dans le bloc (sans les lignes d'ouverture/fermeture)
    original_members_block=$(sed -n "/$start_pattern/,/$end_pattern/p" "$file_path" | sed '1d;$d')
    original_count=$(echo "$original_members_block" | wc -l)

    # Calcul de la ligne après le bloc
    lines_after_member_array=$((member_begin_line + original_count + 1))  # +1 pour la ligne contenant le "]"

    # Étape 3 : Capturer toutes les lignes après cette ligne
    lines_after_member=$(tail -n +"$((lines_after_member_array))" "$file_path")

    # Lire le contenu entier du fichier
    cargo_content=$(cat "$file_path")

    # Supprimer tout après la ligne $member_begin_line
    cargo_content=$(echo "$cargo_content" | head -n "$member_begin_line")

    # Ajouter le bloc members trié
    cargo_content="$cargo_content
$members_block"

    # Ajouter les lignes après le tableau
    cargo_content="$cargo_content
$lines_after_member"

    echo "$cargo_content" > "$file_path"
}

recursive_copy_and_fill() {
  local source_dir="$1"
  local target_dir="$2"
  local service_name="$3"
  local upper_name="$4"
  local service_port="$5"

  cp -r "$source_dir" "$target_dir"

  find "$target_dir" -type f -exec sed -i \
    -e "s/<new_service_name>/${service_name}/g" \
    -e "s/<NEW_SERVICE_NAME>/${upper_name}/g" \
    -e "s/<new_service_port>/${service_port}/g" {} +
}