#!/bin/bash

################################################################################
#          FILE:    del
#         USAGE:    del [OPTION] <FILENAME>...
#   DESCRIPTION:    This moves the file called <filename>
#                   (a full or relative pathname) to the dustbin directory.
#                   It use a text file to store the original location of the file.
#       OPTIONS:    -h, --help display the manuel of the file and exit
#                   -i, --interactive prompt before overwriting an exising file only
#       CREATED:    02/12/2010
################################################################################

# RECORD and TRASH assumed to be environnment variables
# initialised in the 'init.sh' script
# otherwise hard-coded here
#declare -r RECORD="${HOME}/my-applications/.trashrec"   #record file location
#declare -r TRASH="${HOME}/.Trash"   #location of the trash

#number of files deleted
nbdel=0  



function display_help (){
#print the "man page"
echo -e '\033[1mNAME\033[0m
\r\tdel - move a file to the dustbin
\n\r\033[1mSYNOPSIS\033[0m
\r\t\033[1mdelete\033[0m [\033[4mOPTION\033[0m] <\033[4mFILENAME\033[0m>...
\n\r\033[1mDESCRIPTION\033[0m
\r\tMoves <filename> (a full or relative pathname) to the dustbin directory. Its original location is stored to allow it to be restored later.
\n\r\033[1mOPTION\033[0m
\r\t -i, --interractive
\r\t\t prompt before overwriting an existing file only
\n\r\033[1mSEE ALSO\033[0m
\r\ttrash, restore, rm'
exit 0
}



function clean_record_file () {
##arrange the record file
#sort the file alphabeticaly and eliminate duplicate lines
sort -u -o "${RECORD}" "${RECORD}"
#delete empty lines
sed -i '/^$/ {d;q}' "${RECORD}"
return 0
}


function init () {
##test if there is an argument
if [ ${#} -eq 0 ] ; then
    ##if no parameter, print error message
    echo "$(basename ${0}): missing or invalid file operand" >&2
    display_help
    exit 1 # ends the script
fi
clean_record_file    #arrange the record file
return 0
}

init "${@}" #initialize options and check parameters
while [ ${#} -ne 0 ] ; do    #while there is remaining arguments
    case "${1}" in  #process options
        -h|--help)  #Print a "man page" of the script
            display_help
            ;;
        -i|--interactive)   #Prompt the user if any conflict in files
            F_I='-i'    #set a flag
            ;;
        *)  #An unknown argument
            if [ ! -f "${1}" ] || [ ! -w "${1}" ] ; then
                ##not existing file, or non-modifiable
                #print error message
                echo "$(basename ${0}): ${1}: not a valid file (check rights?)" >&2 
            else
                ##existing file, process
                apath=$(readlink -f "${1}") #find the absolute pathname
                bname=$(basename "${1}")    #find the filename only
                if [ "${F_I}" = "-i" ] && [ -f "${TRASH}/${bname}" ]; then
                    ##if the interractive option was set
                    ##and there is a file with the same name in the bin
                    #prompt the user
                    read -p "$(basename ${0}): overwrite \`${TRASH}/${bname}\'? [y/N]"
                    #if answer is not yes, process next argument
                    [ ! "${REPLY:0:1}" = "y" ] && shift && continue                     
                fi
                mv "${apath}" "${TRASH}"    #Move the file to the trash
                ((nbdel++)) #increment the number of files deleted
                #delete previous record with the same name
                sed -i -r '/'"${bname}"'$/ {d}' "${RECORD}"
                #append the original location into a record
                echo "${apath}" >> "${RECORD}"
            fi
            ;;
    esac
shift   #process next argument
done
## if some files changed, arrange the record file
[ ${nbdel} -gt 0 ] && clean_record_file
exit 0  #success, exit the script


