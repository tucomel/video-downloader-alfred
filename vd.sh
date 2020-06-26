#!/bin/bash
# Author: Onur Yildirim (onur@cutepilot.com)

# -------------------------------------
# CONSTANTS
# -------------------------------------

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# -------------------------------------
# IMPORTS
# -------------------------------------

# create if does not exist
touch ~/.bash_profile

source ~/.bash_profile
source "$CURRENT_DIR"/shelper.sh
source "$CURRENT_DIR"/workflowHandler.sh

# -------------------------------------
# VARIABLES
# -------------------------------------

yt="$CURRENT_DIR/bin/youtube-dl"
download_dir="~"
output_format="$download_dir/%(title)s.%(ext)s"
ffmpeg_installed=$(program_exists "ffmpeg")
#ffmpeg_installed=true
video_url="$1" # "{query}"
video_format="$2"
video_size="$3"
play=$(contains_str "$4" "-play")
extract_audio=$(contains_str "$5" "-audio")
options="-i -q -o "$output_format"" # --restrict-filenames
message=""
audio_format=""
# -------------------------------------
# PROGRAM ROUTINE
# -------------------------------------
#echo "format = $video_format size = $video_size"
if $extract_audio; then
    if $ffmpeg_installed; then
        audio_format="mp3"
        options="$options --extract-audio --embed-thumbnail --audio-format "$audio_format""
    else
        echo "Failed! Install ffmpeg for audio conversion."
        echo "Type \"vd-help\" for instructions."
        exit 1
    fi
else
    #if ! [ -z "$video_format" ]; then
    if ! [ $video_format -eq -1 ]; then
        video_format="[ext="$video_format"]"
        audio_format="[ext=m4a]"
        #echo "$video_format"
    else
        video_format=""
    fi
    if ! [ $video_size -eq -1 ]; then
        video_size="[height<="$video_size"]"
        #echo "$video_size"
        else
        video_size=""
    fi
    options="$options -f "bestvideo"$video_size""$video_format"+bestaudio"$audio_format"/best"$video_size""$video_format"" "
fi

#echo "$yt" $options "$video_url"
yt_output=$("$yt" $options "$video_url" 2>&1)
download_result=$?

if [ $download_result -eq 0 ]; then
    filepath="$("$yt" $options --get-filename "$video_url")"
        if ! [ -f "$filepath" ]; then
            filepath="$(remove_ext "$filepath").mkv";
        fi
    if $extract_audio && $ffmpeg_installed;
     then filepath="$(remove_ext "$filepath").$audio_format";
fi
    if $play; then
        sleep 2
        open "$filepath"
        echo "Now Playing: $filepath"
    else
        echo "$filepath"
        #echo "Download complete: $filepath"
    fi
else
    echo "Download failed -> $download_result"
    echo $yt_output
fi
