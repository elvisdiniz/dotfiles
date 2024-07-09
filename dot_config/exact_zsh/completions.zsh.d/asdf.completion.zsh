if [ -f "$ASDF_DATA_DIR/asdf.sh" ]; then
    fpath=(${ASDF_DATA_DIR}/completions $fpath)
fi
