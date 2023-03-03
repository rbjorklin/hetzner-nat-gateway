#!/bin/sh

cat <<EOF
{
  "HCLOUD_TOKEN": "${HCLOUD_TOKEN}",
  "HCLOUD_SSH_KEY": "${HCLOUD_SSH_KEY}"
}
EOF
