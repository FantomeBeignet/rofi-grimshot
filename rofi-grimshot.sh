#!/usr/bin/env bash

# Current Theme
theme='grimshot'

active="Active window"
screen="All visible outputs"
output="Currently active output"
area="Select an area"
window="Select a window"

copy="Copy to clipboard"
save="Save file"

tmp_filename="/tmp/screenshot_$(date +%d)-$(date +%m)-$(date +%y)_$(date +%T).png"

# Function taken directly from grimshot
# https://github.com/swaywm/sway/blob/master/contrib/grimshot
target_directory() {
  test -f "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" && \
    . "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"

  echo "${XDG_SCREENSHOTS_DIR:-${XDG_PICTURES_DIR:-$HOME}}"
}

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-mesg "Screenshot" \
		-theme ${theme}.rasi
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$active\n$screen\n$output\n$area\n$window" | rofi_cmd
}

# Mode selection
mode_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 1; lines: 2;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-mesg 'Screenshot taken' \
		-theme ${theme}.rasi
}

# Ask to select mode
select_mode() {
	echo -e "$copy\n$save" | mode_cmd
}

menu_option="$(run_rofi)"
if [[ ! -z "$menu_option" ]]
then
	case $menu_option in 
		$active)
		grimshot save active $tmp_filename > /dev/null 2>&1
			;;
		$screen)
		grimshot save screen $tmp_filename > /dev/null 2>&1
			;;
		$output)
		grimshot save output $tmp_filename > /dev/null 2>&1
			;;
		$area)
		grimshot save area $tmp_filename > /dev/null 2>&1
			;;
		$window)
		grimshot save window $tmp_filename > /dev/null 2>&1
			;;
	esac
	mode="$(select_mode)"
	if [[ ! -z "$mode" ]]
	then
		case $mode in
			$copy)
			wl-copy --type image/png < $tmp_filename
				;;
			$save)
			cp $tmp_filename $(target_directory)
				;;
		esac
	fi
	rm $tmp_filename
fi
