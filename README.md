# ffmpeg-video-joiner-script

## Description:
Batch file to search and join video segments into a single video. Developed for **itleague.kharkov.ua** needs.

## How it works
The script uses a source path as a starting point. It goes through folders inside the source path, searches all video files inside that folders, sets them in time order, join them into single video (each folder - separate video) and save the result into an output folder.

## Dependencies:
ffmpeg - https://ffmpeg.org/download.html

Download the library, unpack it whereever you want and add the path to the `ffmpeg/bin` directory to the **PATH** variable.

## Using:
`ffmpeg-video-joiner path/to/source/folder` - use passed path as a source

`ffmpeg-video-joiner .` - (dot in the end) use current folder as a source
