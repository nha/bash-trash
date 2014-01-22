#!/bin/bash

################################################################################
#          FILE:    trash
#         USAGE:    trash [OPTION]
#   DESCRIPTION:    This moves removes the content of the dustbin directory.
#                   Without options, it prints the filenames one by one
#                   and ask the user for confirmation.
#       OPTIONS:    -h, --help display the manuel of the file and exit
#                   -a, --all remove all the files from the dustbin without prompting
#                   to a directory nominated by the user
#       CREATED:    02/12/2010
################################################################################

# RECORD and TRASH assumed to be environnment variables
# initialised in the 'init.sh' script
# otherwise hard-coded here
#declare -r RECORD="${HOME}/my-applications/.trashrec"  #record file location
#declare -r TRASH="${HOME}/.Trash"  #location of the trash

function display_help (){
#print the "help page"
echo -e '\033[1mNAME\033[0m
\r\ttrash - empty the dustbin\n
\r\033[1mSYNOPSIS\033[0m
\r\t\033[1mtrash\033[0m [\033[4mOPTION\033[0m]
\n\r\033[1mDESCRIPTION\033[0m
\r\tRemove interractively the files from the dustbin\n
\r\t-a,--all
\r\t\t remove all the files from the dustbin without asking confirmation
\n\r\033[1mSEE ALSO\033[0m
\r\t del, restore, rm'
}

function clean_record_file () {
##arrange the record file
#eliminate duplicate and sort lines alphabeticaly
sort -u -o "${RECORD}" "${RECORD}"
sed -i '/^$/ {d;q}' "${RECORD}" #delete empty line
return 0
}

function init () {
##set filename patterns
##matching no strings to expand to a null string (nullglob)
##and include hidden files in results (dotglob)
oldShoptOptions=$(shopt -p) #backup shopt options
shopt -s nullglob dotglob   #change shell options
return 0
}

function quit () {
clean_record_file   #arrange record file
eval "$oldShoptOptions" 2> /dev/null    #restore shopt options
exit "${1}" #exit with the given parameter
return 0
}

init    #initialise some shell values
case "${1}" in
    -a|--all)   #Empty the trash without confirmation
        rm "${TRASH}"/* #delete files in the bin
        : > "${RECORD}" #empty the record file
        ;;
        
    "") #No parameter
        clean_record_file   #arrange record file
        cd "${TRASH}"
        for file in * ; do  #for each file in the dustbin
            #prompt the user
            read -p "definitely remove the file \"${file}\" [y\N]?" 
            #if yes, remove the file and update the record file
            [ "${REPLY:0:1}" = 'y' ] \
            && rm "${file}" \
            && sed -i -r '/'"${file}"'$/ {d;q}' "${RECORD}"
        done
        ;;
        
    -h|--help)  #Print a "man page" of the script
        display_help
        ;;

    *)  #An unknown argument
        echo -e "$(basename ${0}): missing or invalid file operand
        \r\tTry $(basename ${0}) --help"    >&2 #print an error message
        quit 1  #exit with error
        ;;
esac
quit 0
