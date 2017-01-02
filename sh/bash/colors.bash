#!/usr/bin/env bash

# The extra escape characters - `\[` and `\]` - are used to tell bash they are non-printing.
# This helps to render the prompt correctly and prevent improper wrapping behavior.

# reset
Color_Off='\[\033[0m\]'       # remove all colors

# regular colors
Black='\[\033[0;30m\]'        # Black
Red='\[\033[0;31m\]'          # Red
Green='\[\033[0;32m\]'        # Green
Yellow='\[\033[0;33m\]'       # Yellow
Blue='\[\033[0;34m\]'         # Blue
Magenta='\[\033[0;35m\]'      # Magenta
Cyan='\[\033[0;36m\]'         # Cyan
White='\[\033[0;37m\]'        # White

# bold
BBlack='\[\033[1;30m\]'       # Black
BRed='\[\033[1;31m\]'         # Red
BGreen='\[\033[1;32m\]'       # Green
BYellow='\[\033[1;33m\]'      # Yellow
BBlue='\[\033[1;34m\]'        # Blue
BMagenta='\[\033[1;35m\]'     # Magenta
BCyan='\[\033[1;36m\]'        # Cyan
BWhite='\[\033[1;37m\]'       # White

# underline
UBlack='\[\033[4;30m\]'       # Black
URed='\[\033[4;31m\]'         # Red
UGreen='\[\033[4;32m\]'       # Green
UYellow='\[\033[4;33m\]'      # Yellow
UBlue='\[\033[4;34m\]'        # Blue
UMagenta='\[\033[4;35m\]'     # Magenta
UCyan='\[\033[4;36m\]'        # Cyan
UWhite='\[\033[4;37m\]'       # White

# background
On_Black='\[\033[40m\]'       # Black
On_Red='\[\033[41m\]'         # Red
On_Green='\[\033[42m\]'       # Green
On_Yellow='\[\033[43m\]'      # Yellow
On_Blue='\[\033[44m\]'        # Blue
On_Magenta='\[\033[45m\]'     # Magenta
On_Cyan='\[\033[46m\]'        # Cyan
On_White='\[\033[47m\]'       # White

# high intensity
IBlack='\[\033[0;90m\]'       # Black
IRed='\[\033[0;91m\]'         # Red
IGreen='\[\033[0;92m\]'       # Green
IYellow='\[\033[0;93m\]'      # Yellow
IBlue='\[\033[0;94m\]'        # Blue
IMagenta='\[\033[0;95m\]'     # Magenta
ICyan='\[\033[0;96m\]'        # Cyan
IWhite='\[\033[0;97m\]'       # White

# bold high intensity
BIBlack='\[\033[1;90m\]'      # Black
BIRed='\[\033[1;91m\]'        # Red
BIGreen='\[\033[1;92m\]'      # Green
BIYellow='\[\033[1;93m\]'     # Yellow
BIBlue='\[\033[1;94m\]'       # Blue
BIMagenta='\[\033[1;95m\]'    # Magenta
BICyan='\[\033[1;96m\]'       # Cyan
BIWhite='\[\033[1;97m\]'      # White

# high intensity background
On_IBlack='\[\033[0;100m\]'   # Black
On_IRed='\[\033[0;101m\]'     # Red
On_IGreen='\[\033[0;102m\]'   # Green
On_IYellow='\[\033[0;103m\]'  # Yellow
On_IBlue='\[\033[0;104m\]'    # Blue
On_IMagenta='\[\033[0;105m\]' # Magenta
On_ICyan='\[\033[0;106m\]'    # Cyan
On_IWhite='\[\033[0;107m\]'   # White
