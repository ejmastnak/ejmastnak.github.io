geometry=`head -1 "_geometry.txt"`
output="../../../../../assets/images/vim-latex/pdf-reader/_forward-search.gif"
countdown=2
fps=10

menyoki record --countdown ${countdown} --root --size "${geometry}" gif --fps ${fps} --gifski save "${output}"
