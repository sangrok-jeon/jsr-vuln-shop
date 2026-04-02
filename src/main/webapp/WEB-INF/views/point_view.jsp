<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>포인트 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .point-wrap {
        max-width: 820px;
        margin: 36px auto 60px;
        padding: 0 24px;
        animation: fadeUp 0.35s ease both;
    }
    @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }
    .point-header {
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #334155;
    }
    .point-header h2 {
        font-size: 1.3rem;
        margin: 0;
    }

    .point-banner {
        background: linear-gradient(135deg, rgba(56,189,248,0.12) 0%, rgba(99,102,241,0.08) 100%);
        border: 1px solid rgba(56,189,248,0.25);
        border-radius: 16px;
        padding: 26px 28px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 8px;
        position: relative;
        overflow: hidden;
    }
    .pb-label {
        font-size: 12px;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: .5px;
        margin-bottom: 6px;
    }
    .pb-value {
        font-size: 2.2rem;
        font-weight: 800;
        color: #38bdf8;
        font-family: monospace;
        letter-spacing: -1px;
        line-height: 1;
    }
    .pb-unit {
        font-size: 15px;
        color: #64748b;
        margin-left: 4px;
        font-family: inherit;
        font-weight: 400;
    }

    .progress-wrap { margin-bottom: 20px; }
    .progress-bar-bg {
        background: #0f172a;
        border-radius: 100px;
        height: 6px;
        overflow: hidden;
        margin-bottom: 4px;
    }
    .progress-bar-fill {
        height: 100%;
        border-radius: 100px;
        background: linear-gradient(90deg, #38bdf8, #6366f1);
        transition: width 0.4s ease;
    }
    .progress-label {
        font-size: 11px;
        color: #475569;
        text-align: right;
    }

    .alert {
        padding: 10px 16px;
        border-radius: 8px;
        font-size: 13px;
        margin-bottom: 18px;
        line-height: 1.6;
    }
    .alert-success {
        background: rgba(34,197,94,0.1);
        border: 1px solid rgba(34,197,94,0.3);
        color: #86efac;
    }
    .alert-error {
        background: rgba(239,68,68,0.1);
        border: 1px solid rgba(239,68,68,0.3);
        color: #fca5a5;
    }

    .action-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        margin-bottom: 32px;
    }
    @media (max-width: 580px) {
        .action-grid { grid-template-columns: 1fr; }
    }

    .action-card {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 12px;
        padding: 22px;
    }
    .action-card h3 {
        font-size: 14px;
        font-weight: 700;
        color: #f1f5f9;
        margin-bottom: 8px;
        padding-bottom: 10px;
        border-bottom: 1px solid #334155;
    }
    .limit-note {
        font-size: 11px;
        color: #64748b;
        margin-bottom: 12px;
        padding: 7px 10px;
        background: #0f172a;
        border-radius: 6px;
        border: 1px solid #1e293b;
        line-height: 1.6;
    }
    .limit-note strong { color: #94a3b8; }

    .quick-btns {
        display: flex;
        flex-wrap: wrap;
        gap: 7px;
        margin-bottom: 12px;
    }
    .quick-btn {
        background: #263248;
        border: 1px solid #3f526b;
        color: #94a3b8;
        border-radius: 6px;
        padding: 5px 11px;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.15s;
        font-family: inherit;
    }
    .quick-btn:hover {
        background: #334155;
        color: #f1f5f9;
        border-color: #38bdf8;
    }

    .amount-row {
        display: flex;
        gap: 8px;
        align-items: center;
    }
    .amount-input {
        flex: 1;
        background: #0f172a;
        border: 1px solid #334155;
        border-radius: 8px;
        color: #f1f5f9;
        font-size: 14px;
        padding: 10px 12px;
        outline: none;
        font-family: inherit;
        transition: border-color 0.15s;
    }
    .amount-input:focus { border-color: #38bdf8; }

    .section-title {
        font-size: 14px;
        color: #94a3b8;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 14px;
    }
    .type-badge {
        display: inline-block;
        font-size: 11px;
        font-weight: 700;
        padding: 2px 8px;
        border-radius: 4px;
    }
    .t-CHARGE {
        background: rgba(34,197,94,0.15);
        color: #22c55e;
        border: 1px solid rgba(34,197,94,0.3);
    }
    .t-USE {
        background: rgba(239,68,68,0.15);
        color: #ef4444;
        border: 1px solid rgba(239,68,68,0.3);
    }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="point-wrap">
    <div class="point-header">
        <h2>포인트</h2>
    </div>

    <c:if test="${param.charged == '1'}">
        <div class="alert alert-success">포인트가 충전되었습니다.</div>
    </c:if>
    <c:if test="${param.used == '1'}">
        <div class="alert alert-success">포인트가 사용되었습니다.</div>
    </c:if>
    <c:if test="${param.error == 'empty' || param.error == 'invalid'}">
        <div class="alert alert-error">올바른 금액을 입력해 주세요.</div>
    </c:if>
    <c:if test="${param.error == 'negative'}">
        <div class="alert alert-error">0보다 큰 금액을 입력해 주세요.</div>
    </c:if>
    <c:if test="${param.error == 'overlimit'}">
        <div class="alert alert-error">
            1회 최대 <strong><fmt:formatNumber value="${param.limit}" pattern="#,###"/>P</strong>까지 충전할 수 있습니다.
        </div>
    </c:if>
    <c:if test="${param.error == 'maxpoint'}">
        <div class="alert alert-error">
            최대 보유 포인트는 <strong><fmt:formatNumber value="${param.max}" pattern="#,###"/>P</strong>입니다.
            현재 보유 포인트는 <strong><fmt:formatNumber value="${param.current}" pattern="#,###"/>P</strong>입니다.
        </div>
    </c:if>
    <c:if test="${param.error == 'notenough'}">
        <div class="alert alert-error">
            현재 보유 포인트인 <strong><fmt:formatNumber value="${param.current}" pattern="#,###"/>P</strong>까지만 사용할 수 있습니다.
        </div>
    </c:if>
    <c:if test="${param.error == 'csrf'}">
        <div class="alert alert-error">유효하지 않은 요청입니다. 다시 시도해주세요.</div>
    </c:if>

    <div class="point-banner">
        <div>
            <div class="pb-label">현재 보유 포인트</div>
            <div class="pb-value">
                <fmt:formatNumber value="${jsrUser.point}" pattern="#,###"/>
                <span class="pb-unit">P</span>
            </div>
        </div>
    </div>

    <div class="progress-wrap">
        <div class="progress-bar-bg">
            <div class="progress-bar-fill"
                 style="width:${jsrUser.point > 0 ? (jsrUser.point * 100 / jsrMaxTotal > 100 ? 100 : jsrUser.point * 100 / jsrMaxTotal) : 0}%">
            </div>
        </div>
        <div class="progress-label">
            <fmt:formatNumber value="${jsrUser.point}" pattern="#,###"/>P /
            <fmt:formatNumber value="${jsrMaxTotal}" pattern="#,###"/>P 한도
        </div>
    </div>

    <div class="action-grid">
        <div class="action-card">
            <h3>포인트 충전</h3>
            <div class="limit-note">
                1회 최대 <strong><fmt:formatNumber value="${jsrMaxChargeOnce}" pattern="#,###"/>P</strong> ·
                보유 한도 <strong><fmt:formatNumber value="${jsrMaxTotal}" pattern="#,###"/>P</strong>
            </div>
            <div class="quick-btns">
                <button type="button" class="quick-btn" onclick="setAmt('charge',10000)">1만P</button>
                <button type="button" class="quick-btn" onclick="setAmt('charge',30000)">3만P</button>
                <button type="button" class="quick-btn" onclick="setAmt('charge',50000)">5만P</button>
                <button type="button" class="quick-btn" onclick="setAmt('charge',100000)">10만P (MAX)</button>
            </div>
            <form method="post" action="<%= request.getContextPath() %>/point/charge">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <div class="amount-row">
                    <input type="number" name="amount" id="chargeAmount" class="amount-input"
                           placeholder="최대 100,000P" min="1" max="100000">
                    <input type="submit" value="충전" class="jsr-btn">
                </div>
            </form>
        </div>

        <div class="action-card">
            <h3>포인트 사용</h3>
            <div class="quick-btns">
                <button type="button" class="quick-btn" onclick="setAmt('use',10000)">1만P</button>
                <button type="button" class="quick-btn" onclick="setAmt('use',50000)">5만P</button>
                <button type="button" class="quick-btn" onclick="setAmt('use',100000)">10만P</button>
                <button type="button" class="quick-btn"
                        onclick="setAmt('use',${jsrUser.point > 0 ? jsrUser.point : 0})">전액</button>
            </div>
            <form method="post" action="<%= request.getContextPath() %>/point/use">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <div class="amount-row">
                    <input type="number" name="amount" id="useAmount" class="amount-input"
                           placeholder="사용할 금액 (P)" min="1">
                    <input type="submit" value="사용" class="jsr-btn jsr-btn-danger">
                </div>
            </form>
        </div>
    </div>

    <div class="section-title">포인트 이력</div>
    <table class="jsr-table">
        <thead>
        <tr>
            <th>구분</th>
            <th>변동</th>
            <th>잔액</th>
            <th>내용</th>
            <th>일시</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="h" items="${jsrHistory}">
        <tr>
            <td><span class="type-badge t-${h.type}">${h.type}</span></td>
            <td style="font-family:monospace;font-weight:700;color:${h.type=='CHARGE'?'#22c55e':'#ef4444'}">
                ${h.type == 'CHARGE' ? '+' : '-'}<fmt:formatNumber value="${h.amount}" pattern="#,###"/>P
            </td>
            <td style="font-family:monospace;font-weight:700;color:${h.balanceAfter < 0 ? '#ef4444' : '#38bdf8'}">
                <fmt:formatNumber value="${h.balanceAfter}" pattern="#,###"/>P
            </td>
            <td style="color:#94a3b8;font-size:13px">${h.description}</td>
            <td style="color:#64748b;font-size:12px;font-family:monospace">${h.createdAt}</td>
        </tr>
        </c:forEach>
        <c:if test="${empty jsrHistory}">
        <tr><td colspan="5" style="text-align:center;padding:30px;color:#475569">포인트 이력이 없습니다.</td></tr>
        </c:if>
        </tbody>
    </table>
</div>
<script>
function setAmt(type, val) {
    document.getElementById(type === 'charge' ? 'chargeAmount' : 'useAmount').value = val;
}
</script>
</body>
</html>
