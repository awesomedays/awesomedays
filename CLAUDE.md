## GitHub 이슈 작업 방식
- gh CLI가 없는 환경(모바일 등)에서는
  curl + $GH_TOKEN으로 GitHub API를 직접 호출
- 이슈 조회: GET /repos/awesomedays/awesomedays/issues
- 이슈 생성: POST /repos/awesomedays/awesomedays/issues
- 이슈 수정: PATCH /repos/awesomedays/awesomedays/issues/{number}
- 이슈 삭제: DELETE (GraphQL API 사용)
