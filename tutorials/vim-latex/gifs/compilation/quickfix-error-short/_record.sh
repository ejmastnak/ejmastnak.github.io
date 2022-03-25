geometry=`head -1 "geometry.txt"`
output="../../../../../assets/images/vim-latex/compilation/_quickfix-error-short.gif"
countdown=1
fps=10

menyoki record --countdown ${countdown} --root --size "${geometry}" gif --fps ${fps} --gifski save "${output}"
