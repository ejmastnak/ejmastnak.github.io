#!/bin/sh
# Goal: Concatenate padded clips into a single video
# for upload to YouTube

ffmpeg -f concat -safe 0 -i _concat-list.txt -c copy all.mp4
