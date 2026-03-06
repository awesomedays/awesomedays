# SKILL.md - GitHub 이슈 CRUD 루틴

공통 설정: `$GH_TOKEN` 환경변수, repo = `awesomedays/awesomedays`

---

## SKILL: issue-list (이슈 목록 조회)

```bash
curl -s \
  -H "Authorization: token $GH_TOKEN" \
  "https://api.github.com/repos/awesomedays/awesomedays/issues?state=open&per_page=30" \
  | python3 -c "
import json, sys
issues = json.load(sys.stdin)
for i in issues:
    print(f\"#{i['number']} [{','.join(l['name'] for l in i['labels'])}] {i['title']}\")"
```

옵션 파라미터 (URL 쿼리에 추가):
- `state=open|closed|all`
- `labels=레이블명`
- `per_page=N` (최대 100)

---

## SKILL: issue-create (이슈 생성)

```bash
curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/awesomedays/awesomedays/issues" \
  -d '{
    "title": "{{제목}}",
    "body": "{{본문}}",
    "labels": ["{{레이블}}"]
  }' | python3 -c "import json,sys; i=json.load(sys.stdin); print(f\"생성완료 #{i['number']}: {i['title']}\nhttps://github.com/awesomedays/awesomedays/issues/{i['number']}\")"
```

레이블 옵션 (현재 저장소 기준):
- `book-relocation` / `book-purchase` / `daily` 등 기존 이슈 참고

---

## SKILL: issue-update (이슈 수정)

```bash
curl -s -X PATCH \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/awesomedays/awesomedays/issues/{{번호}}" \
  -d '{
    "title": "{{새제목}}",
    "body": "{{새본문}}",
    "state": "open|closed",
    "labels": ["{{레이블}}"]
  }' | python3 -c "import json,sys; i=json.load(sys.stdin); print(f\"수정완료 #{i['number']}: {i['title']} ({i['state']})\")"
```

수정하지 않을 필드는 `-d` 본문에서 제외하면 됩니다.

---

## SKILL: issue-close (이슈 닫기)

issue-update의 단축형:

```bash
curl -s -X PATCH \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/awesomedays/awesomedays/issues/{{번호}}" \
  -d '{"state": "closed"}' \
  | python3 -c "import json,sys; i=json.load(sys.stdin); print(f\"닫힘 #{i['number']}: {i['title']}\")"
```

---

## SKILL: issue-delete (이슈 삭제)

REST API는 삭제 미지원 → GraphQL 사용:

```bash
# 1단계: 이슈의 node_id 조회
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
  | python3 -c "import json,sys; r=json.load(sys.stdin); print('삭제완료' if 'data' in r else f'오류: {r}')"
```

주의: 삭제는 되돌릴 수 없습니다. 보통 close로 대체 권장.

---

## 사용 가이드

이 스킬들을 활용할 때 다음과 같이 요청하면 됩니다:

> "issue-create 스킬로 이슈 만들어줘: 제목은 ..., 본문은 ..., 레이블은 ..."
> "issue-list 스킬로 open 이슈 보여줘"
> "issue-close 스킬로 #5 닫아줘"
