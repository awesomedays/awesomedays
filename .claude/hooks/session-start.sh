#!/bin/bash
set -euo pipefail

which gh > /dev/null 2>&1 || sudo apt-get install -y gh
