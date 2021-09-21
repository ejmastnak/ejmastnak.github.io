#!/bin/bash
# simple shell script to automate copying
# master version of the CV from the local source
# directory on my computer to this site

CV_SOURCE_PATH="../../../cv/cv/cv.pdf"
CV_TARGET_PATH="cv.pdf"

cp "${CV_SOURCE_PATH}" "${CV_TARGET_PATH}" && echo "SUCCESS: copied ${CV_SOURCE_PATH} to ${CV_TARGET_PATH}"
