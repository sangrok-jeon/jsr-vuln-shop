# jsr-vuln-shop

보안 실습과 취약점 분석을 목적으로 만든 의도적으로 취약한 쇼핑몰 프로젝트입니다.

## 주의

- 이 프로젝트는 교육 및 테스트용입니다.
- 실서비스 배포용으로 사용하면 안 됩니다.

## 진입점

- `/jsr/products`
- `/jsr/login`

## 브랜치 안내

- `master`: 취약한 코드와 전체 분석 문서
- `patched`: 실제 대응 코드가 반영된 브랜치

현재 `patched` 브랜치에는 회원가입 비밀번호 해시 저장, 로그인 SQL Injection 대응, 마이페이지 권한 상승 대응, 문의 게시판 접근 통제 대응이 반영되어 있습니다.

## 문서 목록

| No | 문서 | 포함 취약점 | 진입점 | 경로 |
| --- | --- | --- | --- | --- |
| 1 | Register Security | Plaintext Password Storage, Input Validation Missing | `/jsr/register` | [`docs/01-register-security.md`](docs/01-register-security.md) |
| 2 | Login Security | SQL Injection, Sensitive Debug Logging | `/jsr/login` | [`docs/02-login-security.md`](docs/02-login-security.md) |
| 3 | Privilege Escalation | Privilege Escalation, Broken Access Control | `/jsr/mypage`, `/jsr/admin/dashboard` | [`docs/03-privilege-escalation.md`](docs/03-privilege-escalation.md) |
| 4 | Inquiry Security | Broken Access Control, IDOR | `/jsr/board?tab=INQUIRY`, `/jsr/board/edit`, `/jsr/board/delete` | [`docs/04-inquiry-security.md`](docs/04-inquiry-security.md) |
