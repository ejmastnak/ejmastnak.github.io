#!/bin/bash
# Simple shell script to automate copying master version
# from by local computer to the site directory
REPORT_SOURCE_PATH="${HOME}/Documents/academics/telecomm/projects/hilbert-transformer/report/report.pdf"
REPORT_TARGET_PATH="report.pdf"
VIDEO_SOURCE_PATH="${HOME}/Documents/academics/telecomm/projects/hilbert-transformer/media/realtime-demo.mp4"
VIDEO_TARGET_PATH="../../assets/videos/hilbert/realtime-demo.mp4"

cp "${REPORT_SOURCE_PATH}" "${PAPER_TARGET_PATH}"
cp "${VIDEO_SOURCE_PATH}" "${VIDEO_TARGET_PATH}"
