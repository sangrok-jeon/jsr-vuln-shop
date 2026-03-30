<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>주문/결제 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .order-wrap {
        max-width: 720px;
        margin: 36px auto 60px;
        padding: 0 24px;
        animation: fadeUp 0.35s ease both;
    }
    @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }
    .order-header { margin-bottom:24px; padding-bottom:16px; border-bottom:1px solid #334155; }
    .order-header h2 { font-size:1.3rem; margin:0; }
.order-product-card {
        background:#1e293b; border:1px solid #334155; border-radius:12px;
        padding:16px; display:flex; align-items:center; gap:16px; margin-bottom:16px;
    }
    .order-img-box {
        width:80px; height:80px; border-radius:10px; border:1px solid #334155;
        display:flex; align-items:center; justify-content:center;
        background:#263248; font-size:36px; flex-shrink:0; overflow:hidden;
    }
    .order-img-box img { width:100%; height:100%; object-fit:cover; }
    .op-name  { font-size:16px; font-weight:700; color:#f1f5f9; margin-bottom:4px; }
    .op-price { font-size:18px; font-weight:800; color:#38bdf8; font-family:monospace; }
    .op-qty   { font-size:13px; color:#64748b; margin-top:3px; }

    .point-status {
        background:#1e293b; border:1px solid #334155; border-radius:12px;
        padding:20px 24px; margin-bottom:20px;
    }
    .ps-title { font-size:12px; color:#64748b; text-transform:uppercase; letter-spacing:.5px; margin-bottom:12px; }
    .ps-row {
        display:flex; justify-content:space-between; align-items:center;
        padding:9px 0; border-bottom:1px solid #263248; font-size:14px;
    }
    .ps-row:last-child { border-bottom:none; }
    .ps-row .lbl { color:#94a3b8; }
    .ps-row .val { font-family:monospace; font-weight:700; }
    .v-have { color:#38bdf8; }
    .v-need { color:#f1f5f9; }
    .v-ok   { color:#22c55e; }
    .v-short{ color:#ef4444; }

    .error-box {
        background:rgba(239,68,68,0.08); border:1px solid rgba(239,68,68,0.3);
        border-left:3px solid #ef4444; border-radius:8px;
        padding:14px 18px; margin-bottom:20px;
    }
    .error-box .e-title { font-size:15px; font-weight:700; color:#fca5a5; margin-bottom:6px; }
    .error-box .e-desc  { font-size:13px; color:#94a3b8; line-height:1.7; }
    .e-link {
        display:inline-block; margin-top:10px;
        background:#ef4444; color:#fff; border-radius:8px;
        padding:7px 16px; font-size:13px; font-weight:600; text-decoration:none;
        transition:background 0.15s;
    }
    .e-link:hover { background:#dc2626; }

    .pay-form-box {
        background:#1e293b; border:1px solid #334155; border-radius:12px; padding:22px 24px;
    }
    .pay-form-box h3 { font-size:14px; color:#94a3b8; margin-bottom:14px; }
    .addr-input {
        width:100%; max-width:460px; background:#0f172a; border:1px solid #334155;
        border-radius:8px; color:#f1f5f9; font-size:14px; padding:10px 14px;
        outline:none; transition:border-color 0.15s; font-family:inherit; margin-bottom:16px;
    }
    .addr-input:focus { border-color:#38bdf8; }
    .pay-disabled { background:#334155!important; color:#475569!important; cursor:not-allowed!important; opacity:.6; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="order-wrap">
    <div class="order-header"><h2>주문 / 결제</h2></div>
<%-- 단일 상품 --%>
    <c:if test="${jsrProduct != null}">
    <div class="order-product-card">
        <div class="order-img-box">
            <c:choose>
                <c:when test="${not empty jsrProduct.imageUrl}">
                    <img src="<%= request.getContextPath() %>/static/images/${jsrProduct.imageUrl}"
                         alt="${jsrProduct.name}"
                         onerror="this.style.display='none';this.parentNode.innerHTML='이미지'">
                </c:when>
                <c:otherwise>
                    <c:choose>
                        <c:when test="${jsrProduct.category=='전자기기'}">PC</c:when>
                        <c:when test="${jsrProduct.category=='주변기기'}">ACC</c:when>
                        <c:when test="${jsrProduct.category=='저장장치'}">저장</c:when>
                        <c:when test="${jsrProduct.category=='보안용품'}">보안</c:when>
                        <c:otherwise>이미지</c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </div>
        <div>
            <div class="op-name">${jsrProduct.name}</div>
            <div class="op-price"><fmt:formatNumber value="${jsrProduct.price}" pattern="#,###"/>원</div>
            <div class="op-qty">수량 ${jsrQty}개</div>
        </div>
    </div>
    </c:if>

    <%-- 장바구니 주문 --%>
    <c:if test="${not empty jsrCartItems}">
    <c:forEach var="item" items="${jsrCartItems}">
    <div class="order-product-card">
        <div class="order-img-box">
            <c:choose>
                <c:when test="${not empty item.imageUrl}">
                    <img src="<%= request.getContextPath() %>/static/images/${item.imageUrl}"
                         alt="${item.productName}"
                         onerror="this.style.display='none';this.parentNode.innerHTML='이미지'">
                </c:when>
                <c:otherwise>이미지</c:otherwise>
            </c:choose>
        </div>
        <div>
            <div class="op-name">${item.productName}</div>
            <div class="op-price"><fmt:formatNumber value="${item.subTotal}" pattern="#,###"/>원</div>
            <div class="op-qty">수량 ${item.quantity}개 · 단가 <fmt:formatNumber value="${item.price}" pattern="#,###"/>원</div>
        </div>
    </div>
    </c:forEach>
    </c:if>

    <%-- 포인트 현황 --%>
    <div class="point-status">
        <div class="ps-title">포인트 결제 현황</div>
        <div class="ps-row">
            <span class="lbl">보유 포인트</span>
            <span class="val v-have"><fmt:formatNumber value="${jsrCurrentPoint}" pattern="#,###"/>P</span>
        </div>
        <div class="ps-row">
            <span class="lbl">결제 금액</span>
            <span class="val v-need"><fmt:formatNumber value="${jsrOrderTotal}" pattern="#,###"/>P</span>
        </div>
        <div class="ps-row">
            <span class="lbl">결제 후 잔액</span>
            <c:choose>
                <c:when test="${jsrCurrentPoint >= jsrOrderTotal}">
                    <span class="val v-ok"><fmt:formatNumber value="${jsrCurrentPoint - jsrOrderTotal}" pattern="#,###"/>P</span>
                </c:when>
                <c:otherwise>
                    <span class="val v-short">-<fmt:formatNumber value="${jsrOrderTotal - jsrCurrentPoint}" pattern="#,###"/>P 부족</span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%-- 포인트 부족 에러 --%>
    <c:if test="${not empty errorMsg}">
    <div class="error-box">
        <div class="e-title">${errorMsg}</div>
        <div class="e-desc">
            보유 포인트: <strong style="color:#38bdf8"><fmt:formatNumber value="${jsrCurrentPoint}" pattern="#,###"/>P</strong>
            / 필요: <strong style="color:#f1f5f9"><fmt:formatNumber value="${jsrOrderTotal}" pattern="#,###"/>P</strong><br>
            <strong style="color:#fca5a5"><fmt:formatNumber value="${jsrShortfall}" pattern="#,###"/>P</strong> 부족<br>
</div>
        <a href="<%= request.getContextPath() %>/point/charge" class="e-link">포인트 충전하기 →</a>
    </div>
    </c:if>

    <%-- 결제 폼 --%>
    <div class="pay-form-box">
        <h3>배송 정보</h3>
        <c:choose>
        <c:when test="${jsrCurrentPoint >= jsrOrderTotal}">
            <form method="post" action="<%= request.getContextPath() %>/order/proc">
                <c:if test="${jsrProduct != null}">
                <input type="hidden" name="productId"  value="${jsrProduct.productId}">
                <input type="hidden" name="quantity"   value="${jsrQty}">
                <input type="hidden" name="price"      value="${jsrProduct.price}">
                <input type="hidden" name="totalPrice" value="${jsrProduct.price * jsrQty}">
                </c:if>
                <c:if test="${not empty jsrCartItems}">
                <c:forEach var="item" items="${jsrCartItems}" varStatus="s">
                <c:if test="${s.first}">
                <input type="hidden" name="productId"  value="${item.productId}">
                <input type="hidden" name="quantity"   value="${item.quantity}">
                <input type="hidden" name="price"      value="${item.price}">
                <input type="hidden" name="totalPrice" value="${jsrCartTotal}">
                </c:if>
                </c:forEach>
                </c:if>
                <input type="text" name="address" class="addr-input"
                       value="${jsrUser.address}" placeholder="배송 주소를 입력하세요"><br>
                <input type="submit" value="포인트로 결제 완료" class="jsr-btn jsr-btn-danger">
            </form>
        </c:when>
        <c:otherwise>
            <input type="text" class="addr-input" disabled
                   value="${jsrUser.address}" placeholder="포인트를 충전 후 결제해주세요"><br>
            <button class="jsr-btn jsr-btn-danger pay-disabled" disabled>포인트 부족 — 결제 불가</button>
        </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>
