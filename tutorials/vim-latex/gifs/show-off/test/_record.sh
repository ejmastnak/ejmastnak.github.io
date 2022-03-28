geometry=`head -1 "../_geometry.txt"`
output="../../../../../assets/images/vim-latex/show-off/_test.gif"
countdown=2
fps=15

menyoki record --countdown ${countdown} --root --size "${geometry}" gif --fps ${fps} --gifski save "${output}"
