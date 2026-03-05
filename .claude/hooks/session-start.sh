#!/bin/bash
set -euo pipefail

# GitHub API 접근 가능 여부 확인
if [ -n "$GH_TOKEN" ]; then
  curl -s -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user > /dev/null 2>&1 \
    && echo "✅ GitHub API 연결 확인됨" \
    || echo "⚠️ GitHub API 연결 실패"
fi
