geometry=`sh _geometry.sh`
output="record.gif"
countdown=1
fps=10

menyoki record --countdown ${countdown} --root --size "${geometry}" gif --fps ${fps} --gifski save "${output}"
