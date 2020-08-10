#!/bin/bash
#
# Author: Kien Truong
#
# A tiny tidy backup shell script takes the following options: -n (dry run), -r
# (remote backup), -c (number of backups to retain), -v (printing out every files
# that is being backed up), and -h (prints out usage message). This program will
# create a bzipped tar archive and save it to the destination directory given the
# source directory. The tar archive should have structured filename where the date
# is prefixed to the source directory's name and suffixed with `.tar.bz2`. Once
# the operation has completed, an SHA-256 checksum is calculated using the created
# tar archive and the sha256 command. The checksum is printed to standard out
# and appended to a file called SHA256SUMS which is in the destination directory.
#

function usage () {
  echo "Usage:"
  echo "  ${1} parameter1 parameter2 parameter3 .."
  echo
  echo "  This shell script needs three parameters to backup your file"
  echo "  The first parameter is for your options"
  echo "  The second parameter is your source file"
  echo "  The third parameter is where the file will be backed up"
}

#
# Main
#
SCRIPTNAME=`basename ${0}`

if [ ${#} -lt 1 ]; then
  usage ${SCRIPTNAME}
fi

ARGS=`getopt nr:c:vh $*`

if [ $? -ne 0 ]; then
  echo "Please enter n, r, c, v, or h"
  exit 2
fi

TIME=`date +%Y-%m-%d-%H-%M`

set -- $ARGS

VERBOSE="false"
COPY="false"
HELP="false"
DRYRUN="false"
REMOTEBACKUP="false"

while :; do
  case "$1" in
    -v)
        VERBOSE="true"
        shift
        ;;
    -c)
        COPY="true"
        NUMBACKUPS=${2}
        shift; shift
        ;;
    -h)
        usage ${SCRIPTNAME}
        shift
        exit 1
        ;;
    -n)
        DRYRUN="true"
        shift
        ;;
    -r)
        REMOTEBACKUP="true"
        BACKUPADD=${2}
        shift; shift
        ;;
    --)
        shift; break
        ;;
  esac
done

FNAME=`basename ${1}`
echo "Back up time: ${TIME}"

    if [ ${DRYRUN} = "true" ]; then
      ALLFILES=`ls -1 ${1}`
      echo "All files: ${ALLFILES}"
      echo "The file would go to: ${2}"
      echo "The name of the archive file is: ${TIME}-${FNAME}.tar.bz2"
      exit 1
    fi

    if [ ${REMOTEBACKUP} = "true" ]; then
      tar cvjf - ${1} | ssh ${BACKUPADD} dd of=${TIME}-${FNAME}.tar.bz2
      # tar cvjf - ${1} | ssh ${BACKUPADD} split -b 1024 - ${2}/${TIME}-${FNAME}.tar.bz2
    fi

    if [ ${VERBOSE} = "true" ]; then
      tar cvjf ${2}/${TIME}-${FNAME}.tar.bz2 ${1}
      sha256sum ${2}/${TIME}-${FNAME}.tar.bz2 >> ${2}/SHA256SUMS
    else
      tar cjf ${2}/${TIME}-${FNAME}.tar.bz2 ${1}
      sha256sum ${2}/${TIME}-${FNAME}.tar.bz2 >> ${2}/SHA256SUMS
    fi

    if [ ${COPY} = "true" ]; then
      N=`ls -1 ${2}/*${FNAME}.tar.bz2 | wc -l`

      if [ ${N} -gt ${NUMBACKUPS} ]; then
        NDEL=$(( ${N} - ${NUMBACKUPS} ))
        FILETODEL=`ls -1 ${2}/*${FNAME}.tar.bz2 | head -${NDEL}`

        for FILE in ${FILETODEL}; do
          rm -rf ${FILE}
        done

        if [ ${NDEL} -eq 1 ]; then
          sed -i 1d ${2}/SHA256SUMS
        else
          sed -i 1,${NDEL}d ${2}/SHA256SUMS
        fi

      fi
    fi

  echo "End backup time: ${TIME}"
