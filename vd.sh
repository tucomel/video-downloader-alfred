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
instagram_cookie="$CURRENT_DIR/cookies/instagram.com_cookies.txt"
facebook_cookie="$CURRENT_DIR/cookies/facebook.com_cookies.txt"
download_dir=~/youtube-dl/
output_format="$download_dir/%(title)s-%(id)s.%(ext)s"
ffmpeg_installed=$(program_exists "ffmpeg")
aria2c_installed=$(program_exists "aria2c")
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
mkdir -p $download_dir
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
    options="$options -f "bestvideo"$video_size""$video_format"+bestaudio"$audio_format"/best"$video_size""$video_format"
    if $aria2c_installed; then
        options="$options --external-downloader aria2c"
    fi
fi

if [[ $video_url == *"instagram"* ]]; then
    cookie=$instagram_cookie
else
    if [[ $video_url == *"facebook"* ]] || [[ $video_url == *"fb.watch"* ]]; then
        cookie=$facebook_cookie
    fi
fi

# if [[ $video_url == *"facebook"* ]]; then
#     cookie=$facebook_cookie
# fi

if [[ -e $cookie ]]; then
    options="$options --cookies "$cookie""
fi

#echo $"($yt $options "$video_url")"
yt_output="$($yt "$video_url" $options 2>&1)"
download_result=$?

if [ $download_result -eq 0 ]; then
    filepath="$("$yt" $options --get-filename "$video_url")"
    if ! [ -f "$filepath" ]; then
        filepath="$(remove_ext "$filepath").mkv";
    fi
    if [[ "$extract_audio" == true && "$ffmpeg_installed" == true ]]; then
        #filepath="$(remove_ext "$filepath").$audio_format";
        filepath="$(remove_ext "$filepath")."$audio_format"";
        #echo $filepath
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
