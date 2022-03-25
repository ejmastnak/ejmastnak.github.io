lines=1
geometry=`sh "../../resources/geometry.sh" ${lines}`
output="../../../../../assets/images/vim-latex/ultisnips/_visual-placeholder.gif"
countdown=1
fps=10

menyoki record --countdown ${countdown} --root --size "${geometry}" gif --fps ${fps} --gifski save "${output}"
