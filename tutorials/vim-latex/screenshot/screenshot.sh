#!/bin/sh
# Used to take easily-replicated screenshots of PDF files
# in the scope of the Vim-LaTex tutorial series.
# Argument $1 

if [ $# -eq 1 ]
then
  filename="${1}"
else
  filename="capture.png"
fi

output_file="../../../assets/images/vim-latex/screenshots/${filename}"
menyoki capture -m save "${output_file}"
