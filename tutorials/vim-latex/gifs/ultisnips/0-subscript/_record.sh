lines=5
geometry=`sh "../../resources/geometry.sh" ${lines}`
output="../../../../../assets/images/vim-latex/ultisnips/_0-subscript.gif"
countdown=1
fps=10

menyoki record --countdown ${countdown} --root --size "${geometry}" gif --fps ${fps} --gifski save "${output}"
