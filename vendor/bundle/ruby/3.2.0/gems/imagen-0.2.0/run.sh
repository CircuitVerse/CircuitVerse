docker run \
  --name "imagen-rb" \
  -it \
  --rm \
  -v "$(pwd):/imagen" \
  --entrypoint bash \
  mrgrodo/imagen-rb
