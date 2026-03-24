# jsr-vuln-shop

보안 실습, 취약점 분석, 포트폴리오 정리를 위해 만든 의도적으로 취약한 쇼핑몰 프로젝트입니다.

## 주의

- 이 프로젝트는 교육 및 테스트용입니다.
- 실서비스 배포용으로 사용하면 안 됩니다.
- 운영용 계정, 실제 개인정보, 실서버 비밀값은 저장소에 포함하지 않는 것을 전제로 합니다.

## 진입점

- `/jsr/products`
- `/jsr/login`

## 문서 작성 방식

- `README.md`: 취약점 색인과 진입점 안내
- `docs/*.md`: 기능 단위 상세 분석 문서
- 하나의 기능 문서 안에서 `주요 취약점`과 `관련 취약점`을 함께 설명

## 현재 문서화된 항목

| No | 기능 | 취약점 | 진입점 | 문서 |
| --- | --- | --- | --- | --- |
| 1 | Login | SQL Injection | `/jsr/login` | [`docs/01-login-security.md`](docs/01-login-security.md) |
| 2 | Login | Plaintext Password Storage | `/jsr/login` | [`docs/01-login-security.md`](docs/01-login-security.md) |
| 3 | Login | Sensitive Debug Logging | `/jsr/login` | [`docs/01-login-security.md`](docs/01-login-security.md) |

## 권장 시작 순서

1. `/jsr/login`에서 정상 로그인 실패 화면을 확인합니다.
2. 주석 기반 우회 시도가 왜 실패하는지 확인합니다.
3. OR 조건 기반 우회가 왜 성공하는지 확인합니다.
4. 로그인 이후 `/jsr/products`로 이동되는 흐름을 봅니다.
5. 문서에서 원인, 대응 방안, 수정 코드 예시를 함께 확인합니다.

## 다음 문서 후보

- Product / Review 기능
- Mypage / Order 기능
- Admin / Upload 기능
