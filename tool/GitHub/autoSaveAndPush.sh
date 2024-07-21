#!/bin/bash
#? Script para guardar los cambios y hacer un commit y un push desde la carpeta principal del repositorio

#* Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # Sin color

# Guardar la ruta actual
current_dir=$(pwd)

# Obtener la ruta principal del repositorio
if ! repo_dir=$(git rev-parse --show-toplevel); then
    printf "${RED}No se pudo obtener la ruta principal del repositorio.${NC}\n" >&2
    exit 1
fi

# Función para obtener la rama principal ('main' o 'master')
get_default_branch() {
    local default_branch
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if [[ -z "$default_branch" ]]; then
        printf "${YELLOW}No se pudo determinar la rama principal. Usando 'main' por defecto.${NC}\n" >&2
        default_branch="main"
    fi
    printf "%s" "$default_branch"
}

#* Mensaje por defecto del commit
commit_message=${1:-"$(basename "$repo_dir") automatic update from (autoSaveAndPush.sh)"}

# Cambiar al directorio del repositorio
cd "$repo_dir" || {
    printf "${RED}Error al cambiar al directorio del repositorio.${NC}\n" >&2
    exit 1
}

# Determinar la rama principal (main o master)
if ! default_branch=$(get_default_branch); then
    printf "${RED}Error al obtener la rama principal.${NC}\n" >&2
    cd "$current_dir"
    exit 1
fi

# Añadir cambios al índice, hacer commit y push
printf "${PURPLE}git add .${NC}\n"
if git add . && printf "${PURPLE}git commit -m \"%s\"${NC}\n" "$commit_message" && git commit -m "$commit_message" && printf "${PURPLE}git push origin %s${NC}\n" "$default_branch" && git push origin "$default_branch"; then
    printf "${GREEN}Cambios guardados y enviados exitosamente.${NC}\n"
    if total_commits=$(git rev-list --all --count); then
        printf "${GREEN}Total de commits en el repositorio: \033[1m%s\033[0m${NC}\n" "$total_commits"
    else
        printf "${YELLOW}No se pudo determinar el total de commits.${NC}\n" >&2
    fi
else
    printf "${RED}Error durante el proceso de git add, commit o push.${NC}\n" >&2
fi

# Volver a la ruta anterior
cd "$current_dir" || {
    printf "${RED}Error al volver a la ruta anterior.${NC}\n" >&2
    exit 1
}
