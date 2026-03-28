<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>마이페이지 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .mypage-wrap {
        max-width: 860px;
        margin: 36px auto 60px;
        padding: 0 24px;
        animation: fadeUp 0.35s ease both;
    }
    @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }

    .mypage-header {
        display: flex; align-items: center; gap: 16px;
        margin-bottom: 28px; padding-bottom: 18px;
        border-bottom: 1px solid #334155;
    }
    .avatar {
        width: 52px; height: 52px; border-radius: 50%;
        background: linear-gradient(135deg,#0ea5e9,#6366f1);
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; font-weight: 800; color: #fff; flex-shrink: 0;
    }
    .mypage-header .u-name { font-size:1.2rem; font-weight:800; color:#f1f5f9; }
    .mypage-header .u-role {
        font-size:11px; font-weight:700; padding:2px 8px; border-radius:4px;
        display:inline-block; margin-left:8px;
    }
    .role-admin { background:#ef4444; color:#fff; }
    .role-user  { background:#334155; color:#94a3b8; }
    .mypage-header .u-point { font-size:13px; color:#64748b; margin-top:2px; }
/* 2컬럼 그리드 */
    .mypage-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 28px;
    }
    @media (max-width: 640px) { .mypage-grid { grid-template-columns: 1fr; } }

    .form-card {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 12px;
        padding: 22px;
    }
    .form-card h3 {
        font-size: 14px; font-weight: 700; color: #f1f5f9;
        margin-bottom: 16px; padding-bottom: 10px;
        border-bottom: 1px solid #334155;
        display: flex; align-items: center; gap: 8px;
    }
    .form-field { margin-bottom: 12px; }
    .form-field label {
        display: block; font-size: 11px; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.4px; margin-bottom: 5px;
    }
    .form-field .jsr-input { width: 100%; box-sizing: border-box; }

    /* 알림 */
    .alert { padding:10px 14px; border-radius:8px; font-size:13px; margin-bottom:20px; }
    .alert-success { background:rgba(34,197,94,0.1); border:1px solid rgba(34,197,94,0.3); color:#86efac; }

    /* 포인트 카드 */
    .point-card {
        background: linear-gradient(135deg, rgba(56,189,248,0.1) 0%, rgba(99,102,241,0.08) 100%);
        border: 1px solid rgba(56,189,248,0.25);
        border-radius: 12px;
        padding: 20px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 28px;
    }
    .point-card .pc-label { font-size:13px; color:#64748b; margin-bottom:4px; }
    .point-card .pc-value {
        font-size: 2rem; font-weight: 800;
        color: #38bdf8; font-family: monospace; line-height:1;
    }
    .point-card .pc-unit { font-size:14px; color:#64748b; margin-left:4px; font-family:inherit; font-weight:400; }

    /* 최근 주문 */
    .section-title {
        font-size:14px; color:#94a3b8; text-transform:uppercase;
        letter-spacing:0.5px; margin-bottom:14px;
    }
    .status-badge {
        display:inline-block; font-size:11px; font-weight:700;
        padding:2px 8px; border-radius:4px;
    }
    .s-PAID      { background:rgba(56,189,248,0.15); color:#38bdf8; border:1px solid rgba(56,189,248,0.3); }
    .s-SHIPPING  { background:rgba(245,158,11,0.15); color:#f59e0b; border:1px solid rgba(245,158,11,0.3); }
    .s-DELIVERED { background:rgba(34,197,94,0.15);  color:#22c55e; border:1px solid rgba(34,197,94,0.3); }
    .s-CANCELLED { background:rgba(239,68,68,0.15);  color:#ef4444; border:1px solid rgba(239,68,68,0.3); }

    .order-thumb {
        width:40px; height:40px; border-radius:6px; object-fit:cover;
        border:1px solid #334155; display:block;
    }
    .order-thumb-ph {
        width:40px; height:40px; border-radius:6px;
        background:#263248; border:1px solid #334155;
        display:flex; align-items:center; justify-content:center; font-size:18px;
    }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="mypage-wrap">

    <%-- 헤더 --%>
    <div class="mypage-header">
        <div class="avatar">${jsrUser.username.substring(0,1).toUpperCase()}</div>
        <div>
            <div class="u-name">
                ${jsrUser.username}
                <span class="u-role ${jsrUser.role == 'ADMIN' ? 'role-admin' : 'role-user'}">${jsrUser.role}</span>
            </div>
            <div class="u-point">포인트 <strong style="color:#38bdf8">${jsrUser.point}P</strong></div>
        </div>
    </div>

    <%-- 알림 --%>
    <% if ("1".equals(request.getParameter("updated"))) { %>
    <div class="alert alert-success">정보가 수정되었습니다.</div>
    <% } %>
    <% if ("1".equals(request.getParameter("pwChanged"))) { %>
    <div class="alert alert-success">비밀번호가 변경되었습니다.</div>
    <% } %>
<%-- 포인트 카드 --%>
    <div class="point-card">
        <div>
            <div class="pc-label">보유 포인트</div>
            <div class="pc-value">
                <fmt:formatNumber value="${jsrUser.point}" pattern="#,###"/>
                <span class="pc-unit">P</span>
            </div>
        </div>
        <a href="<%= request.getContextPath() %>/point" class="jsr-btn">포인트 충전/사용 →</a>
    </div>

    <%-- 정보 수정 폼 --%>
    <div class="mypage-grid">
        <%-- 기본 정보 수정 --%>
        <div class="form-card">
            <h3>기본 정보 수정</h3>
<form method="post" action="<%= request.getContextPath() %>/mypage/update">
                <div class="form-field">
                    <label>이메일</label>
                    <input type="email" name="email" value="${jsrUser.email}" class="jsr-input">
                </div>
                <div class="form-field">
                    <label>주소</label>
                    <input type="text" name="address" value="${jsrUser.address}" class="jsr-input">
                </div>
                <div class="form-field">
                    <label>연락처</label>
                    <input type="text" name="phone" value="${jsrUser.phone}" class="jsr-input">
                </div>
                <input type="submit" value="정보 수정" class="jsr-btn" style="margin-top:4px">
            </form>
        </div>

        <%-- 비밀번호 변경 --%>
        <div class="form-card">
            <h3>비밀번호 변경</h3>
<form method="post" action="<%= request.getContextPath() %>/mypage/pw_change">
                <div class="form-field">
                    <label>새 비밀번호 
</label>
                    <input type="password" name="password" class="jsr-input"
                           placeholder="새 비밀번호 입력">
                </div>
                <div class="form-field">
                    <label>비밀번호 확인</label>
                    <input type="password" name="password2" class="jsr-input"
                           placeholder="비밀번호 재입력">
                </div>
                <input type="submit" value="비밀번호 변경" class="jsr-btn" style="margin-top:4px">
            </form>
        </div>
    </div>

    <%-- 최근 주문 --%>
    <div class="section-title">최근 주문</div>
    <table class="jsr-table">
        <thead>
        <tr>
            <th>이미지</th>
            <th>주문번호</th>
            <th>상품명</th>
            <th>결제금액</th>
            <th>상태</th>
            <th>주문일</th>
            <th></th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="o" items="${jsrOrders}" varStatus="s">
        <c:if test="${s.index < 5}">
        <tr>
            <td style="padding:8px 10px">
                <c:choose>
                    <c:when test="${not empty o.imageUrl}">
                        <img src="<%= request.getContextPath() %>/static/images/${o.imageUrl}"
                             alt="${o.productName}" class="order-thumb"
                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                        <span class="order-thumb-ph" style="display:none">IMG</span>
                    </c:when>
                    <c:otherwise><span class="order-thumb-ph">IMG</span></c:otherwise>
                </c:choose>
            </td>
            <td style="color:#64748b;font-family:monospace">#${o.orderId}</td>
            <td style="font-weight:600">${o.productName}</td>
            <td style="color:#38bdf8;font-family:monospace;font-weight:700">
                <fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/>원
            </td>
            <td><span class="status-badge s-${o.status}">${o.status}</span></td>
            <td style="color:#64748b;font-size:12px;font-family:monospace">${o.createdAt}</td>
            <td>
                <a href="<%= request.getContextPath() %>/order/detail?orderId=${o.orderId}"
                   class="jsr-btn-sm">상세</a>
            </td>
        </tr>
        </c:if>
        </c:forEach>
        <c:if test="${empty jsrOrders}">
        <tr><td colspan="7" style="text-align:center;padding:30px;color:#475569">주문 내역이 없습니다.</td></tr>
        </c:if>
        </tbody>
    </table>
    <c:if test="${not empty jsrOrders}">
    <p style="text-align:right;margin-top:10px">
        <a href="<%= request.getContextPath() %>/order/list" style="font-size:13px;color:#64748b">전체 주문 내역 →</a>
    </p>
    </c:if>
</div>
</body>
</html>
