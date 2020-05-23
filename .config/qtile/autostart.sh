#!/bin/bash

picom &
feh --bg-fill $HOME/.config/qtile/wallpapers/adapta.jpg &
redshift-gtk &
xbanish -i lock -i control -i mod1 -i mod4 &
