#!/bin/bash
# simple shell script to automate copying master version
# from by local computer to the site directory

PAPER_SOURCE_PATH="${HOME}/Documents/Media/academics/fmf/fmf-media-3/seminar/paper/paper.pdf"
PAPER_TARGET_PATH="paper.pdf"

SLIDES_SOURCE_PATH="${HOME}/Documents/Media/academics/fmf/fmf-media-3/seminar/presentation/presentation.pdf"
SLIDES_TARGET_PATH="presentation.pdf"

SLIDES_SLO_SOURCE_PATH="${HOME}/Documents/Media/academics/fmf/fmf-media-3/seminar/presentation-slo/presentation-slo.pdf"
SLIDES_SLO_TARGET_PATH="presentation-slo.pdf"

cp "${PAPER_SOURCE_PATH}" "${PAPER_TARGET_PATH}"
cp "${SLIDES_SOURCE_PATH}" "${SLIDES_TARGET_PATH}"
cp "${SLIDES_SLO_SOURCE_PATH}" "${SLIDES_SLO_TARGET_PATH}"
