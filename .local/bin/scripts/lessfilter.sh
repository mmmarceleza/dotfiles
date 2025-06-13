#! /usr/bin/env bash

has_cmd() { command -v "$1" >/dev/null 2>&1 ; }

MIME="$(file -bL --mime-type "$1")"
CATEGORY="${MIME%%/*}"
# KIND="${MIME##*/}"

if [[ -d "$1" ]]; then
    has_cmd exa && exa -a --color=always -l -g --git --group-directories-first --icons "$1"
    has_cmd lsd && lsd -al --color=always --icon=always "$1"
elif [[ "$CATEGORY" == "image" ]]; then
  fzf-preview.sh "$1"
    # has_cmd chafa && chafa "$1"
    # has_cmd exiftool && exiftool "$1"
elif [[ "$CATEGORY" == "text" ]]; then
    has_cmd bat && bat --color=always --line-range :200 "$1"
elif [[ "$CATEGORY" == "video" ]]; then
    has_cmd mediainfo && mediainfo "$1"
else
    lesspipe.sh "$1" | bat --color=always --line-range :200
fi


# #! /usr/bin/env sh
# # this is a example of .lessfilter, you can change it
# mime=$(file -bL --mime-type "$1")
# category=${mime%%/*}
# kind=${mime##*/}
# if [ -d "$1" ]; then
# 	eza --git -hl --color=always --icons "$1"
# elif [ "$category" = image ]; then
# 	chafa "$1"
# 	exiftool "$1"
# elif [ "$kind" = vnd.openxmlformats-officedocument.spreadsheetml.sheet ] || \
# 	[ "$kind" = vnd.ms-excel ]; then
# 	in2csv "$1" | xsv table | bat -ltsv --color=always
# elif [ "$category" = text ]; then
# 	bat --color=always "$1"
# else
# 	lesspipe.sh "$1" | bat --color=always
# fi
# # lesspipe.sh don't use eza, bat and chafa, it use ls and exiftool. so we create a lessfilter.
