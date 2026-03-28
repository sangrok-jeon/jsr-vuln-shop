<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>주문 관리 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .admin-wrap {
        max-width: 1200px;
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
        margin-bottom: 24px;
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

    /* 상태 배지 */
    .status-badge {
        display: inline-block;
        font-size: 11px;
        font-weight: 700;
        padding: 3px 9px;
        border-radius: 6px;
        letter-spacing: 0.3px;
    }
    .s-PAID      { background: rgba(56,189,248,0.15); color:#38bdf8; border:1px solid rgba(56,189,248,0.3); }
    .s-SHIPPING  { background: rgba(245,158,11,0.15); color:#f59e0b; border:1px solid rgba(245,158,11,0.3); }
    .s-DELIVERED { background: rgba(34,197,94,0.15);  color:#22c55e; border:1px solid rgba(34,197,94,0.3); }
    .s-CANCELLED { background: rgba(239,68,68,0.15);  color:#ef4444; border:1px solid rgba(239,68,68,0.3); }

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
        <h2>주문 관리</h2>
        <a href="<%= request.getContextPath() %>/admin/dashboard" class="back-link">← 대시보드</a>
    </div>

    <div class="section-title">전체 주문 (${jsrOrders.size()}건)</div>

    <table class="jsr-table">
        <thead>
        <tr>
            <th>주문번호</th>
            <th>주문자</th>
            <th>상품명</th>
            <th>수량</th>
            <th>결제금액</th>
            <th>현재 상태</th>
            <th>주문일</th>
            <th>상태 변경</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="o" items="${jsrOrders}">
        <tr>
            <td style="color:#64748b;font-family:monospace">#${o.orderId}</td>
            <td style="font-weight:600">${o.username}</td>
            <td>${o.productName}</td>
            <td style="color:#94a3b8">${o.quantity}개</td>
            <td style="color:#38bdf8;font-family:monospace;font-weight:700">
                <fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/>원
            </td>
            <td>
                <span class="status-badge s-${o.status}">${o.status}</span>
            </td>
            <td style="color:#64748b;font-size:13px;font-family:monospace">${o.createdAt}</td>

            <%-- 상태 변경 --%>
            <td>
                <form method="post" action="<%= request.getContextPath() %>/admin/order_status"
                      style="display:flex;gap:6px;align-items:center">
                    <input type="hidden" name="orderId" value="${o.orderId}">
                    <select name="status" class="edit-input">
                        <option value="PAID"      ${o.status=='PAID'      ?'selected':''}>PAID</option>
                        <option value="SHIPPING"  ${o.status=='SHIPPING'  ?'selected':''}>SHIPPING</option>
                        <option value="DELIVERED" ${o.status=='DELIVERED' ?'selected':''}>DELIVERED</option>
                        <option value="CANCELLED" ${o.status=='CANCELLED' ?'selected':''}>CANCELLED</option>
                    </select>
                    <input type="submit" value="변경" class="jsr-btn-sm">
                </form>
            </td>
        </tr>
        </c:forEach>
        <c:if test="${empty jsrOrders}">
        <tr><td colspan="8" style="text-align:center;padding:30px;color:#475569">주문 내역이 없습니다.</td></tr>
        </c:if>
        </tbody>
    </table>
</div>
</body>
</html>
