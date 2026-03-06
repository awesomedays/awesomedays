---
name: issue-create
description: GitHub 이슈를 생성합니다. "이슈 만들어줘", "issue-create 스킬로 이슈 생성해줘" 같은 자연어 요청에 반응합니다.
---

# SKILL: issue-create

공통 설정: `$GH_TOKEN` 환경변수, repo = `awesomedays/awesomedays`

사용자의 요청과 대화 맥락을 바탕으로 다음을 스스로 판단하세요:
- `title`: 핵심 내용을 담은 명확하고 간결한 제목
- `body`: 배경·목적·세부사항을 포함한 본문 (마크다운 사용 가능)
- `labels`: 내용에 맞는 레이블 선택 (book-relocation / book-purchase / daily / 기타)

판단한 값으로 아래 curl 명령을 실행하세요:

```bash
curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/awesomedays/awesomedays/issues" \
  -d '{
    "title": "{{제목}}",
    "body": "{{본문}}",
    "labels": ["{{레이블}}"]
  }' | python3 -c "
import json, sys
i = json.load(sys.stdin)
print(f\"생성완료 #{i['number']}: {i['title']}\")
print(f\"https://github.com/awesomedays/awesomedays/issues/{i['number']}\")"
```

실행 전에 판단한 제목·본문·레이블을 사용자에게 먼저 보여주고 확인을 받으세요.
