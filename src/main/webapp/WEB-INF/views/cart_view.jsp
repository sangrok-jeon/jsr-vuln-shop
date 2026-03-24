<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>장바구니 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .thumb {
        width: 56px; height: 56px;
        border-radius: 8px;
        object-fit: cover;
        border: 1px solid #334155;
        display: block;
    }
    .thumb-placeholder {
        width: 56px; height: 56px;
        border-radius: 8px;
        background: #263248;
        border: 1px solid #334155;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
    }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="jsr-wrap">
    <h2>🛒 장바구니</h2>

    <c:choose>
    <c:when test="${empty jsrCartItems}">
        <p style="color:#64748b;margin-top:20px">
            장바구니가 비어 있습니다.
            <a href="<%= request.getContextPath() %>/products">쇼핑하러 가기 →</a>
        </p>
    </c:when>
    <c:otherwise>
        <table class="jsr-table">
            <thead>
            <tr>
                <th>이미지</th>
                <th>상품명</th>
                <th>단가</th>
                <th>수량</th>
                <th>소계</th>
                <th>삭제</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="item" items="${jsrCartItems}">
            <tr>
                <%-- 썸네일 --%>
                <td style="padding:8px 10px">
                    <c:choose>
                        <c:when test="${not empty item.imageUrl}">
                            <img src="<%= request.getContextPath() %>/static/images/${item.imageUrl}"
                                 alt="${item.productName}" class="thumb"
                                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                            <span class="thumb-placeholder" style="display:none">📦</span>
                        </c:when>
                        <c:otherwise>
                            <span class="thumb-placeholder">📦</span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td style="font-weight:600">${item.productName}</td>
                <td style="color:#94a3b8;font-family:monospace">
                    <fmt:formatNumber value="${item.price}" pattern="#,###"/>원
                </td>
                <td>
                    <form method="post" action="<%= request.getContextPath() %>/cart/update" style="display:inline">
                        <input type="hidden" name="cartId" value="${item.cartId}">
                        <input type="number" name="quantity" value="${item.quantity}" min="1"
                               style="width:60px;background:#263248;border:1px solid #3f526b;
                                      border-radius:6px;color:#f1f5f9;padding:5px 8px;
                                      text-align:center;font-size:14px;outline:none"
                               onchange="this.form.submit()">
                    </form>
                </td>
                <td style="color:#38bdf8;font-weight:700;font-family:monospace">
                    <fmt:formatNumber value="${item.subTotal}" pattern="#,###"/>원
                </td>
                <td>
                    <form method="post" action="<%= request.getContextPath() %>/cart/delete">
                        <input type="hidden" name="cartId" value="${item.cartId}">
                        <input type="submit" value="삭제" class="jsr-btn-sm jsr-btn-danger">
                    </form>
                </td>
            </tr>
            </c:forEach>

            <%-- 합계 행 --%>
            <tr>
                <td colspan="4" style="text-align:right;font-weight:700;color:#94a3b8">합계</td>
                <td style="color:#38bdf8;font-weight:800;font-size:1.1rem;font-family:monospace">
                    <fmt:formatNumber value="${jsrCartTotal}" pattern="#,###"/>원
                </td>
                <td></td>
            </tr>
            </tbody>
        </table>

        <div style="display:flex;gap:12px;margin-top:20px;align-items:center">
            <a href="<%= request.getContextPath() %>/order" class="jsr-btn">주문하기 →</a>
            <a href="<%= request.getContextPath() %>/products" style="font-size:14px;color:#64748b">← 쇼핑 계속</a>
        </div>
    </c:otherwise>
    </c:choose>
</div>
</body>
</html>
