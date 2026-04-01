# 10. Admin CSRF Security

## 개요
1:1 문의 본문이 HTML 링크를 그대로 렌더링하고, 관리자 기능 요청에 대한 CSRF 방어가 없어 관리자가 문의글에 포함된 악성 링크를 클릭하면 관리자 세션으로 상태 변경 요청이 실행된다.  
로컬 테스트 환경에서는 관리자가 문의글의 링크를 클릭한 뒤 `/point/use` 요청이 자동 전송되어 관리자 포인트가 변경되는 것을 확인하였다.

## 진입점
- `/jsr/board?tab=INQUIRY`
- `/jsr/board/detail`
- `/jsr/point/use`

## 포함 이슈

| 구분 | 취약점 | 설명 |
|------|--------|------|
| 주요 취약점 | CSRF | 관리자 기능 요청에 CSRF 토큰 검증이 없어, 관리자가 외부 링크를 열면 관리자 세션으로 상태 변경 요청이 수행된다. |
| 관련 이슈 | HTML Link Injection | 문의 본문이 이스케이프 없이 렌더링되어 공격자가 삽입한 링크가 관리자 화면에서 그대로 클릭 가능하다. |

## 취약한 부분
문의글 본문은 HTML 이스케이프 없이 그대로 출력되므로 공격자는 문의 내용에 외부 링크를 삽입할 수 있다.  
관리자가 문의 내용을 확인하는 과정에서 해당 링크를 클릭하면 외부 페이지의 자동 제출 폼이 관리자 세션 쿠키를 포함한 상태로 `/point/use` 요청을 전송한다.  
서버는 이 요청이 정상 관리자 요청인지, 사용자가 직접 의도한 요청인지 검증하지 않으므로 관리자 포인트가 비정상적으로 변경된다.

## 취약한 코드
파일: `src/main/webapp/WEB-INF/views/board_detail_view.jsp`

```jsp
<div class="post-body">${jsrBoard.content}</div>
```

파일: `src/main/java/com/jsr/ctf/PointServlet.java`

```java
} else if (path.equals("/point/use")) {
    int amount = Integer.parseInt(request.getParameter("amount"));
    if (amount <= 0) {
        response.sendRedirect(request.getContextPath() + "/point?error=invalid");
        return;
    }

    try {
        JsrUser fresh = getFreshUser(user.getUserId());
        usePoint(user.getUserId(), amount);
        JsrUser updated = getFreshUser(user.getUserId());
        request.getSession().setAttribute("jsrUser", updated);
        response.sendRedirect(request.getContextPath() + "/point?used=1");
    } catch (Exception e) {
        throw new ServletException(e);
    }
}
```

파일: 외부 테스트 페이지(`jsr.html`)

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
문의글 상세 화면은 `${jsrBoard.content}`를 그대로 출력하므로, 공격자가 본문에 삽입한 `<a href="...">` 링크가 관리자 화면에서 클릭 가능한 형태로 렌더링된다.  
관리자가 링크를 클릭하면 외부 페이지의 자동 제출 폼이 실행되며, 브라우저는 관리자 세션 쿠키를 포함한 상태로 `/jsr/point/use` 요청을 전송한다.  
`PointServlet`은 이 요청에 대해 CSRF 토큰이나 Referer/Origin 검증 없이 `amount` 파라미터만 받아 포인트 사용 로직을 수행하므로, 관리자의 의도와 무관하게 상태 변경이 발생한다.

## 취약한 코드 증적자료
### 1. 외부 CSRF 페이지 코드
![외부 CSRF 페이지 코드](images/10-admin-csrf-security/01-csrf-page-code.png)

### 2. 관리자 포인트 변경 전 상태
![관리자 포인트 변경 전](images/10-admin-csrf-security/02-admin-point-before-csrf.png)

### 3. 공격자가 악성 링크를 포함한 문의글 작성
![악성 링크 문의 작성](images/10-admin-csrf-security/03-inquiry-write-with-malicious-link.png)

### 4. 관리자가 문의글을 열어 악성 링크 확인
![관리자가 문의글에서 링크 확인](images/10-admin-csrf-security/04-admin-opened-inquiry-with-link.png)

### 5. 외부 8989 서버에서 요청 수신 확인
![외부 서버 요청 수신 확인](images/10-admin-csrf-security/06-attacker-server-request-received.png)

### 6. 링크 클릭 후 관리자 포인트 변경 결과
![관리자 포인트 변경 결과](images/10-admin-csrf-security/05-admin-point-changed-after-csrf.png)

## 영향
- 관리자가 의도하지 않은 상태 변경 요청이 관리자 세션으로 실행될 수 있다.
- 포인트, 주문 상태, 권한 등 관리자 기능이 외부 페이지에 의해 변조될 수 있다.
- 문의글 확인 같은 정상 업무 흐름만으로도 공격이 성립해 현실성이 높다.

## 대응 방안
- 관리자 상태 변경 요청에 CSRF 토큰 검증을 추가한다.
- 문의 본문 출력 시 HTML 이스케이프를 적용해 임의 링크 렌더링을 차단한다.
- 필요시 Origin/Referer 검증을 보조적으로 적용한다.
- 상태 변경 기능은 사용자 의도 확인 절차를 추가한다.

## 수정 코드 예시
파일: `src/main/java/com/jsr/ctf/PointServlet.java`

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    HttpSession session = request.getSession();
    if (session.getAttribute("csrfToken") == null) {
        session.setAttribute("csrfToken", UUID.randomUUID().toString());
    }
    // ...
}

protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String csrfToken = request.getParameter("csrfToken");
    String sessionToken = (String) request.getSession().getAttribute("csrfToken");

    if (sessionToken == null || csrfToken == null || !sessionToken.equals(csrfToken)) {
        response.sendRedirect(request.getContextPath() + "/point?error=csrf");
        return;
    }
    // ...
}
```

파일: `src/main/webapp/WEB-INF/views/point_view.jsp`

```jsp
<form action="<%= request.getContextPath() %>/point/use" method="post" class="point-form">
    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
    <input type="number" name="amount" placeholder="사용할 금액 (P)" required>
    <button type="submit" class="jsr-btn danger">사용</button>
</form>
```

파일: `src/main/webapp/WEB-INF/views/board_detail_view.jsp`

```jsp
<div class="post-body"><c:out value="${jsrBoard.content}" /></div>
```

## 대응 코드 동작 설명
포인트 페이지 진입 시 서버가 세션에 CSRF 토큰을 생성하고, 포인트 사용/충전 폼에 hidden input으로 포함시킨다.  
상태 변경 요청이 들어오면 서버는 요청의 `csrfToken`과 세션의 토큰을 비교하고, 값이 없거나 일치하지 않으면 즉시 차단한다.  
또한 문의 본문은 `<c:out>`으로 출력하여 공격자가 삽입한 HTML 링크가 실행 가능한 요소가 아니라 일반 문자열로만 표시되도록 변경한다.

## 대응 코드 증적자료
대응 증적은 추후 추가 예정입니다.
