<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>주문 상세 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .detail-wrap {
        max-width: 720px;
        margin: 36px auto 60px;
        padding: 0 24px;
        animation: fadeUp 0.35s ease both;
    }
    @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }
    .detail-header { margin-bottom:24px; padding-bottom:16px; border-bottom:1px solid #334155; }
    .detail-header h2 { font-size:1.3rem; margin:0; }
/* 상품 이미지 + 정보 카드 */
    .product-banner {
        background:#1e293b; border:1px solid #334155; border-radius:12px;
        padding:20px; display:flex; align-items:center; gap:20px; margin-bottom:24px;
    }
    .banner-img {
        width:100px; height:100px; border-radius:12px; border:1px solid #334155;
        display:flex; align-items:center; justify-content:center;
        background:#263248; font-size:44px; flex-shrink:0; overflow:hidden;
    }
    .banner-img img { width:100%; height:100%; object-fit:cover; }
    .banner-name { font-size:18px; font-weight:800; color:#f1f5f9; margin-bottom:6px; }
    .banner-price { font-size:22px; font-weight:800; color:#38bdf8; font-family:monospace; }
    .banner-qty { font-size:13px; color:#64748b; margin-top:4px; }

    /* 상세 테이블 */
    .info-table {
        width:100%; border-collapse:collapse; border-radius:12px; overflow:hidden;
    }
    .info-table tr { border-bottom:1px solid #1e293b; }
    .info-table tr:last-child { border-bottom:none; }
    .info-table th {
        background:#1e293b; color:#64748b; font-size:13px; font-weight:600;
        padding:14px 20px; text-align:left; width:140px; white-space:nowrap;
    }
    .info-table td {
        background:#0f172a; color:#e2e8f0; font-size:14px;
        padding:14px 20px;
    }

    .status-badge {
        display:inline-block; font-size:12px; font-weight:700;
        padding:4px 12px; border-radius:6px;
    }
    .s-PAID      { background:rgba(56,189,248,0.15); color:#38bdf8; border:1px solid rgba(56,189,248,0.3); }
    .s-SHIPPING  { background:rgba(245,158,11,0.15); color:#f59e0b; border:1px solid rgba(245,158,11,0.3); }
    .s-DELIVERED { background:rgba(34,197,94,0.15);  color:#22c55e; border:1px solid rgba(34,197,94,0.3); }
    .s-CANCELLED { background:rgba(239,68,68,0.15);  color:#ef4444; border:1px solid rgba(239,68,68,0.3); }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="detail-wrap">
    <div class="detail-header"><h2>주문 상세</h2></div>
<c:choose>
    <c:when test="${jsrOrder != null}">

        <%-- 상품 이미지 배너 --%>
        <div class="product-banner">
            <div class="banner-img">
                <c:choose>
                    <c:when test="${not empty jsrOrder.imageUrl}">
                        <img src="<%= request.getContextPath() %>/static/images/${jsrOrder.imageUrl}"
                             alt="${jsrOrder.productName}"
                              onerror="this.style.display='none';this.parentNode.innerHTML='이미지'">
                    </c:when>
                    <c:otherwise>이미지</c:otherwise>
                </c:choose>
            </div>
            <div>
                <div class="banner-name">${jsrOrder.productName}</div>
                <div class="banner-price">
                    <fmt:formatNumber value="${jsrOrder.totalPrice}" pattern="#,###"/>원
                </div>
                <div class="banner-qty">수량 ${jsrOrder.quantity}개</div>
            </div>
        </div>

        <%-- 주문 정보 테이블 --%>
        <table class="info-table">
            <tr>
                <th>주문번호</th>
                <td style="font-family:monospace;font-weight:700;color:#38bdf8">#${jsrOrder.orderId}</td>
            </tr>
            <tr>
                <th>주문자</th>
                <td style="font-weight:600">${jsrOrder.username}</td>
            </tr>
            <tr>
                <th>상품명</th>
                <td>${jsrOrder.productName}</td>
            </tr>
            <tr>
                <th>수량</th>
                <td>${jsrOrder.quantity}개</td>
            </tr>
            <tr>
                <th>단가</th>
                <td style="font-family:monospace">
                    <fmt:formatNumber value="${jsrOrder.price}" pattern="#,###"/>원
                </td>
            </tr>
            <tr>
                <th>결제금액</th>
                <td style="font-family:monospace;font-weight:700;color:#38bdf8;font-size:15px">
                    <fmt:formatNumber value="${jsrOrder.totalPrice}" pattern="#,###"/>원
                </td>
            </tr>
            <tr>
                <th>배송주소</th>
                <td>${jsrOrder.address}</td>
            </tr>
            <tr>
                <th>상태</th>
                <td><span class="status-badge s-${jsrOrder.status}">${jsrOrder.status}</span></td>
            </tr>
            <tr>
                <th>주문일</th>
                <td style="font-family:monospace;color:#64748b">${jsrOrder.createdAt}</td>
            </tr>
        </table>

        <p style="margin-top:20px">
            <a href="<%= request.getContextPath() %>/order/list" style="font-size:13px;color:#64748b">← 주문 목록</a>
        </p>

    </c:when>
    <c:otherwise>
        <p style="color:#64748b">주문 정보를 찾을 수 없습니다.</p>
        <a href="<%= request.getContextPath() %>/order/list">← 주문 목록</a>
    </c:otherwise>
    </c:choose>
</div>
</body>
</html>
