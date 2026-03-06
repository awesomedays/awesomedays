---
name: issue-update
description: GitHub 이슈를 수정합니다. "이슈 #5 제목 바꿔줘", "issue-update 스킬로 본문 수정해줘" 같은 자연어 요청에 반응합니다.
---

# SKILL: issue-update

공통 설정: `$GH_TOKEN` 환경변수, repo = `awesomedays/awesomedays`

사용자의 요청에서 다음을 판단하세요:
- `number`: 수정할 이슈 번호 (필수)
- 수정할 필드만 선택 (수정하지 않는 필드는 `-d` 본문에서 제외):
  - `title`: 새 제목
  - `body`: 새 본문
  - `state`: open | closed
  - `labels`: 새 레이블 배열

아래 curl 명령을 실행하세요:

```bash
curl -s -X PATCH \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/awesomedays/awesomedays/issues/{{번호}}" \
  -d '{
    "title": "{{새제목}}",
    "body": "{{새본문}}",
    "labels": ["{{레이블}}"]
  }' | python3 -c "
import json, sys
i = json.load(sys.stdin)
print(f\"수정완료 #{i['number']}: {i['title']} ({i['state']})\")"
```

실행 전에 수정 내용을 사용자에게 먼저 보여주고 확인을 받으세요.
