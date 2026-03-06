---
name: issue-list
description: GitHub 이슈 목록을 조회합니다. "이슈 목록 보여줘", "open 이슈 뭐 있어", "book-purchase 레이블 이슈 알려줘" 같은 자연어 요청에 반응합니다.
---

# SKILL: issue-list

공통 설정: `$GH_TOKEN` 환경변수, repo = `awesomedays/awesomedays`

사용자의 요청에서 다음 파라미터를 판단하세요:
- `state`: open(기본값) | closed | all
- `labels`: 레이블명 (없으면 생략)
- `per_page`: 결과 수 (기본 30, 최대 100)

아래 curl 명령을 실행하되, 파라미터를 URL 쿼리에 적절히 반영하세요:

```bash
curl -s \
  -H "Authorization: token $GH_TOKEN" \
  "https://api.github.com/repos/awesomedays/awesomedays/issues?state=open&per_page=30" \
  | python3 -c "
import json, sys
issues = json.load(sys.stdin)
if not issues:
    print('이슈 없음')
else:
    for i in issues:
        labels = ','.join(l['name'] for l in i['labels'])
        label_str = f'[{labels}]' if labels else ''
        print(f\"#{i['number']} {label_str} {i['title']}\")"
```
