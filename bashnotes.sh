#!/usr/bin/env bash
#
#  ____            _       _   _       _
# | __ )  __ _ ___| |__   | \ | | ___ | |_ ___  ___
# |  _ \ / _` / __| '_ \  |  \| |/ _ \| __/ _ \/ __|
# | |_) | (_| \__ \ | | | | |\  | (_) | ||  __/\__ \
# |____/ \__,_|___/_| |_| |_| \_|\___/ \__\___||___/
#                                                 v0.1
#
# BashNotes is a simple bash script for managing notes
#
# bashnotes help                        : Shows the help menu for BashNotes
# bashnotes create <note_name>          : Creates a note with the given name and opens it in the default editor (add the --no flag before the filename if you don't want it opened after creation)
# bashnotes delete <note_name>          : Deletes the note with the given name
# bashnotes edit <note_name>            : Opens the given note in the default editor
# bashnotes info <note_name>            : Shows information about the given note
# bashnotes list <tag>                  : Lists all notes that belong to the given tag (lists all notes if no tag name is given)
# bashnotes search <search>             : Searches for the given search term in note names
# bashnotes tag <note_name> <tag_name>  : Assigns the given tag to the given note
# bashnotes untag <note_name>           : Removes the current tag from the given note
# bashnotes taglist                     : Lists all tags

# - CONFIG PREFERENCES -
BASE_LOCATION=~/.config/BashNotes
NOTES_LOCATION=${BASE_LOCATION}/notes
DEFAULT_EDITOR=nano
DEFAULT_EXTENSION=.md
# - END CONFIG PREFERENCES -

# - MAIN GLOBAL VARIABLES -
NOTES=()
TAGS=()

# - COLOR VARIABLES -
RED="\033[0;31m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
YELLOW='\033[0;33m'
RESETC="\033[0m"


# -- INITIALIZE --
# create folders
if ! [[ -d ${BASE_LOCATION} ]]; then
    mkdir ${BASE_LOCATION}
    mkdir ${NOTES_LOCATION}
fi

# fill the tags array
if ! [ -z $(ls -A ${NOTES_LOCATION}) ]; then
    for dir in ${NOTES_LOCATION}/*/; do
        dir=${dir%*/}
        if [ -z "$(ls -A ${dir})" ]; then
            rm -rf "${dir}"
        fi
    done
fi
shopt -s nullglob
for dir in ${NOTES_LOCATION}/*/; do
    dir=${dir%*/}   # remove the trailing "/"
    pure_tag_name=${dir/"${NOTES_LOCATION}/"/""}    # remove the base dir path
    TAGS+=("${pure_tag_name}")
done

# fill the notes array
for file in ${NOTES_LOCATION}/*${DEFAULT_EXTENSION}; do
    pure_filename1=${file/"${NOTES_LOCATION}/"/""}    # remove the base dir path
    NOTES+=("${pure_filename1}")
done
for dir in ${NOTES_LOCATION}/*/; do
    for file in $dir*${DEFAULT_EXTENSION}; do
        pure_filename2=${file/"${NOTES_LOCATION}/"/""}    # remove the base dir path
        NOTES+=("${pure_filename2}")
    done
done
shopt -u nullglob


# -- UTIL FUNCTIONS --
log() {
    local color
    if [[ "$1" = "INFO" ]]; then color=${GREEN}
    elif [[ "$1" = "WARN" ]]; then color=${YELLOW}
    elif [[ "$1" = "ERROR" ]]; then color=${RED}
    fi
    echo -e "${color}$2: $3.${RESETC}"
}

prompt() {
    while true; do
        echo -e "${YELLOW}$1 [y/n]: ${RESETC}"
        read -r yn
        case ${yn} in
            [Yy]*) echo "$2" ; return 0 ;;
            [Nn]*) echo "$3" ; return  1 ;;
        esac
    done
}

get_note_path() {
    for note in ${NOTES[@]}; do
            if [[ ${note} == */* ]]; then
            IFS='/' read -ra arr <<< "${note}"
            if [ "${arr[1]}" == "$1${DEFAULT_EXTENSION}" ]; then
                echo "${note}"
            fi
        else
            if [ "${note}" == "$1${DEFAULT_EXTENSION}" ]; then
                echo "${note}"
            fi
        fi
    done
}

get_note_tag() {
    local file
    file=$(get_note_path $1)
    echo ${file/"/$1${DEFAULT_EXTENSION}"/""}
}


# -- MAIN FUNCTIONS --
help() {
    echo -e \
    ${GREEN}"BashNotes v0.1
BashNotes is a simple bash script for managing notes
${BLUE}
 ?? bnotes help                        : ${GREEN}Shows the help menu for BashNotes${BLUE}
 ?? bnotes create <note_name>          : ${GREEN}Creates a note with the given name and opens it in the default editor${BLUE}
 ?? bnotes delete <note_name>          : ${GREEN}Deletes the note with the given name${BLUE}
 ?? bnotes edit <note_name>            : ${GREEN}Opens the note with the given name in the default editor${BLUE}
 ?? bnotes list <tag>                  : ${GREEN}Lists all notes that belong to the given tag (lists all notes if no tag name is given)${BLUE}
 ?? bnotes search <search>             : ${GREEN}Searches for the given search term in note names${BLUE}
 ?? bnotes tag <note_name> <tag_name>  : ${GREEN}Assigns the given tag to the given note${BLUE}
 ?? bnotes untag <note_name>           : ${GREEN}Removes the current tag from the given note${BLUE}
 ?? bnotes taglist                     : ${GREEN}Lists all tags"${RESET}
}

create() {
    # $1 = note name
    # if $1 is the --no flag, then $2 is the note name
    if [ "$1" == "--no" ]; then
        touch ${NOTES_LOCATION}/$2${DEFAULT_EXTENSION} && log INFO "Note created" "Succesfully created $1"
    else
        touch ${NOTES_LOCATION}/$1${DEFAULT_EXTENSION} && log INFO "Note created" "Succesfully created $1"
        ${DEFAULT_EDITOR} ${NOTES_LOCATION}/$1${DEFAULT_EXTENSION}
    fi
}

delete() {
    if [[ "${NOTES[*]}" == *"$(get_note_path $1)"* ]]; then
        prompt "Are you sure you want to delete this note?" "" "" && rm ${NOTES_LOCATION}/$(get_note_path $1) && log INFO "Note deleted" "Succesfully deleted $1"
    else
        log ERROR "Unable to delete" "The given note doesn't exist"
    fi
}

edit() {
    if [[ "${NOTES[*]}" == *"$(get_note_path $1)"* ]]; then
        ${DEFAULT_EDITOR} ${NOTES_LOCATION}/$(get_note_path $1)
    else
        log ERROR "Unable to open" "The given note doesn't exist"
    fi
}

info() {
    if [[ "${NOTES[*]}" == *"$(get_note_path $1)"* ]]; then
        local file=$(get_note_path $1)
        echo -e ${GREEN}"Name: $1.${DEFAULT_EXTENSION}"
        echo -e ${GREEN}"Tag: ${file/"/$1${DEFAULT_EXTENSION}"/""}"

        local stats=$(stat ${NOTES_LOCATION}/$(get_note_path $1))
        readarray -t stats <<<"${stats}"

        local created=${stats[7]/"Birth: "/""}
        IFS='.' read -ra created <<< "${created}"
        echo -e ${BLUE}"Created:${created[0]}"

        local modified=${stats[5]/"Modify: "/""}
        IFS='.' read -ra modified <<< "${modified}"
        echo -e ${BLUE}"Modified: ${modified[0]}"

        local lines=$(wc -l ${NOTES_LOCATION}/${file})
        echo -e ${BLUE}"Lines: ${lines/"${NOTES_LOCATION}/$(get_note_path $1)"/""}"

        local words=$(wc -w ${NOTES_LOCATION}/${file})
        echo -e ${BLUE}"Words: ${words/"${NOTES_LOCATION}/$(get_note_path $1)"/""}"
    else
        log ERROR "Unable to display info" "The given note doesn't exist"
    fi
}

list() {
    shopt -s nullglob
    if [ -z "$(ls -A ${NOTES_LOCATION})" ]; then
        log INFO "Folder empty" "You don't have any notes! Use the create option to create a new note"
    else
        echo -e ${GREEN}"Untagged Notes/"${RESETC}
        for file in ${NOTES_LOCATION}/*${DEFAULT_EXTENSION}; do
            local pure_filename1=${file/"$NOTES_LOCATION/"/""}    # remove the base dir path
            echo -e ${BLUE}"  ${pure_filename1}"${RESETC}
        done
        for dir in ${NOTES_LOCATION}/*/; do
            local pure_dirname=${dir/"$NOTES_LOCATION/"/""}
            echo -e ${GREEN}"$pure_dirname"${RESETC}
            for file in $dir*${DEFAULT_EXTENSION}; do
                local pure_filename2=${file/"$dir"/""}    # remove the base dir path
                echo -e ${BLUE}"  ${pure_filename2}"${RESETC}
            done
        done
    fi
    shopt -u nullglob
}

search() {
    echo
}

tag() {
    if [[ "${NOTES[*]}" == *"$(get_note_path $1)"* ]]; then
        if [[ "${TAGS[*]}" == *"$2"* ]]; then
            mv ${NOTES_LOCATION}/$(get_note_path $1) ${NOTES_LOCATION}/$2/ && log INFO "Note tagged" "Succesfully tagges $1 as $2"
        else
            mkdir ${NOTES_LOCATION}/$2
            TAGS+=("$2")
            mv ${NOTES_LOCATION}/$(get_note_path $1) ${NOTES_LOCATION}/$2/ && log INFO "Note tagged" "Succesfully tagges $1 as $2"
        fi
    else
        log ERROR "Unable to tag" "The given note doesn't exist"
    fi
}

untag() {
    if [[ "${NOTES[*]}" == *"$(get_note_path $1)"* ]]; then
        local note=${NOTES_LOCATION}/$(get_note_path $1)
        if [ ${note/"$1${DEFAULT_EXTENSION}"/""} != ${NOTES_LOCATION}/ ]; then
            mv "${NOTES_LOCATION}/$(get_note_path $1)" "${NOTES_LOCATION}/" && log INFO "Note untagged" "Succesfully untagged $1"
        fi
    else
        log ERROR "Unable to untag" "The given note doesn't exist"
    fi
}


case "$1" in
    h | help)
        help
        ;;
    c | create)
        create $2 $3
        ;;
    d | delete)
        delete $2
        ;;
    e | edit)
        edit $2
        ;;
    i | info)
        info $2
        ;;
    l | list)
        list
        ;;
    s | search)
        search $2
        ;;
    t | tag)
        tag $2 $3
        ;;
    u | untag)
        untag $2
        ;;
    *)
        log ERROR "BashNotes" "Option not found"
        ;;
esac
