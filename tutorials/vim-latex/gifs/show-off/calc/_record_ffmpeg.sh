# X Window system geometry of the form WxH+X+Y
geometry=`head -1 "../_geometry.txt"`

# Example: geometry="1080x720+100+50"
WxH=${geometry%%+*} # e.g. 1080x720
X=${geometry#*+}    # e.g. 100+50
X=${X%%+*}          # e.g. 100
Y=${geometry##*+}   # e.g. 50

output="../../../../../assets/images/vim-latex/show-off/_calc.mp4"
countdown=3
fps=20

sleep ${countdown}
ffmpeg -y -video_size ${WxH} -framerate ${fps} -f x11grab -i :0.0+${X},${Y} ${output}
