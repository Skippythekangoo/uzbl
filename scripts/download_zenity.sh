#!/bin/bash
#
# the original dget.sh script:
# (c) 2007 by Robert Manea
#
# bashtardized and heavily modded for uzbl:
# 2009 by pbrisbin
#
# modified for zenity
# 2009 by iosonofabio
#
# requires:
#   zenity
#   wget
#
###
# auto open the file post-download based on the file's extension
open() {
  case "$1" in
    *.pdf|*.ps|*.eps)                           evince "$1"    & ;;
    *.jpg|*.png|*.jpeg|*.png)                   gpicview "$1"    & ;;
    *.txt|*README*|*.pl|*.sh|*.py|*.hs)         gvim "$1"    & ;;
    *.mov|*.avi|*.mpeg|*.mpg|*.flv|*.wmv|*.mp4) vlc "$1"    & ;;
    *.zip|*.zipx)                               xarchiver "$1"    & ;;
    *.torrent)                                  deluge "$1"    & ;;
  esac
}
#
#
# these are passed in from uzbl
PID="$2"
XID="$3"
ACTUAL_URL="$6"
DOWN_URL="$8"
#
# get filename from the url and convert some hex codes
# i hate spaces in filenames so i'm switching them
# with underscores here, adjust the first s///g if
# you want to keep the spaces
FILE="$(basename $DOWN_URL | sed -r \
's/[_%]20/\_/g;s/[_%]22/\"/g;s/[_%]23/\#/g;s/[_%]24/\$/g;
s/[_%]25/\%/g;s/[_%]26/\&/g;s/[_%]28/\(/g;s/[_%]29/\)/g;
s/[_%]2C/\,/g;s/[_%]2D/\-/g;s/[_%]2E/\./g;s/[_%]2F/\//g;
s/[_%]3C/\</g;s/[_%]3D/\=/g;s/[_%]3E/\>/g;s/[_%]3F/\?/g;
s/[_%]40/\@/g;s/[_%]5B/\[/g;s/[_%]5C/\\/g;s/[_%]5D/\]/g;
s/[_%]5E/\^/g;s/[_%]5F/\_/g;s/[_%]60/\`/g;s/[_%]7B/\{/g;
s/[_%]7C/\|/g;s/[_%]7D/\}/g;s/[_%]7E/\~/g;s/[_%]2B/\+/g')"
#
# show zenity directory selection window to ask the user
# for the destination folder. Wait until the user answers
# for beginning download (this could be improved).
DIRFILE=$(zenity --file-selection --save --filename="$FILE" --confirm-overwrite)
# This command is used to download:
GET="wget --user-agent=Firefox --content-disposition --load-cookies=$XDG_DATA_HOME/uzbl/cookies.txt --referer=$ACTUAL_URL --output-document=$DIRFILE"
ZEN="zenity --progress --percentage=0 --title=Download dialog --text=Starting..."
# download
if [ "$DIRFILE" ];
then
 ( $GET "$DOWN_URL" 2>&1 | \
   sed -u 's/^[a-zA-Z\-].*//; s/.* \{1,2\}\([0-9]\{1,3\}\)%.*/\1\n#Downloading... \1%/; s/^20[0-9][0-9].*/#Done./' | \
   $ZEN; \
   open "$DIRFILE") &
fi
exit 0
