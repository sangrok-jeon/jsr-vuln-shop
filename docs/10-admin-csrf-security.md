# 10. Admin CSRF Security

## 개요
1:1 문의 기능에서 본문 내용이 이스케이프 없이 그대로 출력되어, 공격자가 삽입한 외부 링크가 관리자 화면에서 그대로 노출된다.  
관리자가 문의를 확인하던 중 해당 링크를 클릭하면, 외부 페이지가 자동으로 상태 변경 요청을 전송하고 서버는 이를 정상적인 관리자 요청으로 처리한다.

이번 시나리오에서는 공격자가 1:1 문의에 악성 링크를 삽입하고, 관리자가 해당 링크를 클릭하자 외부 페이지가 `/jsr/point/use` 요청을 자동 제출하여 관리자 포인트가 의도치 않게 차감되는 것을 확인하였다.

## 진입점
- `/jsr/board?tab=INQUIRY`
- `/jsr/board/detail`
- `/jsr/point/use`

## 포함 이슈

| 구분 | 취약점 | 설명 |
| --- | --- | --- |
| 주요 취약점 | CSRF | 포인트 사용과 같은 상태 변경 요청에 대해 CSRF 토큰 또는 Origin/Referer 검증이 없어, 로그인된 관리자 브라우저가 의도치 않은 요청을 전송할 수 있다. |
| 관련 이슈 | HTML Link Injection | 문의 본문이 raw 렌더링되어 공격자가 삽입한 `<a href>` 링크가 그대로 출력되고, 관리자가 이를 클릭할 수 있다. |

## 취약한 부분
문의 본문은 HTML 이스케이프 없이 그대로 출력되고, 포인트 사용 기능은 로그인 세션만 확인한 뒤 요청을 처리한다.  
그 결과 공격자는 외부 CSRF 페이지 링크를 1:1 문의에 삽입할 수 있고, 관리자가 해당 링크를 클릭하면 관리자 세션으로 상태 변경 요청이 수행된다.

## 취약한 코드

파일: `src/main/webapp/WEB-INF/views/board_detail_view.jsp`

```jsp
<div class="post-body">${jsrBoard.content}</div>
```

파일: `src/main/java/com/jsr/ctf/PointServlet.java`

```java
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String path = request.getServletPath();
    String amountStr = request.getParameter("amount");
    int amount = Integer.parseInt(amountStr.trim());

    JsrUser fresh = getUserById(user.getUserId());

    if (path.contains("use")) {
        if (amount <= 0) {
            response.sendRedirect(request.getContextPath() + "/point?error=negative");
            return;
        }

        int newPoint = fresh.getPoint() - amount;
        updatePoint(user.getUserId(), newPoint);
        saveHistory(user.getUserId(), "USE", amount, newPoint, "포인트 사용");
        fresh.setPoint(newPoint);
        request.getSession().setAttribute("jsrUser", fresh);
        response.sendRedirect(request.getContextPath() + "/point?used=1");
    }
}
```

테스트에 사용한 외부 CSRF 페이지 예시:

```html
<!DOCTYPE html>
<html>
<head><title>이벤트 안내</title></head>
<body>
    <h1>잠시만 기다려주세요...</h1>
    <form action="http://localhost:8080/jsr/point/use" method="POST" id="csrfForm">
        <input type="hidden" name="amount" value="100000000">
    </form>
    <script>
        document.getElementById("csrfForm").submit();
    </script>
</body>
</html>
```

## 취약한 코드 동작 설명
공격자는 외부 페이지에 자동 제출되는 CSRF 폼을 준비한 뒤, 해당 페이지로 이동하는 링크를 1:1 문의 본문에 삽입한다.  
문의 상세 화면은 본문을 그대로 렌더링하므로 관리자는 링크를 정상 문의 링크처럼 인식하고 클릭할 수 있다.

관리자가 링크를 클릭하면 먼저 공격자 서버(예: `http://localhost:8989/jsr.html`)에 접속하고, 이후 해당 외부 페이지가 `/jsr/point/use` 요청을 자동 제출한다.  
서버는 요청의 출처를 검증하지 않고 로그인된 관리자 세션만 확인하여 포인트 사용을 수행한다.

## 취약한 코드 증적자료

### 1. 공격자가 준비한 외부 CSRF 페이지
![01-csrf-page-code](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/10-admin-csrf-security/01-csrf-page-code.png)

### 2. 관리자 포인트 사용 전 상태
![02-admin-point-before-csrf](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/10-admin-csrf-security/02-admin-point-before-csrf.png)

### 3. 공격자가 1:1 문의에 악성 링크 삽입
![03-inquiry-write-with-malicious-link](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/10-admin-csrf-security/03-inquiry-write-with-malicious-link.png)

### 4. 관리자가 문의 상세에서 링크를 확인하고 클릭
![04-admin-opened-inquiry-with-link](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/10-admin-csrf-security/04-admin-opened-inquiry-with-link.png)

### 5. 공격자 서버(8989)에서 관리자 요청 수신 확인
![06-attacker-server-request-received](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/10-admin-csrf-security/06-attacker-server-request-received.png)

### 6. 관리자 세션으로 포인트 사용이 수행된 결과
![05-admin-point-changed-after-csrf](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/10-admin-csrf-security/05-admin-point-changed-after-csrf.png)

## 영향
- 관리자가 의도하지 않은 상태 변경 요청이 관리자 세션으로 수행될 수 있다.
- 문의 확인과 같은 정상 업무 흐름 안에서 공격이 유도될 수 있다.
- 동일한 방식으로 포인트 사용 외 다른 관리자 기능에도 영향을 줄 수 있다.
- 사용자의 브라우저가 공격자 페이지를 열기만 해도 서버 상태가 변경될 수 있어, 요청 출처 신뢰가 무너진다.

## 대응 방안
- 상태 변경 요청에 CSRF 토큰을 추가하고 서버에서 세션 기준으로 검증한다.
- 보조 방어로 Origin/Referer를 검증한다.
- 문의 본문은 HTML을 그대로 렌더링하지 않고 이스케이프하여 링크 삽입을 어렵게 한다.
- `SameSite` 쿠키 정책을 보조적으로 적용하되, CSRF 토큰을 대체 수단으로 사용하지 않는다.

## 수정 코드 예시

파일: `src/main/webapp/WEB-INF/views/point_view.jsp`

```jsp
<form method="post" action="${pageContext.request.contextPath}/point/use">
    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
    <input type="number" name="amount" min="1" max="${jsrUser.point}" required>
    <button type="submit">사용</button>
</form>
```

파일: `src/main/java/com/jsr/ctf/PointServlet.java`

```java
String csrfToken = request.getParameter("csrfToken");
String sessionToken = (String) request.getSession().getAttribute("csrfToken");

if (sessionToken == null || !sessionToken.equals(csrfToken)) {
    response.sendRedirect(request.getContextPath() + "/point?error=csrf");
    return;
}
```

파일: `src/main/webapp/WEB-INF/views/board_detail_view.jsp`

```jsp
<div class="post-body"><c:out value="${jsrBoard.content}" /></div>
```

## 대응 코드 동작 설명
정상 사용자는 서버가 발급한 CSRF 토큰을 함께 제출해야만 포인트 사용 요청이 처리된다.  
외부 공격 페이지는 세션에 저장된 토큰 값을 알 수 없으므로 자동 제출 폼만으로는 요청이 성공할 수 없다.

또한 문의 본문을 `<c:out>`으로 출력하면 공격자가 삽입한 `<a href>` 태그가 문자열 그대로 표시되므로, 관리자 화면에서 악성 링크를 클릭하게 만드는 유도 지점도 제거할 수 있다.

## 대응 코드 증적자료
추후 추가 예정
