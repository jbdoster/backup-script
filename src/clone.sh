###########
#CONSTANTS#
###########
RSYNC_SOURCE_PATH=$1
RSYNC_DESTINATION_PATH=$2
LOG_PATH=/tmp/clone/log.out
ZIP_PATH=/tmp/clone/env.zip

###########
#FUNCTIONS#
###########
: '
@function _new_line
@param $1 {int} number of new lines to print
'
function _new_line {
    for i in {1...$1}; do echo ''; done
} 2>&1

: '
@function _stamp
@param $1 {buffer} filename
'
function _stamp {
    filename=resources/log_stamps/$1.txt
    while read line; do
    echo "  $line"
    done < $filename
} 2>&1

: '
@function Clean
'
function Clean {
    echo "Cleaning previous clones, then logging to /tmp/clone/log.out from here on out.."
    sudo rm -rf $RSYNC_DESTINATION_PATH
    mkdir $RSYNC_DESTINATION_PATH
    touch $LOG_PATH
} 2>&1

: '
@function Clone
'
function Clone {
    _stamp $STAMP_CLONING
    sudo rsync -azh --progress --stats --exclude '.*' --exclude 'Android*' --exclude '*.iso' --exclude '*.deb' --exclude 'repo*' --include ".bashrc" --include ".bash_profile" $RSYNC_SOURCE_PATH $RSYNC_DESTINATION_PATH
} 2>&1

: '
@function Complete
'
function Complete {
    echo "DISK USAGE"
    df -h
    _new_line 4

    echo "ZIP FILE STAT"
    stat $ZIP_PATH
    _new_line 4

    echo "CURRENT EXEC DIRECTORY"
    pwd
    _new_line 4
} 2>&1

: '
@function Compress
'
function Compress {
    _stamp $STAMP_COMPRESSING
    sudo zip -r $ZIP_PATH $RSYNC_DESTINATION_PATH
} 2>&1

: '
@function Init
'
function Init {
    echo "DISK USAGE"
    df -h
    _new_line 4

    echo "CURRENT EXEC DIRECTORY"
    pwd
    _new_line 4
} 2>&1

########
#RUNNER#
########

# Clean
_stamp cleaning
Clean

# Setup logging
exec 3>&1 42>&1
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1> $LOG_PATH 2>&1
_new_line 3

_stamp initialize
Init

# Clone
_stamp cloning
Clone

# Compress
_stamp compressing
Compress

# Complete
_stamp complete
Complete

exit 0