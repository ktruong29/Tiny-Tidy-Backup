# Tiny Tidy Backup
---
The purpose of this program is to become familiar with using commands in shell
script. The goal is to create a script where a source directory is specified
and it is backed up to a destination directory as a tar archive. The script will
process command line options and have an option to write the backup to a remote
computer via ssh
---
The script should do the following:
The script shall accept a source directory, a destination directory, and
process any command line options.
The script understands the following options:
* -n Dry run: A dry run is where the script prints out what it would do, including
all the files it would backup, where the files will go, the name of the tar archive,
yet does not do any operations that would modify the file system.
* -r Remote backup: The destination is specified as an SSH style path. The path is
specified as ```user@remotehost:/fully/qualified/path```. The backup archive
shall be sent over the network and stored on the remote host.
* -c N the number of backups to store: this argument rakes an option, N, which is
the number of backups to retain
* -v Verbose mode: Make the script verbose by printing out every step that it does
and every file that is being backed up
* -h Help: print out a usage message

The script will print out a diagnostic message stating the start time of the backup
job, then take the contents of the source directory and create a bzipped tar
archive and save it to the destination directory. The tar archive shall have a
structured filename where the date is prefixed to the source directory's name
and suffixed with ```.tar.bz2```. Once that operation has completed, an SHA-256
checksum is calculated using the created tar archive and the sha256sum command.
The checksum is printed to standard out and appended to a file called SHA256SUMS,
which is in the destination directory. Finally, a diagnostic message is printed
stating the end time of the backup.

The script will retain N copies of the backup. For instance, if N is 2 and the source
directory is ```my-project``` and the backup script is run on a daily basis, there
will be 2 files in the destination directory that are named similar
to ```2020-01-17-17-30-my-project.tar.bz2```, ```2020-01-18-17-30-my-project.tar.bz2```.
A subsequent backup on the 19th would delete ```2020-01-17-17-30-my-project.tar.bz2```
and in its place ```2020-01-19-17-30-my-project.tar.bz2``` would exist.
Additionally, the checksum file SHA256SUMS is edited to only include the checksums
of the remaining backups.

The options are not mutually exclusive, which means that any of the above options
can be used in any combination with one another. Command line arguments can
easily be processed using the getopts command.

A remote backup should use the ssh command and the dd command or split command.
If the output of the backup shall be small enough to fit in a single file, dd is a good utility to use. If the backup files will be too large, then use split to create many smaller files which can be reassembled to restore the computer.

If the program is run without any parameters, it prints out a usage message indicating
the correct usage of the script.

## Prerequisites
---
* A virtual machine

## Instruction on how to run the program
---
1. chmod +x backup.sh then ./backup.sh
2. sh backup.sh
