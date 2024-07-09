#!/bin/sh

# clone asdf repository on $ASDF_DATA_DIR, default is $XDG_DATA_HOME/asdf
# or update if is already there
if [ -f "${ASDF_DATA_DIR}/asdf.sh" ]; then
    asdf update
else
    git clone https://github.com/asdf-vm/asdf.git $ASDF_DATA_DIR
fi