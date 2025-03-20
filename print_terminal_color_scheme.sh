#!/bin/bash

# Color names and their ANSI codes
colors=("Black" "Red" "Green" "Yellow" "Blue" "Magenta" "Cyan" "White")
bg_codes=("40" "41" "42" "43" "44" "45" "46" "47")
bright_bg_codes=("100" "101" "102" "103" "104" "105" "106" "107")

# Function that works for terminals supporting OSC 4 color query
get_color_hex() {
    local color_index=$1
    local result
    
    # Use stty to save/restore terminal settings
    saved_stty=$(stty -g)
    stty raw -echo min 0 time 0
    
    # Query the color
    printf "\033]4;%s;?\033\\" "$color_index" > /dev/tty
    read -r result < /dev/tty
    
    # Restore terminal settings
    stty "$saved_stty"
    
    # Parse the color response
    if [[ $result =~ rgb:([0-9a-fA-F]+)/([0-9a-fA-F]+)/([0-9a-fA-F]+) ]]; then
        # Extract and standardize hex values
        r=$(printf "%02s" "${BASH_REMATCH[1]}" | tr ' ' '0')
        g=$(printf "%02s" "${BASH_REMATCH[2]}" | tr ' ' '0')
        b=$(printf "%02s" "${BASH_REMATCH[3]}" | tr ' ' '0')
        echo "#${r}${g}${b}"
    else
        # Fallback values based on standard xterm colors
        local fallbacks=(
            "#000000" "#CD0000" "#00CD00" "#CDCD00" 
            "#0000EE" "#CD00CD" "#00CDCD" "#E5E5E5"
            "#7F7F7F" "#FF0000" "#00FF00" "#FFFF00" 
            "#5C5CFF" "#FF00FF" "#00FFFF" "#FFFFFF"
        )
        echo "${fallbacks[$color_index]}"
    fi
}

# Function to print color blocks with hex codes
print_color_blocks() {
    printf "%-10s %-9s %-10s\n" "ANSI" "Standard" "Bright"
    
    for i in "${!colors[@]}"; do
        local color_name="${colors[i]}"
        local code="${bg_codes[i]}"
        local bright_code="${bright_bg_codes[i]}"
        local hex=$(get_color_hex "$i")
        local br_hex=$(get_color_hex "$((i+8))")
        
        printf "%-10s \e[%sm%s\e[0m \e[%sm%s\e[0m\n" \
            "$color_name" "$code" " $hex " "$bright_code" " $br_hex "
    done
}

# Print background colors
print_color_blocks
