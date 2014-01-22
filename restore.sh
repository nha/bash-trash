#!/bin/bash

################################################################################
#          FILE:    restore
#         USAGE:    restore [OPTION] <FILENAME>...
#   DESCRIPTION:    This moves the file called <filename>
#                   (a full or relative pathname) back to it`s original directory.
#       OPTIONS:   -h, --help display the manuel of the file and exit
#                  -n, --nominate move the file to a directory specified
#                   by the user instead of the original directory
#                   TODO and --interractive option
#       CREATED:    02/12/2010
################################################################################

# RECORD and TRASH assumed to be environnment variables
# initialised in the 'init.sh' script
# otherwise hard-coded here
#declare -r RECORD="${HOME}/my-applications/.trashrec"  #record file location
#declare -r TRASH="${HOME}/.Trash"  #location of the trash

nbres=0 #number of files restored

function display_help (){
#print the "help page"
echo -e '\033[1mNAME\033[0m
\r\trestore - restore file from dustbin\n
\r\033[1mSYNOPSIS\033[0m
\r\t\033[1mrestore\033[0m [\033[4mOPTION\033[0m] <\033[4mFILENAME\033[0m>...\n
\r\033[1mDESCRIPTION\033[0m
\r\tmove the called <filename> (a full or relative pathname), from the dust bin back to it`s original directory\n
\r\t-n,--nominate
\r\t\tspecify a different destination directory (full or relative pathname) to restore the file'
exit 0
}

function init () {
##test if there is an argument
if [ ${#} -eq 0 ] ; then
  ##if no parameter, print error message
  echo "$(basename ${0}): missing or invalid file operand" >&2
  display_help
  exit 1  #end script
fi
##set filename patterns
##matching no strings to expand to a null string (nullglob)
##and include hidden files in results (dotglob)
oldShoptOptions=$(shopt -p) #backup shopt options
shopt -s nullglob dotglob   #change shell options
return 0
}

function quit () {
#put the flags back to their default values
eval "$oldShoptOptions" #2> /dev/null   #restore shopt options
[ ${nbres} -eq 0 ] && echo "No such file in the trash"
exit "${1}" #exit with the given parameter
return 0
}

function clean_record_file () {
##arrange the record file
#eliminate duplicate and sort lines alphabeticaly
sort -u -o "${RECORD}" "${RECORD}"
sed -i '/^$/ {d:q}' "${RECORD}" #delete empty lines
return 0
}

init "${@}" #initialize options and check parameters
while [ ${#} -ne 0 ] ; do    #while there is remaining arguments
  case "${1}" in

    -n|--nominate)    #name the destination directory
      #verify that it`s a valide directory (right to write?)
      if [ -d "$(dirname "${2}")" ] ; then
        #convert it into an absolute pathname
        dest_dir=$(readlink -f "${2}")
        F_N="-n"    #set the flag
      else
        echo -e "the -n argument (destination directory) is not a valid path
        \r\tTry $(basename ${0}) --help" >&2
        quit 1
      fi
      shift    #shift one time for the argument of -n
      ;;

    -h|--help)    #display help and quit
      display_help
      quit 0
      ;;

    *)    #the filename?
      cd "${TRASH}"
      for afile in * ; do    #for each file in the dustbin
        #keep only the filename from the absolute path
        bfile=$(basename "${afile}")
        if [ "${bfile}" = "${1}" ] ; then
          ##if the file is found in the bin
          if [ ! "${F_N}" = '-n' ] ; then   
            ##if the user didn`t use -n
            #use recorded location
            dest_dir=$(sed -n '/'"$bfile"'$/ {p;q} ' "${RECORD}")
          fi
          #restore the file
          mv -b ""${TRASH}"/"${bfile}"" "${dest_dir}"
          ((nbres++)) #increment the number of files restored
          sed -i -r '/'"${bfile}"'$/ {d;q}' "${RECORD}"   #update the record file
          continue    #file restored,stop searching for it
        fi
      done
      ;;

  esac
  shift    #see the next argument
done     
quit 0



