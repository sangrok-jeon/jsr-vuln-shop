# 01. Login Security

## 개요

로그인 기능은 하나의 화면 안에 여러 보안 이슈를 함께 보여주기 좋은 지점입니다. 이 프로젝트에서는 로그인 기능을 기준으로 `SQL Injection`, `평문 비밀번호 저장`, `민감한 디버그 로그 출력`을 함께 정리합니다.

## 진입점

- `/jsr/login`

## 포함 이슈

| 구분 | 취약점 | 설명 |
| --- | --- | --- |
| 주요 취약점 | SQL Injection | 사용자 입력이 문자열 결합 SQL로 실행되어 인증 우회가 가능함 |
| 관련 취약점 | Plaintext Password Storage | 비밀번호를 해시 대신 평문으로 저장하고 비교하는 정황이 보임 |
| 추가 관찰 | Sensitive Debug Logging | 로그인 시도 시 사용자 ID와 비밀번호가 로그에 그대로 출력됨 |

## 재현 흐름

### 1. 정상 실패 동작 확인

- 잘못된 계정 정보를 입력하면 로그인 실패 메시지가 표시됩니다.
- 이 단계는 애플리케이션의 기본 동작과 에러 메시지를 확인하는 용도입니다.

### 2. 주석 기반 우회 시도는 실패

- 예시: `test'--`
- 현재 필터는 `--`, `#`, `/**/` 같은 일부 주석 패턴을 제거합니다.
- 따라서 단순 주석 기반 입력은 문법이 깨지거나 의도한 우회가 되지 않아 실패할 수 있습니다.

### 3. OR 조건 기반 우회는 성공

- 예시: `test'or'1'='1`
- 주석만 막는 블랙리스트 필터는 boolean-based 조건 우회를 막지 못합니다.
- 그 결과 쿼리 조건이 참이 되어 인증 우회가 발생할 수 있습니다.

## 원인 분석

이 기능은 사용자 입력을 SQL 문자열에 직접 결합한 뒤 `Statement`로 실행합니다. 즉, 입력값이 데이터가 아니라 SQL 구문으로 해석될 수 있는 구조입니다.

또한 비밀번호를 해시 검증이 아니라 DB의 `PASSWORD` 값과 직접 비교하고, 로그인 성공 후 객체에 그대로 담고 있어 평문 비밀번호 처리 정황도 보입니다.

## 취약 코드

파일: [`src/main/java/com/jsr/ctf/LoginServlet.java`](../src/main/java/com/jsr/ctf/LoginServlet.java)

```java
userid   = filterSqli(userid);
password = filterSqli(password);

String sql = "SELECT * FROM JSR_USERS "
        + "WHERE USERNAME = '" + userid + "' "
        + "AND PASSWORD = '" + password + "'";

stmt = conn.createStatement();
rs   = stmt.executeQuery(sql);

if (rs.next()) {
    loginUser = new JsrUser();
    loginUser.setUserId(rs.getLong("USER_ID"));
    loginUser.setUsername(rs.getString("USERNAME"));
    loginUser.setPassword(rs.getString("PASSWORD"));
    loginUser.setEmail(rs.getString("EMAIL"));
    loginUser.setRole(rs.getString("ROLE"));
    loginUser.setPoint(rs.getInt("POINT"));
    loginUser.setAddress(rs.getString("ADDRESS"));
    loginUser.setPhone(rs.getString("PHONE"));
}
```

### 왜 취약한가

1. `filterSqli()`는 일부 문자열만 제거하는 블랙리스트 방식이라 우회가 가능합니다.
2. `Statement`와 문자열 결합 SQL을 함께 사용해 SQL Injection이 발생합니다.
3. `PASSWORD` 컬럼을 그대로 조회하고 애플리케이션 객체에 넣고 있어 평문 저장 및 처리 정황이 보입니다.
4. 로그인 시도 시 사용자 입력을 그대로 로그에 남겨 민감 정보 노출 위험이 있습니다.

## 현재 필터의 한계

```java
private String filterSqli(String input) {
    if (input == null) return input;
    input = input.replaceAll("--", "");
    input = input.replaceAll("#", "");
    input = input.replaceAll("/\\*.*?\\*/", "");
    return input;
}
```

이 방식은 특정 패턴만 제거할 뿐, SQL 문법 전체를 안전하게 제어하지 못합니다. 따라서 주석 패턴을 쓰지 않는 조건 우회 입력은 여전히 통과할 수 있습니다.

## 영향

- 인증 우회 가능
- 임의 사용자 세션 획득 가능
- 사용자 정보 조회 가능성
- DB 유출 시 평문 비밀번호 즉시 노출 가능
- 로그 접근이 가능한 경우 계정 정보 추가 노출 가능

## 대응 방안

### 1. SQL Injection 대응

- `Statement` 대신 `PreparedStatement` 사용
- 사용자 입력을 SQL 문자열에 직접 결합하지 않기
- 블랙리스트 필터를 근본 대응으로 사용하지 않기

### 2. 비밀번호 저장 대응

- 비밀번호를 평문으로 저장하지 않기
- `bcrypt`, `scrypt`, `Argon2`, `PBKDF2` 등 단방향 해시 사용
- 로그인 시 해시 비교 방식으로 검증하기

### 3. 로그 처리 대응

- 사용자 비밀번호를 로그에 출력하지 않기
- 운영 환경에서 디버그 로그 최소화

## 수정 코드 예시

### 즉시 적용 가능한 SQL Injection 완화 예시

```java
String sql = "SELECT * FROM JSR_USERS WHERE USERNAME = ? AND PASSWORD = ?";

PreparedStatement ps = conn.prepareStatement(sql);
ps.setString(1, userid);
ps.setString(2, password);

ResultSet rs = ps.executeQuery();
```

이 코드는 문자열 결합 SQL을 제거해 SQL Injection 위험을 줄입니다. 다만 비밀번호를 여전히 평문으로 비교한다는 한계가 있어, 아래 방식이 더 적절합니다.

### 권장 수정 예시

```java
String sql = "SELECT USER_ID, USERNAME, PASSWORD_HASH, EMAIL, ROLE, POINT, ADDRESS, PHONE "
        + "FROM JSR_USERS WHERE USERNAME = ?";

PreparedStatement ps = conn.prepareStatement(sql);
ps.setString(1, userid);

ResultSet rs = ps.executeQuery();

if (rs.next() && PasswordUtil.matches(password, rs.getString("PASSWORD_HASH"))) {
    loginUser = new JsrUser();
    loginUser.setUserId(rs.getLong("USER_ID"));
    loginUser.setUsername(rs.getString("USERNAME"));
    loginUser.setEmail(rs.getString("EMAIL"));
    loginUser.setRole(rs.getString("ROLE"));
    loginUser.setPoint(rs.getInt("POINT"));
    loginUser.setAddress(rs.getString("ADDRESS"));
    loginUser.setPhone(rs.getString("PHONE"));
}
```

## 포트폴리오용 캡처 추천

### 본문용

- 로그인 화면
- 정상 로그인 실패 화면
- OR 조건 기반 우회 입력 화면

본문용 캡처는 UI가 잘 보이도록 전체 화면 또는 폼 중심 캡처가 깔끔합니다.

### 증거용

- 로그인 우회 후 이동된 페이지
- `/jsr/products` 또는 `/jsr/login` 같은 실제 경로가 드러나는 화면

성공 증거 캡처는 주소창이 보이게 찍는 편이 신뢰도가 높습니다.

### 추천 파일명

- `01-login-page.png`
- `02-invalid-login.png`
- `03-comment-filter-fail.png`
- `04-boolean-based-bypass-input.png`
- `05-products-after-login-with-url.png`

## 정리

이 로그인 기능은 단순히 SQL Injection 하나만 있는 화면이 아니라, `불완전한 필터링`, `평문 비밀번호 처리`, `민감한 로그 출력`까지 함께 관찰할 수 있는 좋은 포트폴리오 사례입니다. 따라서 문서는 기능 단위로 묶고, 그 안에서 주요 취약점과 관련 이슈를 함께 설명하는 방식이 가장 읽기 좋습니다.
