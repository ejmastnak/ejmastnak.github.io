W="1670"
H="410"
X="175"
Y="135"

# X Window system geometry of the form WxH+X+Y
geometry=`head -1 "../_geometry.txt"`

# Example: geometry="1080x720+100+50"
WxH=${geometry%%+*} # e.g. 1080x720
X=${geometry#*+}    # e.g. 100+50
X=${X%%+*}          # e.g. 100
Y=${geometry##*+}   # e.g. 50
# echo "WxH: ${WxH}"
# echo "X: ${X}"
# echo "Y: ${Y}"

output="../../../../../assets/images/vim-latex/show-off/_test.mp4"
countdown=2
fps=20

sleep ${countdown}
ffmpeg -video_size ${WxH} -framerate ${fps} -f x11grab -i :0.0+${X},${Y} ${output}
