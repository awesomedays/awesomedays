---
name: issue-delete
description: GitHub 이슈를 완전히 삭제합니다 (되돌릴 수 없음). "이슈 #5 삭제해줘", "issue-delete 스킬로 지워줘" 같은 자연어 요청에 반응합니다. 삭제 대신 close를 권장하세요.
---

# SKILL: issue-delete

공통 설정: `$GH_TOKEN` 환경변수, repo = `awesomedays/awesomedays`

⚠️ 삭제는 되돌릴 수 없습니다. 실행 전에 반드시 사용자에게 확인을 받으세요.
보통은 issue-close로 대체하는 것을 먼저 권유하세요.

사용자가 삭제를 확인하면 아래 두 단계를 순서대로 실행하세요:

```bash
# 1단계: node_id 조회
NODE_ID=$(curl -s \
  -H "Authorization: token $GH_TOKEN" \
  "https://api.github.com/repos/awesomedays/awesomedays/issues/{{번호}}" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['node_id'])")

# 2단계: GraphQL로 삭제
curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/graphql" \
  -d "{\"query\": \"mutation { deleteIssue(input: {issueId: \\\"$NODE_ID\\\"}) { repository { name } } }\"}" \
  | python3 -c "
import json, sys
r = json.load(sys.stdin)
print('삭제완료' if 'data' in r else f'오류: {r}')"
```
