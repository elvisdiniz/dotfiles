#!/usr/bin/env sh
has_cmd() {
	for opt in "$@"; do
		if command -v "$opt" >/dev/null; then
			continue
		else
			return $?
		fi
	done
}

display_image() {
	img_file="$1"

	if [ ! -f "$img_file" ]; then
		echo "File not found: $img_file" >&2
		return 1
	fi

	# iTerm2
	if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
		img_base64=$(base64 <"$img_file")
		printf '\033]1337;File=name=%s;inline=1:%s\a\n' \
			"$(basename "$img_file" | base64)" "$img_base64"

	# Kitty
	elif [ -n "$KITTY_WINDOW_ID" ]; then
		if command -v kitty >/dev/null; then
			kitty +kitten icat "$img_file"
		else
			echo "Kitty is not installed, cannot display image." >&2
			return 1
		fi

	# WezTerm (uses the same protocol as Kitty in practice)
	elif [ "$TERM_PROGRAM" = "WezTerm" ]; then
		if command -v wezterm >/dev/null; then
			wezterm imgcat "$img_file"
		elif command -v kitty >/dev/null; then
			kitty +kitten icat "$img_file"
		else
			echo "WezTerm or Kitty not found." >&2
			return 1
		fi

	# Sixel-capable terminals
	elif infocmp | grep -q 'sixel'; then
		if command -v img2sixel >/dev/null; then
			img2sixel "$img_file"
		else
			echo "img2sixel not installed." >&2
			return 1
		fi
	# Chafa for terminals that support it
	elif has_cmd chafa; then
		chafa -f symbols "$1"
	else
		echo "This terminal does not support image rendering." >&2
		return 1
	fi
}

mime=$(file -Lbs --mime-type "$1")
category=${mime%%/*}
kind=${mime##*/}
ext=${1##*.}
if [ "$kind" = octet-stream ]; then
	if [[ $1 == *events.out.tfevents.* ]]; then
		python <<EOF
from contextlib import suppress
import sys
from time import gmtime, strftime

import pandas as pd
import plotext as plt
from tensorboard.backend.event_processing.event_file_loader import (
    EventFileLoader,
)

file = "$1"
df = pd.DataFrame(columns=["Step", "Value"])
df.index.name = "YYYY-mm-dd HH:MM:SS"

for event in EventFileLoader(file).Load():
    with suppress(IndexError):
        df.loc[strftime("%F %H:%M:%S", gmtime(event.wall_time))] = [  # type: ignore
            event.step,  # type: ignore
            event.summary.value[0].tensor.float_val[0],  # type: ignore
        ]
df.index = pd.to_datetime(df.index)  # type: ignore
df.Step = df.Step.astype(int)
plt.plot(df.Step, df.Value, marker="braille")
plt.title(event.summary.value[0].metadata.display_name)  # type: ignore
plt.clc()
plt.show()
df.to_csv(sys.stdout, "\t")
EOF
	elif [[ $(basename "$1") == data.mdb ]]; then
		python <<EOF
from os.path import dirname as dirn
import lmdb

with lmdb.open(dirn("$1")) as env, env.begin() as txn:
    for key, val in txn.cursor():
        print(key.decode())
EOF
	fi
elif [ "$kind" = zip ] && [ "$ext" = pth ]; then
	python <<EOF
import torch

data = torch.load("$1")
if isinstance(data, torch.Tensor):
    print(data.shape)
print(data)
EOF
elif [ "$kind" = json ]; then
	if has_cmd jupyter bat && [ "$ext" = ipynb ]; then
		jupyter nbconvert --to python --stdout "$1" | bat --color=always -plpython
	elif has_cmd jq; then
		jq -Cr . "$1"
	fi
elif [ "$kind" = vnd.sqlite3 ]; then
	if has_cmd yes sqlite3 bat; then
		yes .q | sqlite3 "$1" | bat --color=always -plsql
	fi
# https://github.com/wofr06/lesspipe/pull/107
elif [ -d "$1" ]; then
	if has_cmd eza; then
		eza -hl --git --color=always --icons "$1"
	elif has_cmd exa; then
		exa -hl --color=always --icons "$1"
	fi
# https://github.com/wofr06/lesspipe/pull/110
elif [ "$kind" = pdf ]; then
	if has_cmd pdftotext sed; then
		pdftotext -q "$1" - | sed "s/\f/$(hr ─)\n/g"
	fi
# https://github.com/wofr06/lesspipe/pull/115
elif [ "$kind" = rfc822 ]; then
	if has_cmd bat; then
		bat --color=always -lEmail "$1"
	fi
elif [ "$kind" = javascript ]; then
	if has_cmd bat; then
		bat --color=always -ljs "$1"
	fi
# https://github.com/wofr06/lesspipe/pull/106
elif [ "$category" = image ]; then
	display_image "$1"
	if has_cmd exiftool; then
		exiftool "$1" | bat --color=always -plyaml
	fi
elif [ "$kind" = vnd.openxmlformats-officedocument.spreadsheetml.sheet ] || [ "$kind" = vnd.ms-excel ]; then
	if has_cmd in2csv && has_cmd xsv && has_cmd bat; then
		in2csv "$1" | xsv table | bat -ltsv --color=always
	fi
# https://github.com/wofr06/lesspipe/pull/117
elif [ "$category" = text ]; then
	if has_cmd bat; then
		bat --color=always "$1"
	elif has_cmd pygmentize; then
		pygmentize "$1" | less
	fi
elif has_cmd lesspipe.sh; then
	lesspipe.sh "$1"
elif has_cmd "$HOME/.local/share/lesspipe/lesspipe.sh"; then
	$HOME/.local/share/lesspipe/lesspipe.sh "$1"
else
	exit 1
fi
