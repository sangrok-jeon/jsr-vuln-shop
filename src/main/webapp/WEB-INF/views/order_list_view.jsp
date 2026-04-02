<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>주문 내역 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .list-wrap {
        max-width: 900px;
        margin: 36px auto 60px;
        padding: 0 24px;
        animation: fadeUp 0.35s ease both;
    }
    @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }
    .list-header { margin-bottom:24px; padding-bottom:16px; border-bottom:1px solid #334155; }
    .list-header h2 { font-size:1.3rem; margin:0 0 4px; }
.thumb {
        width:52px; height:52px; border-radius:8px;
        object-fit:cover; border:1px solid #334155; display:block;
    }
    .thumb-ph {
        width:52px; height:52px; border-radius:8px;
        background:#263248; border:1px solid #334155;
        display:flex; align-items:center; justify-content:center; font-size:22px;
    }

    .status-badge {
        display:inline-block; font-size:11px; font-weight:700;
        padding:3px 9px; border-radius:6px; letter-spacing:.3px;
    }
    .s-PAID      { background:rgba(56,189,248,0.15); color:#38bdf8; border:1px solid rgba(56,189,248,0.3); }
    .s-SHIPPING  { background:rgba(245,158,11,0.15); color:#f59e0b; border:1px solid rgba(245,158,11,0.3); }
    .s-DELIVERED { background:rgba(34,197,94,0.15);  color:#22c55e; border:1px solid rgba(34,197,94,0.3); }
    .s-CANCELLED { background:rgba(239,68,68,0.15);  color:#ef4444; border:1px solid rgba(239,68,68,0.3); }

    .empty-state {
        text-align:center; padding:60px 20px; color:#475569;
    }
    .empty-state .e-icon { font-size:48px; margin-bottom:12px; }
    .empty-state .e-text { font-size:15px; margin-bottom:16px; }
    .notice-error {
        margin: 0 0 20px;
        padding: 14px 16px;
        border-radius: 12px;
        border: 1px solid rgba(239,68,68,0.35);
        background: rgba(127,29,29,0.22);
        color: #fecaca;
        font-size: 14px;
        line-height: 1.5;
    }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="list-wrap">
    <div class="list-header">
        <h2>주문 내역</h2>
    </div>
    <c:if test="${param.error eq 'idor'}">
        <div class="notice-error">
            다른 사용자의 주문 상세에는 접근할 수 없습니다.
        </div>
    </c:if>
<c:choose>
    <c:when test="${empty jsrOrders}">
        <div class="empty-state">
            <div class="e-icon">ORD</div>
            <div class="e-text">아직 주문 내역이 없습니다.</div>
            <a href="<%= request.getContextPath() %>/products" class="jsr-btn">상품 보러 가기</a>
        </div>
    </c:when>
    <c:otherwise>
    <table class="jsr-table">
        <thead>
        <tr>
            <th>이미지</th>
            <th>주문번호</th>
            <th>상품명</th>
            <th>수량</th>
            <th>결제금액</th>
            <th>상태</th>
            <th>주문일</th>
            <th>상세</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="o" items="${jsrOrders}">
        <tr>
            <%-- 썸네일 --%>
            <td style="padding:8px 10px">
                <c:choose>
                    <c:when test="${not empty o.imageUrl}">
                        <img src="<%= request.getContextPath() %>/static/images/${o.imageUrl}"
                             alt="${o.productName}" class="thumb"
                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                        <span class="thumb-ph" style="display:none">이미지</span>
                    </c:when>
                    <c:otherwise><span class="thumb-ph">이미지</span></c:otherwise>
                </c:choose>
            </td>
            <td style="color:#64748b;font-family:monospace;font-weight:700">#${o.orderId}</td>
            <td style="font-weight:600">${o.productName}</td>
            <td style="color:#94a3b8">${o.quantity}개</td>
            <td style="color:#38bdf8;font-family:monospace;font-weight:700">
                <fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/>원
            </td>
            <td><span class="status-badge s-${o.status}">${o.status}</span></td>
            <td style="color:#64748b;font-size:13px;font-family:monospace">${o.createdAt}</td>
            <td>
                <a href="<%= request.getContextPath() %>/order/detail?orderId=${o.orderId}"
                   class="jsr-btn-sm">상세</a>
            </td>
        </tr>
        </c:forEach>
        </tbody>
    </table>
    </c:otherwise>
    </c:choose>
</div>
</body>
</html>
