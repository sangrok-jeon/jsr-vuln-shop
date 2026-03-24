# 01. Login Security

## 개요

로그인 기능에서 확인된 보안 이슈를 정리한 문서이다. 본 문서에서는 `SQL Injection`, `평문 비밀번호 저장/비교 구조`, `민감한 디버그 로그 출력`을 함께 다룬다.

## 진입점

- `/jsr/login`

## 포함 이슈

| 구분 | 취약점 | 설명 |
| --- | --- | --- |
| 주요 취약점 | SQL Injection | 사용자 입력이 문자열 결합 SQL로 실행되어 인증 우회가 가능함 |
| 관련 취약점 | Plaintext Password Storage | 비밀번호를 해시 처리 없이 저장·비교하는 구조 |
| 추가 관찰 | Sensitive Debug Logging | 로그인 시도 시 사용자 ID와 비밀번호가 로그에 그대로 출력됨 |

## 재현 결과

### 1. 정상 실패 동작 확인

- 잘못된 계정 정보를 입력하면 로그인 실패 메시지가 표시된다.

### 2. 주석 기반 우회 시도는 실패

- 예시: `test'--`
- `--`, `#`, `/**/` 등 일부 주석 패턴이 제거되어 우회가 실패한다.

### 3. OR 조건 기반 우회는 성공

- 예시: `test'or'1'='1`
- 주석 제거 방식만으로는 boolean-based 조건 우회를 막지 못한다.
- 조건식이 참이 되면서 인증 우회가 발생한다.

## 확인 로그

민감한 연결 정보는 제외하고 로그인 요청 시 출력된 로그 일부만 정리하면 다음과 같다.

```text
==== [DEBUG] LoginServlet doPost called ====
[DEBUG] userid   = [test'or'1'='1]
[DEBUG] password = [12]
```

## 원인 분석

이 기능은 사용자 입력을 SQL 문자열에 직접 결합한 뒤 `Statement`로 실행한다. 따라서 입력값이 데이터가 아니라 SQL 구문으로 해석될 수 있다.

또한 비밀번호를 해시 검증이 아니라 `PASSWORD` 값과 직접 비교하고, 로그인 성공 후 객체에 그대로 저장하고 있다.

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

## 취약 원인

1. `filterSqli()`는 일부 문자열만 제거하는 블랙리스트 방식이라 우회가 가능합니다.
2. `Statement`와 문자열 결합 SQL을 함께 사용해 SQL Injection이 발생합니다.
3. `PASSWORD` 컬럼을 그대로 비교하고 애플리케이션 객체에 저장하고 있어 평문 비밀번호 처리 구조가 드러납니다.
4. 로그인 시도 시 사용자 입력을 그대로 로그에 남깁니다.

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

이 방식은 특정 패턴만 제거할 뿐 SQL 문법 전체를 제어하지 못한다. 따라서 주석을 사용하지 않는 조건 우회 입력은 그대로 통과할 수 있다.

## 영향

- 인증 우회 가능
- 임의 사용자 세션 획득 가능
- 사용자 정보 조회 가능
- DB 유출 시 평문 비밀번호 노출 가능
- 로그 접근 시 계정 정보 노출 가능

## 대응 방안

### 1. SQL Injection 대응

- `Statement` 대신 `PreparedStatement` 사용
- 사용자 입력을 SQL 문자열에 직접 결합하지 않기
- 블랙리스트 필터에 의존하지 않기

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

위 코드는 문자열 결합 SQL을 제거해 SQL Injection을 완화한다. 다만 비밀번호를 여전히 평문으로 비교한다는 한계가 있다.

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
