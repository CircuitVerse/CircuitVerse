#!/bin/sh

# Only Linux hosts need the container user mapped to a real uid/gid to write
# the bind-mounted checkout; Codespaces and other hosts keep the compose
# defaults. Never fail the container build if this can't run.
[ "$(uname -s 2>/dev/null)" = "Linux" ] || exit 0

cat > "$(dirname "$0")/../.env" <<-EOF
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
OPERATING_SYSTEM=linux
EOF
