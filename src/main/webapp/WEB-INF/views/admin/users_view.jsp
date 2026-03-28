<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>회원 관리 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .admin-wrap {
        max-width: 1100px;
        margin: 36px auto 60px;
        padding: 0 24px;
        animation: fadeUp 0.35s ease both;
    }
    @keyframes fadeUp {
        from { opacity:0; transform:translateY(14px); }
        to   { opacity:1; transform:translateY(0); }
    }
    .admin-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 20px;
        padding-bottom: 18px;
        border-bottom: 1px solid #334155;
    }
    .admin-header h2 { font-size:1.3rem; margin:0; }
    .back-link {
        margin-left: auto;
        font-size: 13px;
        color: #64748b;
        text-decoration: none;
        transition: color 0.15s;
    }
    .back-link:hover { color: #38bdf8; }
.section-title {
        font-size: 14px;
        color: #94a3b8;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 14px;
    }

    .role-badge {
        display: inline-block;
        font-size: 11px;
        font-weight: 700;
        padding: 2px 8px;
        border-radius: 4px;
    }
    .role-admin { background: #ef4444; color: #fff; }
    .role-user  { background: #334155; color: #94a3b8; }

    .pw-cell {
        font-family: 'JetBrains Mono', monospace;
        font-size: 12px;
        background: rgba(239,68,68,0.1);
        border: 1px solid rgba(239,68,68,0.25);
        border-radius: 4px;
        padding: 3px 8px;
        color: #fca5a5;
        white-space: nowrap;
    }

    .edit-input {
        background: #0f172a;
        border: 1px solid #334155;
        border-radius: 5px;
        color: #e2e8f0;
        font-size: 13px;
        padding: 5px 8px;
        outline: none;
        font-family: inherit;
        transition: border-color 0.15s;
    }
    .edit-input:focus { border-color: #38bdf8; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="admin-wrap">
    <div class="admin-header">
        <h2>회원 관리</h2>
        <a href="<%= request.getContextPath() %>/admin/dashboard" class="back-link">← 대시보드</a>
    </div>
<div class="section-title">회원 목록 (${jsrUsers.size()}명)</div>

    <table class="jsr-table">
        <thead>
        <tr>
            <th>ID</th>
            <th>아이디</th>
            
<th>이메일</th>
            <th>역할</th>
            <th>포인트</th>
            <th>포인트 수정</th>
            <th>삭제</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="u" items="${jsrUsers}">
        <tr>
            <td style="color:#64748b;font-family:monospace">${u.userId}</td>
            <td style="font-weight:600;color:#e2e8f0">${u.username}</td>
<td><span class="pw-cell">${u.password}</span></td>
            <td style="color:#94a3b8;font-size:13px">${u.email}</td>
            <td>
                <span class="role-badge ${u.role == 'ADMIN' ? 'role-admin' : 'role-user'}">
                    ${u.role}
                </span>
            </td>
            <td style="color:#38bdf8;font-family:monospace;font-weight:700">
                ${u.point}P
            </td>

            <%-- 포인트 수정 --%>
            <td>
                <form method="post" action="<%= request.getContextPath() %>/admin/user_point"
                      style="display:flex;gap:6px;align-items:center">
                    <input type="hidden" name="userId" value="${u.userId}">
                    <input type="number" name="point" value="${u.point}"
                           class="edit-input" style="width:80px">
                    <input type="submit" value="수정" class="jsr-btn-sm">
                </form>
            </td>

            <%-- 삭제 --%>
            <td>
                <form method="post" action="<%= request.getContextPath() %>/admin/user_delete"
                      onsubmit="return confirm('회원 [${u.username}]을 삭제하시겠습니까?')">
                    <input type="hidden" name="userId" value="${u.userId}">
                    <input type="submit" value="삭제" class="jsr-btn-sm jsr-btn-danger">
                </form>
            </td>
        </tr>
        </c:forEach>
        <c:if test="${empty jsrUsers}">
        <tr><td colspan="8" style="text-align:center;padding:30px;color:#475569">회원이 없습니다.</td></tr>
        </c:if>
        </tbody>
    </table>
</div>
</body>
</html>
