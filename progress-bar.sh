#!/usr/bin/env bash

DEFAULT_WIDTH=200
DEFAULT_HEIGHT=20
DEFAULT_BACKGROUND_COLOR=white
DEFAULT_FOREGROUND_COLOR=gradient:orange-yellowgreen
DEFAULT_TEXT_COLOR=black
DEFAULT_PERCENTAGE=100

usage () {
	echo "Usage: progress-bar.sh [ -w | --width <WIDTH> ]
	                             [ -h | --height <HEIGHT> ]
	                             [ -f | --foreground | --foreground-color <COLOR> ]
	                             [ -b | --background | --background-color <COLOR> ]
	                             [ -t | --text | --text-color <COLOR> ]
	                             [ -p | --progress | --percent | --percentage <PERCENT> ]
	" >&2
	exit 1
}

parsedArguments=$(getopt -n progress-bar -o w:h:f:b:p:t: --long width:,height:,foreground:,foreground-color:,background:,background-color:,text:,text-color:,progress:,percent:,percentage: -- "$@")
validArguments=$?
if [ \! ${validArguments} ]; then
	usage
fi

eval set -- "${parsedArguments}"
while :
do
	case "$1" in
		"-w"|"-width")
			width="${2}"
			shift 2
			;;
		"-h"|"-height")
			height="${2}"
			shift 2
			;;
		"-f"|"--foreground"|"--foreground-color")
			foregroundColor="${2}"
			shift 2
			;;
		"-b"|"--background"|"--background-color")
			backgroundColor="${2}"
			shift 2
			;;
		"-t"|"--text"|"--text-color")
			textColor="${2}"
			shift 2
			;;
		"-p"|"--progress"|"--percent"|"--percentage")
			percentage="${2}"
			shift 2
			;;
		--)
			shift
			break
			;;
	esac
done
outputFile="${1}"

foregroundWidth=$(( ( ${width:-${DEFAULT_WIDTH}} * ${percentage:-${DEFAULT_PERCENTAGE}} / 100) - 1 ))
cornerSize=$(( ${height:-${DEFAULT_HEIGHT}} / 2 ))
backgroundBottomRight=$(( ${width:-${DEFAULT_WIDTH}} - 1 )),$(( ${height:-${DEFAULT_HEIGHT}} - 1 ))
foregroundBottomRight=${foregroundWidth},$(( ${height:-${DEFAULT_HEIGHT}} - 1 ))

magick \
	-define gradient:vector=0,0,${width:-${DEFAULT_WIDTH}},0 \
	-size ${width:-${DEFAULT_WIDTH}}x${height:-${DEFAULT_HEIGHT}} \
	xc:transparent \
	-fill ${backgroundColor:-${DEFAULT_BACKGROUND_COLOR}} \
	-draw "roundrectangle 0,0 ${backgroundBottomRight} ${cornerSize},${cornerSize}" \
	-fill ${foregroundColor:-${DEFAULT_FOREGROUND_COLOR}} \
	-draw "roundrectangle 0,0 ${foregroundBottomRight} ${cornerSize},${cornerSize}" \
	-gravity center \
	-pointsize ${height:-${DEFAULT_HEIGHT}} \
	-fill ${textColor:-${DEFAULT_TEXT_COLOR}} \
	-font "Liberation-Mono" \
	-weight Bold \
	-draw "text 0,0 '${percentage:-${DEFAULT_PERCENTAGE}}%'" \
	png:-
