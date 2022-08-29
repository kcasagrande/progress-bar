#!/usr/bin/env bash

DEFAULT_WIDTH=200
DEFAULT_HEIGHT=20
DEFAULT_BACKGROUND_COLOR=gradient:gray-lightgray
DEFAULT_FOREGROUND_COLOR=gradient:orange-yellowgreen
DEFAULT_TEXT_COLOR=gray10
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
			argWidth="${2}"
			shift 2
			;;
		"-h"|"-height")
			argHeight="${2}"
			shift 2
			;;
		"-f"|"--foreground"|"--foreground-color")
			argForegroundColor="${2}"
			shift 2
			;;
		"-b"|"--background"|"--background-color")
			argBackgroundColor="${2}"
			shift 2
			;;
		"-t"|"--text"|"--text-color")
			argTextColor="${2}"
			shift 2
			;;
		"-p"|"--progress"|"--percent"|"--percentage")
			argPercentage="${2}"
			shift 2
			;;
		--)
			shift
			break
			;;
	esac
done
outputFile="${1}"

width=${argWidth:-${DEFAULT_WIDTH}}
height=${argHeight:-${DEFAULT_HEIGHT}}
foregroundColor=${argForegroundColor:-${DEFAULT_FOREGROUND_COLOR}}
backgroundColor=${argBackgroundColor:-${DEFAULT_BACKGROUND_COLOR}}
textColor=${argTextColor:-${DEFAULT_TEXT_COLOR}}
percentage=${argPercentage:-${DEFAULT_PERCENTAGE}}

cornerSize=$(( ${height} / 2 ))
bottom=$(( ${height} - 1 ))
right=$(( ${width} - 1 ))
foregroundRight=$(( ( ${width} * ${percentage} / 100) - 1 ))
backgroundBottomRight=${right},${bottom}
foregroundBottomRight=${foregroundRight},${bottom}

magick \
	-size ${width}x${height} \
	xc:transparent \
	\( \
		xc:transparent \
		-fill ${backgroundColor} \
		-draw "roundrectangle 0,0 ${right},${bottom} ${cornerSize},${cornerSize}" \
	\) \
	-composite \
	\( \
		xc:transparent \
		-define gradient:vector=0,0,${width},0 \
		-fill ${foregroundColor} \
		-draw "roundrectangle 0,0 ${foregroundRight},${bottom} ${cornerSize},${cornerSize}" \
	\) \
	-composite \
	\( \
		xc:transparent \
		-define gradient:vector=0,0,0,${height} \
		-fill gradient:white-transparent \
		-draw "roundrectangle 0,0 ${foregroundRight},${bottom} ${cornerSize},${cornerSize}" \
	\) \
	-composite \
	\( \
		xc:transparent \
		-gravity center \
		-pointsize ${height} \
		-fill ${textColor} \
		-font "Liberation-Sans" \
		-draw "text 0,0 '${percentage}%'" \
	\) \
	-composite \
	png:-
