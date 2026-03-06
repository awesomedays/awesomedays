---
name: issue-close
description: GitHub 이슈를 닫습니다. "이슈 #5 닫아줘", "issue-close 스킬로 완료 처리해줘" 같은 자연어 요청에 반응합니다.
---

# SKILL: issue-close

공통 설정: `$GH_TOKEN` 환경변수, repo = `awesomedays/awesomedays`

사용자의 요청에서 닫을 이슈 번호를 파악하세요. 번호가 명시되지 않으면 먼저 issue-list로 목록을 보여주고 선택하게 하세요.

아래 curl 명령을 실행하세요:

```bash
curl -s -X PATCH \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/awesomedays/awesomedays/issues/{{번호}}" \
  -d '{"state": "closed"}' \
  | python3 -c "
import json, sys
i = json.load(sys.stdin)
print(f\"닫힘 #{i['number']}: {i['title']}\")"
```
