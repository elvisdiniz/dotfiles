if [ -z "$CUDA_CACHE_PATH" ]; then
  export CUDA_CACHE_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/nv"
fi
