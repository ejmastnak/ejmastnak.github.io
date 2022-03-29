#1/bin/sh
# Concatenates a few GIFs into one;
# goal is to create one demo GIF for the home page

gif1="gauss.gif"
gif2="fourier.gif"
gif3="sinc.gif"
gif4="expz.gif"

gifsicle --colors 256 ${gif1} \
  ${gif2} \
  ${gif3} \
  ${gif4} \
  > demo.gif 
