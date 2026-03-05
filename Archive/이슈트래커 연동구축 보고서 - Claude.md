# Google Drive + Claude Code + GitHub Issues 연동 구축 보고서

- **작성일**: 2026-03-05
- **작성자**: Donghwan Lee (awesomedays)
- **저장소**: awesomedays/awesomedays (Private)

---

## 1. 개요

Google Drive 로컬 폴더를 Claude Code 에이전트가 접근하고, 그 맥락을 기반으로 GitHub Issues를 생성/조회/편집/삭제하는 워크플로우를 구축한 과정을 기록한다. 사무실 PC, 데스크탑 앱, 모바일(Android) 세 환경에서의 시행착오와 최종 해결 방안을 포함한다.

---

## 2. 목표 및 최종 구성

### 2.1 목표

- Google Drive 폴더의 파일을 Claude Code가 읽고 맥락 파악
- 해당 맥락을 기반으로 GitHub Issues에 이슈 자동 생성/조회/편집/삭제
- 사무실 PC, 데스크탑 앱, 모바일 세 환경에서 동일하게 동작

### 2.2 최종 워크플로우

| 환경 | 도구 | GitHub 연동 방식 | 상태 |
|------|------|----------------|------|
| 사무실 PC (VS Code) | Claude Code Extension + gh CLI | gh CLI (로컬 설치) | ✅ 완료 |
| 데스크탑 앱 | Claude Code (Github PR Automation 환경) | gh CLI (로컬 설치) | ✅ 완료 |
| 모바일 (Android) | Claude Code (Github PR Automation 환경) | curl + GH_TOKEN | ✅ 완료 |

---

## 3. 구축 과정

### 3.1 이슈트래커 선정

AI 에이전트 접근성, 인간 친화적 UI, 크로스플랫폼 연동을 기준으로 검토한 결과 GitHub Issues를 선택하였다.

| 서비스 | AI 에이전트 접근성 | UI | 크로스플랫폼 |
|--------|-----------------|-----|------------|
| GitHub Issues | ⭐⭐⭐⭐⭐ (gh CLI) | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Linear | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Jira | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |

선택 근거: 기존 gh CLI 인증(GH_TOKEN) 환경이 이미 구성되어 있어 추가 설정 없이 바로 연동 가능.

### 3.2 저장소 설정

- `awesomedays/awesomedays`: GitHub 프로필 저장소를 이슈트래커로 활용
- **Private 전환**: 개인정보 포함 이슈의 보안을 위해 Public → Private으로 변경
- **Collaborator 0명 확인**: 본인 외 접근 불가 상태 확인

### 3.3 VS Code 익스텐션 설치

- 설치: `GitHub Pull Requests` (`github.vscode-pull-request-github`, 3300만+ 다운로드)
- 한계 확인: Google Drive 폴더는 git 리포지토리가 아니므로 익스텐션 사이드바 비활성화 (`No git repositories found`)
- 결론: 익스텐션 UI 활용 포기, Claude Code의 gh CLI 방식으로 전환

### 3.4 사무실 PC 연동 확인

VS Code에서 Google Drive 로컬 폴더를 열고 Claude Code Extension으로 gh CLI 인증 상태 확인.

| 확인 항목 | 결과 |
|----------|------|
| `gh auth status` | ✅ awesomedays 계정 로그인 (keyring) |
| `gh api user` | ✅ Donghwan Lee / Plotrick Co. 확인 |
| `gh issue list` | ⚠️ git 리포지토리 아님 → `-R` 플래그로 해결 |
| 이슈 생성/편집/삭제 | ✅ `-R awesomedays/awesomedays` 명시로 정상 동작 |

---

## 4. 시행착오 (모바일 환경)

### 4.1 문제 상황

모바일에서 새 세션 생성 시 `gh` CLI가 없어 모든 명령 실패. `Github PR Automation` 환경을 선택했음에도 동일한 증상 반복.

### 4.2 1차 시도: session-start hook에 gh CLI 설치 추가

`session-start.sh`에 아래 라인 추가 후 PR 머지:

```bash
which gh > /dev/null 2>&1 || sudo apt-get install -y gh
```

**결과: 실패.** hook 파일에 아래 조건이 있어 모바일에서 hook이 조기 종료되고 있었음:

```bash
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi
```

`CLAUDE_CODE_REMOTE` 변수가 모바일 환경에 존재하지 않아 hook이 실행되지 않았음.

### 4.3 2차 시도: hook 조건 블록 제거

`CLAUDE_CODE_REMOTE` 조건 블록 전체를 제거하여 모든 환경에서 hook이 실행되도록 수정.

**결과: 실패.** `apt-get` 설치 시 아래 에러 발생:

```
Temporary failure resolving 'archive.ubuntu.com'
E: Failed to fetch http://security.ubuntu.com/ubuntu ...
```

원인: 모바일 Claude Code 클라우드 샌드박스 컨테이너가 외부 인터넷(apt 저장소)을 차단하고 있음. 모바일 데이터 연결과 무관한 컨테이너 네트워크 정책 문제.

### 4.4 3차 시도: curl + GH_TOKEN 방식으로 전환 (최종 해결)

`gh` CLI 없이 `GH_TOKEN` 환경변수와 `curl`로 GitHub REST/GraphQL API를 직접 호출하는 방식 채택.

- 이슈 조회: `curl` + REST API (`GET /repos/.../issues`)
- 이슈 생성: `curl` + REST API (`POST /repos/.../issues`)
- 이슈 삭제: `curl` + GraphQL API (REST는 삭제 미지원)

`session-start.sh`를 GitHub API 연결 확인용으로 변경하고, `CLAUDE.md`에 `curl` 방식 사용 지침 추가.

**결과: ✅ 성공.**

### 4.5 시행착오 요약

| 시도 | 방법 | 결과 | 원인 |
|------|------|------|------|
| 1차 | apt-get install gh (hook 조건 있음) | ❌ 실패 | CLAUDE_CODE_REMOTE 변수 없어 hook 조기 종료 |
| 2차 | apt-get install gh (hook 조건 제거) | ❌ 실패 | 샌드박스 컨테이너 외부 네트워크 차단 |
| 3차 | curl + GH_TOKEN으로 API 직접 호출 | ✅ 성공 | GH_TOKEN은 주입됨, GitHub API는 접근 허용 |

---

## 5. 최종 구성

### 5.1 session-start.sh

```bash
#!/bin/bash
set -euo pipefail

# GitHub API 연결 확인
if [ -n "$GH_TOKEN" ]; then
  curl -s -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user > /dev/null 2>&1 \
    && echo "✅ GitHub API 연결 확인됨" \
    || echo "⚠️ GitHub API 연결 실패"
fi
```

### 5.2 CLAUDE.md 추가 지침

환경에 따라 Claude Code가 자동으로 적절한 방식을 선택하도록 지침 추가:

- `gh` CLI 사용 가능 환경(로컬): `gh` CLI 명령 사용
- `gh` CLI 없는 환경(모바일 클라우드): `curl + $GH_TOKEN`으로 GitHub API 직접 호출

### 5.3 환경별 동작 방식 요약

| 환경 | GH_TOKEN | gh CLI | GitHub API (curl) | 동작 |
|------|----------|--------|-----------------|------|
| 사무실 PC (로컬) | keyring | ✅ 로컬 설치 | 가능 | ✅ |
| 데스크탑 앱 (클라우드) | 환경변수 주입 | ✅ 로컬 설치 | 가능 | ✅ |
| 모바일 (클라우드 샌드박스) | 환경변수 주입 | ❌ 설치 불가 | ✅ 가능 | ✅ |

---

## 6. 결론

세 환경 모두에서 Google Drive 파일 맥락 기반 GitHub 이슈 생성/조회/편집/삭제가 정상 동작함을 확인하였다.

| 항목 | 상태 |
|------|------|
| 사무실 PC: Google Drive → Claude Code → GitHub Issues | ✅ 완료 |
| 데스크탑 앱: Claude Code (Github PR Automation 환경) | ✅ 완료 |
| 모바일: curl + GH_TOKEN 방식으로 GitHub API 직접 연동 | ✅ 완료 |
| awesomedays/awesomedays Private 설정 | ✅ 완료 |
| 집 PC 로컬 환경 세팅 | ⏳ 퇴근 후 실행 예정 |

**핵심 교훈**: 모바일 클라우드 샌드박스는 외부 패키지 설치가 차단되어 있으나, `GH_TOKEN` 환경변수와 GitHub API(HTTPS)는 접근 가능하다. `gh` CLI에 의존하지 않고 `curl` 기반 API 호출로 동일한 기능을 구현할 수 있다.
