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

현재 `patched` 브랜치에는 회원가입 비밀번호 해시 저장 대응이 반영되어 있습니다.

## 문서 목록

| No | 기능 | 취약점 | 진입점 | 문서 |
| --- | --- | --- | --- | --- |
| 1 | Register | Plaintext Password Storage | `/jsr/register` | [`docs/01-register-security.md`](docs/01-register-security.md) |
| 2 | Register | Input Validation Missing | `/jsr/register` | [`docs/01-register-security.md`](docs/01-register-security.md) |
| 3 | Login | SQL Injection | `/jsr/login` | [`docs/02-login-security.md`](docs/02-login-security.md) |
| 4 | Login | Sensitive Debug Logging | `/jsr/login` | [`docs/02-login-security.md`](docs/02-login-security.md) |
