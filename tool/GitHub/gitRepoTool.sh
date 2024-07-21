#!/bin/bash

#* Colores
GREEN='\033[0;32m'  #? Exito
RED='\033[0;31m'    #? Error
YELLOW='\033[1;33m' #? Aviso
PURPLE='\033[0;35m' #? Informacion git
BLUE='\033[0;34m'   #? Input del Usuario
NC='\033[0m'        #; Sin color

#* Función para pausar la ejecución si se ejecuta fuera de la terminal
pause_if_not_terminal() {
    if [[ ! -t 1 ]]; then
        printf "${BLUE}Presione Enter para continuar...${NC}"
        read -r
    fi
}

#* Función para mostrar mensajes en color
echo_color() {
    printf "%b%s%b\n" "${2}" "${1}" "${NC}"
}

#* Obtener la fecha y hora actual
current_datetime() {
    local datetime
    datetime=$(date '+%Y-%m-%d %H:%M:%S')
    printf "%s" "$datetime"
}

#* Obtener el nombre del repositorio a partir de la URL
get_repo_name() {
    local repo_url repo_name
    repo_url=$(git config --get remote.origin.url)
    if [[ -z "$repo_url" ]]; then
        printf "%bError: No se pudo obtener la URL del repositorio.%b\n" "${RED}" "${NC}" >&2
        return 1
    fi
    repo_name=$(basename -s .git "$repo_url")
    printf "%s" "$repo_name"
}

#* Solicitar la URL del repositorio remoto
prompt_repo_url() {
    local remote_url
    read -p "$(echo_color 'Introduce la URL del repositorio remoto: ' "${BLUE}")" remote_url
    if [[ -z "$remote_url" ]]; then
        echo_color 'La URL del repositorio no puede estar vacía.' "${RED}" >&2
        return 1
    fi
    printf "%s" "$remote_url"
}

#* Solicitar la ruta del repositorio (opcional)
prompt_repo_path() {
    local repo_path
    read -p "$(echo_color 'Introduce la ruta donde se clonará el repositorio (Opcional, por defecto es la ruta actual): ' "${BLUE}")" repo_path
    printf "%s" "$repo_path"
}

#* Clonar el repositorio
clone_repo() {
    local remote_url="$1"
    local repo_path="$2"
    echo_color 'Clonando el repositorio...' "${PURPLE}"
    if ! git clone "$remote_url" "$repo_path"; then
        echo_color 'Error al clonar el repositorio.' "${RED}" >&2
        return 1
    fi
}

#* Verificar si la rama principal es 'main' o 'master'
get_default_branch() {
    local default_branch
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if [[ -z "$default_branch" ]]; then
        echo_color 'No se pudo determinar la rama principal. Usando "main" por defecto.' "${YELLOW}" >&2
        default_branch="main"
    fi
    printf "%s" "$default_branch"
}

#* Limpiar el repositorio
clean_repo() {

    # Eliminar todas las ramas excepto la principal
    delete_branches_except_main() {
        local main_branch="$1"
        echo_color 'Eliminando todas las ramas excepto la principal...' "${PURPLE}"
        for branch in $(git branch --format='%(refname:short)'); do
            if [[ "$branch" != "$main_branch" ]]; then
                git branch -D "$branch"
            fi
        done
        for branch in $(git branch -r | grep -v '\->' | grep -v "origin/$main_branch" | sed 's/origin\///'); do
            git push origin --delete "$branch"
        done
    }

    local default_branch="$1"

    delete_branches_except_main "$default_branch"

    echo_color "Eliminando archivos y carpetas del repositorio..." "${PURPLE}"
    rm -rf *
    find . -mindepth 1 -maxdepth 1 -name ".*" ! -name ".git" -exec rm -rf {} +

    echo_color "Haciendo el commit de limpieza..." "${PURPLE}"
    if ! git add .; then
        echo_color "Error al agregar archivos para el commit de limpieza." "${RED}" >&2
        return 1
    fi

    git commit -m "Cleaning commit $(current_datetime)"

    echo_color "Enviando cambios a la rama '$default_branch' del repositorio remoto..." "${PURPLE}"
    if ! git push origin "$default_branch"; then
        echo_color "Error al enviar los cambios a la rama '$default_branch'." "${RED}" >&2
        return 1
    fi

    echo_color "Eliminando el directorio .git..." "${PURPLE}"
    rm -rf .git
}

#* Eliminar el repositorio si existe
remove_existing_repo() {
    local repo_path="$1"
    if [[ -d "$repo_path" ]]; then
        echo_color 'Eliminando el directorio existente del repositorio...' "${PURPLE}"
        rm -rf "$repo_path"
    fi
}

#* Crear la rama main, crear README.md y hacer commit inicial
initialize_main_branch() {
    local repo_name="$1"

    echo_color 'Inicializando el repositorio con git init...' "${PURPLE}"
    if ! git init; then
        echo_color 'Error al inicializar el repositorio.' "${RED}" >&2
        return 1
    fi

    echo_color 'Creando la rama main...' "${PURPLE}"
    git branch -M main

    echo_color 'Creando README.md para la rama principal...' "${PURPLE}"
    echo -e "# $repo_name [$(current_datetime)]" >README.md

    echo_color 'Agregando README.md...' "${PURPLE}"
    if ! git add README.md; then
        echo_color 'Error al agregar README.md.' "${RED}" >&2
        return 1
    fi

    echo_color 'Haciendo el commit inicial en la rama main...' "${PURPLE}"
    if ! git commit -m "Initial commit in main branch $(current_datetime)"; then
        echo_color 'Error al realizar el commit inicial.' "${RED}" >&2
        return 1
    fi
}

#* Procesar y crear ramas iniciales
process_branches() {
    local branches branch

    prompt_branches() {
        local branches
        read -p "$(echo_color 'Introduce los nombres de las ramas iniciales, separados por espacios (Opcional): ' "${BLUE}")" branches
        printf "%s" "$branches"
    }

    create_switch_branch() {
        local branch="$1"
        echo_color "Creando y cambiando a la rama '$branch'..." "${PURPLE}"
        if ! git checkout -b "$branch"; then
            echo_color "Error al crear y cambiar a la rama '$branch'." "${RED}" >&2
            return 1
        fi
    }

    create_readme_branch() {
        local branch="$1"
        echo_color "Creando README.md para la rama '$branch'..." "${PURPLE}"
        echo -e "# $branch\n## $(current_datetime)" >README.md
    }

    commit_readme() {
        local branch="$1"
        if ! git add README.md; then
            echo_color "Error al agregar README.md para la rama '$branch'." "${RED}" >&2
            return 1
        fi
        if ! git commit -m "Added README.md for $branch branch $(current_datetime)"; then
            echo_color "Error al hacer commit del README.md en la rama '$branch'." "${RED}" >&2
            return 1
        fi
    }

    push_branch() {
        local branch="$1"
        echo_color "Enviando la rama '$branch' al remoto..." "${PURPLE}"
        if ! git push -u origin "$branch"; then
            echo_color "Error al enviar la rama '$branch' al remoto." "${RED}" >&2
            return 1
        fi
    }

    branches=$(prompt_branches)
    if [[ -z "$branches" ]]; then
        return 2
    fi

    IFS=' ' read -r -a branches <<<"$branches"

    for branch in "${branches[@]}"; do
        echo_color "Creando y cambiando a la rama '$branch' desde la rama main..." "${PURPLE}"
        if ! git checkout -b "$branch" main; then
            echo_color "Error al crear y cambiar a la rama '$branch' desde la rama main." "${RED}" >&2
            return 1
        fi

        create_switch_branch "$branch" || return 1
        create_readme_branch "$branch" || return 1
        commit_readme "$branch" || return 1
        push_branch "$branch" || return 1

        echo_color 'Volviendo a la rama main...' "${PURPLE}"
        if ! git checkout main; then
            echo_color 'Error al volver a la rama main.' "${RED}" >&2
            return 1
        fi
    done

    return 0
}

#* Inicializar el repositorio
initialize_repo() {
    local remote_url repo_path repo_name

    remote_url=$(prompt_repo_url) || return 1
    repo_path=$(prompt_repo_path)
    repo_path="${repo_path:-$(pwd)}"

    repo_name=$(basename -s .git "$(basename "$remote_url")")
    if [[ -z "$repo_path" || ! "$repo_path" =~ $repo_name ]]; then
        echo_color "La ruta del repositorio no coincide con el nombre del repositorio o está vacía, usando la ruta actual." "${YELLOW}"
        repo_path=$(pwd)/"$repo_name"
    fi

    if [[ -d "$repo_path" ]]; then
        remove_existing_repo "$repo_path"
    fi

    mkdir -p "$repo_path"
    cd "$repo_path" || return 1

    initialize_main_branch "$repo_name" || return 1

    echo_color 'Agregando el origen remoto...' "${PURPLE}"
    if ! git remote add origin "$remote_url"; then
        echo_color 'Error al agregar el origen remoto.' "${RED}" >&2
        return 1
    fi

    echo_color 'Enviando la rama main al remoto...' "${PURPLE}"
    if ! git push -u origin main; then
        echo_color 'Error al enviar la rama main al remoto.' "${RED}" >&2
        return 1
    fi

    echo_color 'El repositorio ha sido inicializado.' "${GREEN}"

    process_branches
    case $? in
    1)
        echo_color 'Error al crear y enviar las ramas personalizadas al remoto.' "${RED}" >&2
        return 1
        ;;
    2)
        echo_color 'No se proporcionaron ramas adicionales. Finalizando la función.' "${YELLOW}"
        return 2
        ;;
    0)
        echo_color 'Las ramas personalizadas han sido creadas y enviadas al remoto.' "${GREEN}"
        ;;
    esac
}

#* Reiniciar el repositorio de fábrica
reset_repo() {
    local remote_url repo_path default_branch repo_name

    remote_url=$(prompt_repo_url) || return 1
    repo_path=$(prompt_repo_path)
    repo_path="${repo_path:-$(pwd)}"

    repo_name=$(basename -s .git "$(basename "$remote_url")")
    if [[ -z "$repo_path" || ! "$repo_path" =~ $repo_name ]]; then
        echo_color "La ruta del repositorio no coincide con el nombre del repositorio o está vacía, usando la ruta actual." "${YELLOW}"
        repo_path=$(pwd)/"$repo_name"
    fi

    if [[ -d "$repo_path" ]]; then
        remove_existing_repo "$repo_path"
    fi

    clone_repo "$remote_url" "$repo_path" || return 1
    cd "$repo_path" || return 1

    default_branch=$(get_default_branch) || return 1

    clean_repo "$default_branch" || return 1

    initialize_main_branch "$repo_name" || return 1

    echo_color 'Agregando el origen remoto...' "${PURPLE}"
    if ! git remote add origin "$remote_url"; then
        echo_color 'Error al agregar el origen remoto.' "${RED}" >&2
        return 1
    fi

    echo_color 'Enviando la rama main al remoto...' "${PURPLE}"
    if ! git push -f -u origin main; then
        echo_color 'Error al enviar la rama main al remoto.' "${RED}" >&2
        return 1
    fi

    echo_color 'El repositorio ha sido reiniciado.' "${GREEN}"

    process_branches
    case $? in
    1)
        echo_color 'Error al crear y enviar las ramas personalizadas al remoto.' "${RED}" >&2
        return 1
        ;;
    2)
        echo_color 'No se proporcionaron ramas adicionales. Finalizando la función.' "${YELLOW}"
        return 2
        ;;
    0)
        echo_color 'Las ramas personalizadas han sido creadas y enviadas al remoto.' "${GREEN}"
        ;;
    esac
}

#* Función principal
main() {
    local choice

    PS3="$(echo_color 'Introduce tu elección (1 o 2): ' "${BLUE}")"
    options=("Inicializar el repositorio" "Reiniciar el repositorio" "Salir")

    select opt in "${options[@]}"; do
        case $REPLY in
        1)
            initialize_repo
            break
            ;;
        2)
            reset_repo
            break
            ;;
        3)
            echo_color 'Saliendo...' "${YELLOW}"
            return 1
            ;;
        *) echo_color 'Opción no válida. Inténtalo de nuevo.' "${RED}" >&2 ;;
        esac
    done
}

main "$@"

# Pausar si no se ejecuta en una terminal
pause_if_not_terminal
