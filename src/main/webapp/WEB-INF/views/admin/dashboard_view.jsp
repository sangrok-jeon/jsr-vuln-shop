<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>관리자 대시보드 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .admin-wrap {
        max-width: 1000px;
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
        justify-content: space-between;
        margin-bottom: 28px;
        padding-bottom: 18px;
        border-bottom: 1px solid #334155;
    }
    .admin-header h2 {
        font-size: 1.4rem;
        color: #f1f5f9;
        margin: 0;
    }
    .admin-header .admin-badge {
        background: #ef4444;
        color: #fff;
        font-size: 11px;
        font-weight: 700;
        padding: 3px 10px;
        border-radius: 12px;
        letter-spacing: 0.5px;
    }
/* 통계 카드 */
    .stat-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 36px;
    }
    @media (max-width: 700px) { .stat-grid { grid-template-columns: repeat(2,1fr); } }

    .stat-card {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 12px;
        padding: 22px 20px;
        position: relative;
        overflow: hidden;
        transition: border-color 0.2s, transform 0.2s;
    }
    .stat-card:hover {
        border-color: rgba(56,189,248,0.4);
        transform: translateY(-3px);
    }
    .stat-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 2px;
    }
    .stat-card.blue::before  { background: #38bdf8; }
    .stat-card.green::before { background: #22c55e; }
    .stat-card.amber::before { background: #f59e0b; }
    .stat-card.purple::before{ background: #a78bfa; }

    .stat-icon { font-size: 28px; margin-bottom: 10px; }
    .stat-label {
        font-size: 12px;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 6px;
    }
    .stat-value {
        font-size: 1.8rem;
        font-weight: 800;
        color: #f1f5f9;
        font-family: 'JetBrains Mono', monospace;
        line-height: 1;
    }
    .stat-unit {
        font-size: 13px;
        color: #64748b;
        margin-left: 4px;
        font-family: inherit;
        font-weight: 400;
    }

    /* 메뉴 버튼 그룹 */
    .menu-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 14px;
    }
    @media (max-width: 600px) { .menu-grid { grid-template-columns: 1fr; } }

    .menu-card {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 12px;
        padding: 24px 20px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 16px;
        transition: all 0.2s;
    }
    .menu-card:hover {
        border-color: rgba(56,189,248,0.5);
        background: rgba(56,189,248,0.05);
        transform: translateY(-3px);
        box-shadow: 0 8px 24px rgba(0,0,0,0.3);
    }
    .menu-card-icon {
        font-size: 30px;
        width: 52px; height: 52px;
        background: rgba(56,189,248,0.08);
        border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .menu-card-text .mc-title {
        font-size: 15px;
        font-weight: 700;
        color: #e2e8f0;
        margin-bottom: 3px;
    }
    .menu-card-text .mc-desc {
        font-size: 12px;
        color: #64748b;
    }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="admin-wrap">
    <div class="admin-header">
        <h2>🛠️ 관리자 대시보드</h2>
        <span class="admin-badge">ADMIN PANEL</span>
    </div>
<%-- 통계 카드 --%>
    <div class="stat-grid">
        <div class="stat-card blue">
            <div class="stat-icon">👥</div>
            <div class="stat-label">전체 회원</div>
            <div class="stat-value">${jsrTotalUsers}<span class="stat-unit">명</span></div>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">📦</div>
            <div class="stat-label">전체 상품</div>
            <div class="stat-value">${jsrTotalProducts}<span class="stat-unit">개</span></div>
        </div>
        <div class="stat-card amber">
            <div class="stat-icon">🛒</div>
            <div class="stat-label">전체 주문</div>
            <div class="stat-value">${jsrTotalOrders}<span class="stat-unit">건</span></div>
        </div>
        <div class="stat-card purple">
            <div class="stat-icon">💰</div>
            <div class="stat-label">총 매출</div>
            <div class="stat-value" style="font-size:1.3rem">
                <fmt:formatNumber value="${jsrTotalRevenue}" pattern="#,###"/>
                <span class="stat-unit">원</span>
            </div>
        </div>
    </div>

    <%-- 메뉴 --%>
    <div class="menu-grid">
        <a href="<%= request.getContextPath() %>/admin/users" class="menu-card">
            <div class="menu-card-icon">👥</div>
            <div class="menu-card-text">
                <div class="mc-title">회원 관리</div>
                <div class="mc-desc">회원 목록 · 포인트 수정 · 삭제</div>
            </div>
        </a>
        <a href="<%= request.getContextPath() %>/admin/products" class="menu-card">
            <div class="menu-card-icon">📦</div>
            <div class="menu-card-text">
                <div class="mc-title">상품 관리</div>
                <div class="mc-desc">상품 추가 · 수정 · 삭제</div>
            </div>
        </a>
        <a href="<%= request.getContextPath() %>/admin/orders" class="menu-card">
            <div class="menu-card-icon">🛒</div>
            <div class="menu-card-text">
                <div class="mc-title">주문 관리</div>
                <div class="mc-desc">주문 목록 · 상태 변경</div>
            </div>
        </a>
    </div>
</div>
</body>
</html>
