#!/bin/sh
# Used to standardize the portion of the screen recorded across all GIFs
# Arguments: 
# $1 denotes the number of lines in the to-be-recorded text snippet.
#    Used to correctly size the recording area for screen capture.

# Sizes calibrated to 38 px font
if [ ${1} -le 1 ]
then
  H="320"
elif [ ${1} -le 4 ]
then
  H="420"
elif [ ${1} -le 6 ]
then
  H="515"
else
  H="595"
fi

# H="220"  # for two lines of text (large)
# H="320"  # for three lines of text (large)
# H="420"  # for four lines of text (large)
# H="515"  # for five lines of text (large)
# H="615"  # for six lines of text using (large)
# H="515"  # for six lines (medium)
# H="595"  # for seven lines (medium)

W="1670"
X="30"
Y="100"

geometry="${W}x${H}+${X}+${Y}"

echo ${geometry}
