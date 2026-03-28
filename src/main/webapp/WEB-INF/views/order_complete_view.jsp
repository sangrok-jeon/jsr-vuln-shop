<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>주문 완료 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .complete-wrap {
        max-width: 560px;
        margin: 60px auto 80px;
        padding: 0 24px;
        text-align: center;
        animation: fadeUp 0.4s ease both;
    }
    @keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:none} }

    .success-icon {
        font-size: 64px;
        margin-bottom: 16px;
        display: block;
        animation: pop 0.5s cubic-bezier(.36,.07,.19,.97) both;
    }
    @keyframes pop {
        0%   { transform: scale(0.5); opacity:0; }
        80%  { transform: scale(1.1); }
        100% { transform: scale(1);   opacity:1; }
    }

    .complete-title {
        font-size: 1.8rem;
        font-weight: 800;
        color: #f1f5f9;
        margin-bottom: 6px;
        letter-spacing: -0.5px;
    }
    .complete-sub {
        font-size: 14px;
        color: #64748b;
        margin-bottom: 32px;
    }

    /* 주문 요약 카드 */
    .summary-card {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 16px;
        overflow: hidden;
        margin-bottom: 24px;
        text-align: left;
    }
    .summary-header {
        background: rgba(56,189,248,0.08);
        border-bottom: 1px solid #334155;
        padding: 14px 20px;
        font-size: 12px;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-weight: 600;
    }

    /* 상품 이미지 + 정보 */
    .summary-product {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 18px 20px;
        border-bottom: 1px solid #334155;
    }
    .summary-img {
        width: 72px; height: 72px;
        border-radius: 10px; border:1px solid #334155;
        background: #263248; font-size:32px;
        display:flex; align-items:center; justify-content:center;
        flex-shrink:0; overflow:hidden;
    }
    .summary-img img { width:100%; height:100%; object-fit:cover; }
    .summary-prod-name { font-size:15px; font-weight:700; color:#f1f5f9; margin-bottom:3px; }
    .summary-prod-qty  { font-size:13px; color:#64748b; }

    /* 금액 정보 */
    .summary-rows { padding: 0 20px; }
    .summary-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid #1a2740;
        font-size: 14px;
    }
    .summary-row:last-child { border-bottom:none; }
    .summary-row .s-label { color: #94a3b8; }
    .summary-row .s-value { font-family:monospace; font-weight:700; color:#e2e8f0; }
    .summary-row.total .s-label { color:#f1f5f9; font-weight:700; }
    .summary-row.total .s-value { color:#38bdf8; font-size:18px; }

    /* 버튼 그룹 */
    .action-row {
        display: flex;
        gap: 12px;
        justify-content: center;
    }
    .btn-outline {
        background: transparent;
        border: 1px solid #334155;
        color: #94a3b8;
        border-radius: 10px;
        padding: 11px 22px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        text-decoration: none;
        transition: all 0.15s;
        font-family: inherit;
    }
    .btn-outline:hover { border-color:#64748b; color:#f1f5f9; }
.vuln-badge {
        display: inline-block;
        background: rgba(239,68,68,0.1);
        border: 1px solid rgba(239,68,68,0.3);
        border-radius: 6px;
        padding: 6px 14px;
        font-size: 12px;
        color: #fca5a5;
        margin-bottom: 24px;
    }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="complete-wrap">
    <span class="success-icon">OK</span>
    <div class="complete-title">결제 완료!</div>
    <div class="complete-sub">주문이 성공적으로 접수되었습니다.</div>

    <c:if test="${jsrOrder != null}">

    <%-- 가격 변조 감지 표시 (실제 가격과 다를 때) --%>
    <c:if test="${jsrOrder.price != jsrOrder.totalPrice / jsrOrder.quantity}">
        
</c:if>

    <div class="summary-card">
        <div class="summary-header">주문 #${jsrOrder.orderId} 상세</div>

        <%-- 상품 이미지 + 이름 --%>
        <div class="summary-product">
            <div class="summary-img">
                <c:choose>
                    <c:when test="${not empty jsrOrder.imageUrl}">
                        <img src="<%= request.getContextPath() %>/static/images/${jsrOrder.imageUrl}"
                             alt="${jsrOrder.productName}"
                             onerror="this.style.display='none';this.parentNode.innerHTML='IMG'">
                    </c:when>
                    <c:otherwise>IMG</c:otherwise>
                </c:choose>
            </div>
            <div>
                <div class="summary-prod-name">${jsrOrder.productName}</div>
                <div class="summary-prod-qty">수량 ${jsrOrder.quantity}개</div>
            </div>
        </div>

        <div class="summary-rows">
            <div class="summary-row">
                <span class="s-label">주문번호</span>
                <span class="s-value" style="color:#64748b">#${jsrOrder.orderId}</span>
            </div>
            <div class="summary-row">
                <span class="s-label">단가</span>
                <span class="s-value">
                    <fmt:formatNumber value="${jsrOrder.price}" pattern="#,###"/>원
                </span>
            </div>
            <div class="summary-row">
                <span class="s-label">수량</span>
                <span class="s-value">${jsrOrder.quantity}개</span>
            </div>
            <div class="summary-row">
                <span class="s-label">배송 주소</span>
                <span class="s-value" style="font-family:inherit;font-size:13px;color:#94a3b8">${jsrOrder.address}</span>
            </div>
            <div class="summary-row total">
                <span class="s-label">결제 금액</span>
                <span class="s-value">
                    <fmt:formatNumber value="${jsrOrder.totalPrice}" pattern="#,###"/>원
                </span>
            </div>
        </div>
    </div>

    </c:if>

    <div class="action-row">
        <a href="<%= request.getContextPath() %>/order/list" class="btn-outline">주문 내역 보기</a>
        <a href="<%= request.getContextPath() %>/products" class="jsr-btn">쇼핑 계속하기</a>
    </div>
</div>
</body>
</html>
