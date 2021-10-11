## Video Downloader Alfred (Workflow) ##
Updated Version of Video Downloader (workflow)
Version 1.1 (2021-02-25)

Video Downloader Alfred is an **[Alfred](http://www.alfredapp.com)** workflow written in Bash/Shell for easily downloading videos (and/or extracting audio) from various websites such as YouTube, Vimeo, DailyMotion and more... It uses [youtube-dl](http://rg3.github.io/youtube-dl) as the core component.

## Installation ##
Download and double click [video-downloader-alfred.alfredworkflow](video-downloader-alfred.alfredworkflow). It will be imported into Alfred automatically.

Here is a full visual list of what Video Downloader Alfred can do:

![video-downloader-alfred.png](video-downloader-alfred.png "video-downloader-alfred")

Here is how the workflow nodes look like:

![video-downloader-alfred-workflow.png](video-downloader-alfred-workflow.png "video-downloader-alfred-workflow")

## Usage ##
* `vd-update` will automatically check and update the core component. Run this first when you import the workflow.
* `vd {video-url}` without any option will download the best video+audio option from URL merge then and save the video file to your home folder "\~".
* `vd {video-extension} and/or {video-compression} {video-url}` with this option you can choose compression size and extension (any or both) .

![video-downloader-alfred.gif](video-downloader-alfred.gif "video-downloader-alfred.gif")

* `vd {video-url} hold ⌘` will download the video file, then automatically extract and create an audio file. (.mp3) (The original video file is deleted at the end)

* `vd {video-url} hold ⌥` will download the video file, then automatic try to play with your default player (VLC, IINA or QT)

![video-downloader-alfred-info](video-downloader-alfred-info.gif "video-downloader-alfred-info")

* `vd-info {video-url}` will display some video meta-data in Large Type and create an *.info.json* file.
* `vd-help` will display a quick help in Large Type.

### Instagram (private or public photos/videos including Reels and IGTV) (optional) ###
#### Nexts steps is only necessarily for private contents download ####
1. Log-in to your instagram account and use [GetCookies](https://chrome.google.com/webstore/detail/get-cookiestxt/bgaddhkoddajcdgocldbbfleckgcbcid/) extension to save your cookie file.
1. Put the file inside "$plugin_folder/cookies" (like image below) using the **exacly** name **"instagram.com_cookies.txt"** (do not worry, **I will not have access to this file**, he will be used by **youtube-dl** at *--cookies* parameter)

![video-downloader-cookies.png](video-downloader-cookies.png "video-downloader-cookies")

### Audio Extraction (optional) ###
For this feature, you should install FFmpeg yourself manually (because of licensing issues).

One way to install FFmpeg is:

1. Install [HomeBrew](https://brew.sh)
2. Install FFmpeg by running the command below in Terminal:

```shell
    $ brew install ffmpeg
```

You can check [THIS GIST](https://gist.github.com/Piasy/b5dfd5c048eb69d1b91719988c0325d8) options to enable support for various codecs and FFmpeg features:

### aria2c Downloader (optional but strongly recommended) ###
aria2c is a lightweight library for best use of your network (parallels requests), fixing the problem of very slow downloads (dash playback)
1. Install [aria2c](https://github.com/aria2/aria2)

```shell
    brew install aria2 (macx86)
```

### Notes ###
* Videos, audio and meta-data files will be downloaded/created on your folder "\~".
* This workflow will display post notifications where appropriate (before/after downloads, on download errors, updates, etc)...

## Supported Sites ##
    • YouTube
    • Instagram (private profiles need "cookie file".txt)
    • Vimeo
    • Dailymotion
    • Twitch
    • MetaCafe
    • Google Video
    • MTV
    • Soundcloud
    • Photobucket Videos
    • DepositFiles
    • blip.tv
    • myvideo.de
    • Google Plus
    • The Daily Show / Colbert Nation
    • The Escapist
    • CollegeHumor
    • arte.tv
    • xvideos
    • infoq
    • mixcloud
    • Stanford Open Content
    • Youku
    • XNXX
    • more...
 list [here](http://rg3.github.io/youtube-dl/documentation.html).

## Requirements ##
* [Python](http://www.python.org) version 2.6, 2.7, or 3.3+
* [FFmpeg](http://www.ffmpeg.org) (optional, required for audio extraction feature)
* [GetCookies](https://chrome.google.com/webstore/detail/get-cookiestxt/bgaddhkoddajcdgocldbbfleckgcbcid/) (optional, required for private instagram profiles for example)
* [aria2c](https://github.com/aria2/aria2) (optional, recommended for fast download when downloading dash playback content)

## License ##
**Video Downloader Alfred** workflow is released to the public domain. (Do whatever you like with it.)
*FFmpeg is a trademark of Fabrice Bellard and it is licensed under LGPL version 2.1
http://www.ffmpeg.org/legal.html*
