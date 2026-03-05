#!/bin/bash
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

which gh > /dev/null 2>&1 || sudo apt-get install -y gh
