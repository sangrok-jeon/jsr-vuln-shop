# jsr-vuln-shop

보안 실습과 웹 취약점 분석을 목적으로 제작한 의도적 취약 쇼핑몰 프로젝트입니다.  
회원가입, 로그인, 마이페이지, 주문, Q&A, 관리자 기능을 포함한 전형적인 쇼핑몰 흐름을 직접 구현하고, 각 기능에서 발생할 수 있는 취약점을 재현한 뒤 대응 코드와 재검증까지 정리했습니다.

## 프로젝트 목적

- 웹 취약점 진단 및 재현 역량 정리
- 코드 레벨 원인 분석과 대응 방안 정리

## 프로젝트에서 다룬 범위

- 인증/인가: 평문 비밀번호 저장, 로그인 SQL Injection, 권한 상승, 주문/문의 IDOR
- 입력 검증/출력 인코딩: Stored XSS, 정보 노출, 잘못된 파라미터 처리
- 파일 처리: 위험한 파일 업로드, 웹 경로 노출, 웹쉘 실행 위험
- 비즈니스 로직: 포인트 충전/사용, 가격 변조, 주문 결제 검증
- 세션/상태 변경: 관리자 CSRF, 비밀번호 변경 재인증 부재

## 대표 취약점

- 로그인 SQL Injection을 통해 인증 우회가 가능한 구조를 재현하고, `PreparedStatement` 기반 대응으로 수정했습니다.
- 마이페이지 `role` 신뢰 문제로 일반 사용자가 관리자 권한을 획득할 수 있는 흐름을 재현하고, 세션 기준 권한 검증으로 보완했습니다.
- 주문 기능에서 `price`, `totalPrice` 요청값을 신뢰하는 구조를 이용해 가격 변조가 가능한 상황을 재현하고, 서버 재계산 방식으로 수정했습니다.
- 리뷰 Stored XSS를 통해 저장형 스크립트 실행을 확인하고, 출력 이스케이프와 테스트용 쿠키 제거로 대응했습니다.
- 관리자 문의 확인 흐름을 이용한 CSRF 시나리오를 재현하고, 본문 안전 렌더링과 CSRF 토큰 검증으로 보완했습니다.

## 브랜치 안내

- `master`
  - 취약 코드 유지
  - 문서, 분석 내용, 증적 이미지 관리
- `patched`
  - 실제 대응 코드만 반영
  - 취약점별 수정 결과 확인용 브랜치

## 테스트 및 실행 환경

- 로컬 테스트 환경에서만 재현
- 기본 진입점
  - `/jsr/products`
  - `/jsr/login`
- 일부 시나리오는 Burp Suite, 로컬 HTTP 서버, 별도 테스트용 페이지를 사용해 검증

## 문서 목록

| No | 문서 | 포함 취약점 | 진입점 | 경로 |
| --- | --- | --- | --- | --- |
| 1 | Register Security | Plaintext Password Storage, Input Validation Missing | `/jsr/register` | [`docs/01-register-security.md`](docs/01-register-security.md) |
| 2 | Login Security | SQL Injection, Sensitive Debug Logging | `/jsr/login` | [`docs/02-login-security.md`](docs/02-login-security.md) |
| 3 | Privilege Escalation | Privilege Escalation, Broken Access Control | `/jsr/mypage`, `/jsr/admin/dashboard` | [`docs/03-privilege-escalation.md`](docs/03-privilege-escalation.md) |
| 4 | Inquiry Security | Broken Access Control, IDOR | `/jsr/board?tab=INQUIRY`, `/jsr/board/edit`, `/jsr/board/delete` | [`docs/04-inquiry-security.md`](docs/04-inquiry-security.md) |
| 5 | File Upload Security | Insecure File Upload, Web-Accessible Upload, Web Shell Upload | `/jsr/board/write`, `/jsr/uploads/*` | [`docs/05-file-upload-security.md`](docs/05-file-upload-security.md) |
| 6 | Point Charge Security | Business Logic Flaw, Charge Limit Bypass, Negative Point Balance | `/jsr/point`, `/jsr/point/charge`, `/jsr/point/use` | [`docs/06-point-charge-security.md`](docs/06-point-charge-security.md) |
| 7 | Order Security | Price Tampering, Business Logic Flaw | `/jsr/product/detail`, `/jsr/order`, `/jsr/order/proc` | [`docs/07-order-security.md`](docs/07-order-security.md) |
| 8 | Stored XSS Security | Stored XSS, Test Cookie Exposure (Local Test Only) | `/jsr/login`, `/jsr/product/detail`, `/jsr/product/review` | [`docs/08-stored-xss-security.md`](docs/08-stored-xss-security.md) |
| 9 | Order IDOR Security | Broken Access Control, IDOR | `/jsr/order/list`, `/jsr/order/detail` | [`docs/09-order-idor-security.md`](docs/09-order-idor-security.md) |
| 10 | Admin CSRF Security | CSRF, HTML Link Injection | `/jsr/board?tab=INQUIRY`, `/jsr/board/detail`, `/jsr/point/use` | [`docs/10-admin-csrf-security.md`](docs/10-admin-csrf-security.md) |
| 11 | Password Change Security | Missing Current Password Verification, Weak Re-Authentication | `/jsr/mypage`, `/jsr/mypage/pw_change` | [`docs/11-password-change-security.md`](docs/11-password-change-security.md) |
| 12 | Information Exposure Security | Information Exposure, Improper Input Validation, Verbose Error Message | `/jsr/product/detail`, `/jsr/board/detail` | [`docs/12-information-exposure-security.md`](docs/12-information-exposure-security.md) |

## 보는 방법

- 취약한 동작과 분석 문서를 보려면 `master` 브랜치를 확인합니다.
- 실제 수정된 코드가 궁금하면 `patched` 브랜치를 확인합니다.
- 각 문서는 공통적으로 다음 순서로 정리했습니다.
  - 개요
  - 진입점
  - 포함 이슈
  - 취약한 부분
  - 취약한 코드
  - 증적 자료
  - 영향
  - 대응 방안
  - 수정 코드
  - 대응 증적

## 주의

- 본 프로젝트는 교육, 실습, 분석 목적으로 제작되었습니다.
- 로컬 테스트 환경 기준으로 재현했으며, 실제 서비스 운영 환경에 그대로 사용하면 안 됩니다.
