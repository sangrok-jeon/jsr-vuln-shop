<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // 세션에서 로그인 정보 꺼내기 (일반적인 JSP 세션 키 대응)
    Object sessionUser = session.getAttribute("jsrUser");
    Object sessionUsername = session.getAttribute("username");
    Object sessionRole = session.getAttribute("role");
    Object sessionUserId = session.getAttribute("userId");

    String navUsername = null;
    String navRole = null;

    if (sessionUser != null) {
        try {
            navUsername = (String) sessionUser.getClass().getMethod("getUsername").invoke(sessionUser);
            navRole     = (String) sessionUser.getClass().getMethod("getRole").invoke(sessionUser);
        } catch (Exception e) { /* VO 없는 경우 무시 */ }
    }
    if (navUsername == null && sessionUsername != null) {
        navUsername = sessionUsername.toString();
    }
    if (navRole == null && sessionRole != null) {
        navRole = sessionRole.toString();
    }

    boolean isLoggedIn = (navUsername != null);
    boolean isAdmin    = "ADMIN".equalsIgnoreCase(navRole);

    pageContext.setAttribute("_navUsername", navUsername);
    pageContext.setAttribute("_navRole",     navRole);
    pageContext.setAttribute("_isLoggedIn",  isLoggedIn);
    pageContext.setAttribute("_isAdmin",     isAdmin);
%>
<style>
/* ── JSR Nav 스타일 ─────────────────────────────────── */
.jsr-nav {
    background: #1e293b;
    padding: 0 24px;
    display: flex;
    align-items: center;
    gap: 0;
    height: 52px;
    font-family: 'Segoe UI', sans-serif;
    font-size: 14px;
    box-shadow: 0 2px 6px rgba(0,0,0,.3);
    flex-wrap: wrap;
}
.jsr-nav .nav-brand {
    color: #38bdf8;
    font-weight: 700;
    font-size: 16px;
    text-decoration: none;
    margin-right: 20px;
    letter-spacing: -0.5px;
}
.jsr-nav a {
    color: #cbd5e1;
    text-decoration: none;
    padding: 6px 12px;
    border-radius: 6px;
    transition: background .15s, color .15s;
    white-space: nowrap;
}
.jsr-nav a:hover {
    background: #334155;
    color: #f1f5f9;
}
.jsr-nav .nav-sep {
    color: #475569;
    margin: 0 2px;
    user-select: none;
}
.jsr-nav .nav-admin-badge {
    background: #ef4444;
    color: #fff;
    font-size: 11px;
    font-weight: 700;
    padding: 2px 7px;
    border-radius: 10px;
    margin-left: 4px;
    vertical-align: middle;
}
.jsr-nav .nav-right {
    margin-left: auto;
    display: flex;
    align-items: center;
    gap: 4px;
}
.jsr-nav .nav-user {
    color: #94a3b8;
    font-size: 13px;
    padding: 4px 8px;
}
.jsr-nav .nav-user b {
    color: #38bdf8;
}
.jsr-nav .nav-logout {
    background: #dc2626;
    color: #fff !important;
    padding: 5px 12px;
    border-radius: 6px;
    font-weight: 600;
}
.jsr-nav .nav-logout:hover {
    background: #b91c1c !important;
    color: #fff !important;
}
.jsr-nav .nav-login-btn {
    background: #2563eb;
    color: #fff !important;
    padding: 5px 14px;
    border-radius: 6px;
    font-weight: 600;
}
.jsr-nav .nav-login-btn:hover {
    background: #1d4ed8 !important;
}
</style>

<nav class="jsr-nav">
    <%-- 브랜드 --%>
    <a class="nav-brand" href="<%= request.getContextPath() %>/products">🛒 JSR Shop</a>

    <c:if test="${_isLoggedIn}">
        <%-- 일반 메뉴 --%>
        <a href="<%= request.getContextPath() %>/products">상품 목록</a>
        <span class="nav-sep">|</span>
        <a href="<%= request.getContextPath() %>/cart">장바구니</a>
        <span class="nav-sep">|</span>
        <a href="<%= request.getContextPath() %>/order/list">주문 내역</a>
        <span class="nav-sep">|</span>
        <a href="<%= request.getContextPath() %>/mypage">마이페이지</a>
        <span class="nav-sep">|</span>
        <a href="<%= request.getContextPath() %>/board">💬 Q&amp;A</a>

        <%-- 관리자 메뉴 --%>
        <c:if test="${_isAdmin}">
            <span class="nav-sep">&nbsp;|</span>
            <a href="<%= request.getContextPath() %>/admin/dashboard">
                관리자 대시보드
                <span class="nav-admin-badge">ADMIN</span>
            </a>
        </c:if>

        <%-- 우측: 유저 정보 + 로그아웃 --%>
        <div class="nav-right">
            <span class="nav-user">
                <b>${_navUsername}</b>
                <c:if test="${_isAdmin}"> (관리자)</c:if>
                님
            </span>
            <a class="nav-logout" href="<%= request.getContextPath() %>/logout">로그아웃</a>
        </div>
    </c:if>

    <c:if test="${!_isLoggedIn}">
        <%-- 비로그인 시 --%>
        <a href="<%= request.getContextPath() %>/products">상품 목록</a>
        <div class="nav-right">
            <a class="nav-login-btn" href="<%= request.getContextPath() %>/login">로그인</a>
            <a href="<%= request.getContextPath() %>/register">회원가입</a>
        </div>
    </c:if>
</nav>
