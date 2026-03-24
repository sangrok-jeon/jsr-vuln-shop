<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>JSR Shop - 상품 목록</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    /* ══════════════════════════════════════
       HERO BANNER
    ══════════════════════════════════════ */
    .hero {
        position: relative;
        width: 100%;
        min-height: 320px;
        background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 50%, #0f2744 100%);
        overflow: hidden;
        display: flex;
        align-items: center;
        padding: 0 60px;
        margin-bottom: 0;
    }

    /* 배경 장식 원 */
    .hero::before {
        content: '';
        position: absolute;
        width: 500px; height: 500px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(56,189,248,0.12) 0%, transparent 70%);
        right: -80px; top: -100px;
        pointer-events: none;
    }
    .hero::after {
        content: '';
        position: absolute;
        width: 300px; height: 300px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(99,102,241,0.10) 0%, transparent 70%);
        left: 30%; bottom: -80px;
        pointer-events: none;
    }

    .hero-content {
        position: relative;
        z-index: 1;
        max-width: 560px;
    }

    .hero-badge {
        display: inline-block;
        background: rgba(56,189,248,0.15);
        border: 1px solid rgba(56,189,248,0.4);
        color: #38bdf8;
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 1.5px;
        text-transform: uppercase;
        padding: 4px 12px;
        border-radius: 20px;
        margin-bottom: 16px;
        animation: fadeUp 0.4s ease both;
    }

    .hero-title {
        font-size: 2.4rem;
        font-weight: 800;
        color: #f1f5f9;
        line-height: 1.2;
        margin-bottom: 12px;
        animation: fadeUp 0.5s ease 0.1s both;
        letter-spacing: -1px;
    }
    .hero-title span { color: #38bdf8; }

    .hero-desc {
        color: #94a3b8;
        font-size: 15px;
        margin-bottom: 28px;
        line-height: 1.6;
        animation: fadeUp 0.5s ease 0.2s both;
    }

    .hero-actions {
        display: flex;
        gap: 12px;
        animation: fadeUp 0.5s ease 0.3s both;
    }

    .hero-btn-primary {
        background: #38bdf8;
        color: #0f172a;
        font-weight: 700;
        font-size: 14px;
        padding: 11px 24px;
        border-radius: 8px;
        text-decoration: none;
        transition: background 0.15s, transform 0.1s, box-shadow 0.15s;
        white-space: nowrap;
    }
    .hero-btn-primary:hover {
        background: #7dd3fc;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(56,189,248,0.35);
        color: #0f172a;
    }

    .hero-btn-secondary {
        background: rgba(255,255,255,0.07);
        border: 1px solid rgba(255,255,255,0.15);
        color: #e2e8f0;
        font-weight: 600;
        font-size: 14px;
        padding: 11px 24px;
        border-radius: 8px;
        text-decoration: none;
        transition: background 0.15s;
        white-space: nowrap;
    }
    .hero-btn-secondary:hover {
        background: rgba(255,255,255,0.13);
        color: #f1f5f9;
    }

    /* 배너 오른쪽 플로팅 카드들 */
    .hero-cards {
        position: absolute;
        right: 60px;
        top: 50%;
        transform: translateY(-50%);
        display: flex;
        gap: 12px;
        animation: fadeUp 0.6s ease 0.35s both;
    }

    .hero-mini-card {
        background: rgba(30,41,59,0.85);
        border: 1px solid rgba(56,189,248,0.2);
        border-radius: 12px;
        padding: 14px 16px;
        width: 130px;
        backdrop-filter: blur(10px);
        text-align: center;
        transition: transform 0.2s;
    }
    .hero-mini-card:hover { transform: translateY(-4px); }
    .hero-mini-card .mc-icon { font-size: 28px; margin-bottom: 6px; }
    .hero-mini-card .mc-label {
        font-size: 12px;
        color: #94a3b8;
        margin-bottom: 4px;
    }
    .hero-mini-card .mc-val {
        font-size: 14px;
        font-weight: 700;
        color: #38bdf8;
    }

    @keyframes fadeUp {
        from { opacity: 0; transform: translateY(16px); }
        to   { opacity: 1; transform: translateY(0); }
    }

    /* ══════════════════════════════════════
       이벤트 탭 배너
    ══════════════════════════════════════ */
    .event-strip {
        background: #1e293b;
        border-top: 1px solid #334155;
        border-bottom: 1px solid #334155;
        padding: 14px 0;
        overflow: hidden;
        white-space: nowrap;
    }
    .event-strip-inner {
        display: flex;
        gap: 8px;
        padding: 0 60px;
        overflow-x: auto;
        scrollbar-width: none;
    }
    .event-strip-inner::-webkit-scrollbar { display: none; }

    .event-pill {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: #263248;
        border: 1px solid #3f526b;
        border-radius: 20px;
        padding: 6px 14px;
        font-size: 13px;
        color: #cbd5e1;
        white-space: nowrap;
        cursor: pointer;
        transition: all 0.15s;
        text-decoration: none;
    }
    .event-pill:hover {
        background: rgba(56,189,248,0.1);
        border-color: #38bdf8;
        color: #38bdf8;
    }
    .event-pill .pill-badge {
        background: #ef4444;
        color: #fff;
        font-size: 10px;
        font-weight: 700;
        padding: 1px 6px;
        border-radius: 10px;
    }
    .event-pill .pill-badge.green  { background: #22c55e; }
    .event-pill .pill-badge.amber  { background: #f59e0b; }
    .event-pill .pill-badge.blue   { background: #3b82f6; }

    /* ══════════════════════════════════════
       섹션 공통
    ══════════════════════════════════════ */
    .shop-section {
        max-width: 1100px;
        margin: 0 auto;
        padding: 0 24px;
    }

    .section-header {
        display: flex;
        align-items: baseline;
        justify-content: space-between;
        margin: 40px 0 18px;
    }
    .section-title {
        font-size: 1.2rem;
        font-weight: 700;
        color: #f1f5f9;
        letter-spacing: -0.3px;
    }
    .section-title span { color: #38bdf8; }
    .section-more {
        font-size: 13px;
        color: #64748b;
        text-decoration: none;
        transition: color 0.15s;
    }
    .section-more:hover { color: #38bdf8; }

    /* ══════════════════════════════════════
       추천 상품 카드 그리드
    ══════════════════════════════════════ */
    .product-cards {
        display: grid;
        grid-template-columns: repeat(6, 1fr);
        gap: 14px;
    }

    @media (max-width: 1100px) { .product-cards { grid-template-columns: repeat(4, 1fr); } }
    @media (max-width: 760px)  { .product-cards { grid-template-columns: repeat(2, 1fr); } }

    .pcard {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 12px;
        overflow: hidden;
        transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
        cursor: pointer;
        text-decoration: none;
        display: block;
        animation: fadeUp 0.4s ease both;
    }
    .pcard:nth-child(1) { animation-delay: 0.05s; }
    .pcard:nth-child(2) { animation-delay: 0.10s; }
    .pcard:nth-child(3) { animation-delay: 0.15s; }
    .pcard:nth-child(4) { animation-delay: 0.20s; }
    .pcard:nth-child(5) { animation-delay: 0.25s; }
    .pcard:nth-child(6) { animation-delay: 0.30s; }

    .pcard:hover {
        transform: translateY(-5px);
        box-shadow: 0 12px 32px rgba(0,0,0,0.4);
        border-color: rgba(56,189,248,0.4);
    }

    .pcard-img {
        width: 100%;
        aspect-ratio: 1 / 1;
        background: #263248;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 48px;
        position: relative;
        overflow: hidden;
    }
    .pcard-img img {
        width: 100%; height: 100%;
        object-fit: cover;
    }

    .pcard-badge {
        position: absolute;
        top: 8px; left: 8px;
        font-size: 10px;
        font-weight: 700;
        padding: 3px 8px;
        border-radius: 6px;
        line-height: 1.4;
    }
    .badge-hot   { background: #ef4444; color: #fff; }
    .badge-new   { background: #22c55e; color: #fff; }
    .badge-sale  { background: #f59e0b; color: #0f172a; }
    .badge-best  { background: #6366f1; color: #fff; }

    .pcard-body {
        padding: 12px 12px 14px;
    }
    .pcard-cat {
        font-size: 11px;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 4px;
    }
    .pcard-name {
        font-size: 13px;
        font-weight: 600;
        color: #e2e8f0;
        line-height: 1.4;
        margin-bottom: 8px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
    .pcard-price {
        font-size: 15px;
        font-weight: 700;
        color: #38bdf8;
        font-family: 'JetBrains Mono', monospace;
    }
    .pcard-stock {
        font-size: 11px;
        color: #64748b;
        margin-top: 4px;
    }
    .pcard-stock.low { color: #f59e0b; }

    /* ══════════════════════════════════════
       카테고리 바로가기
    ══════════════════════════════════════ */
    .cat-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 12px;
        margin-bottom: 0;
    }
    @media (max-width: 600px) { .cat-grid { grid-template-columns: repeat(2, 1fr); } }

    .cat-card {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 12px;
        padding: 20px 16px;
        display: flex;
        align-items: center;
        gap: 14px;
        text-decoration: none;
        transition: all 0.2s;
        animation: fadeUp 0.4s ease both;
    }
    .cat-card:nth-child(1) { animation-delay: 0.05s; }
    .cat-card:nth-child(2) { animation-delay: 0.10s; }
    .cat-card:nth-child(3) { animation-delay: 0.15s; }
    .cat-card:nth-child(4) { animation-delay: 0.20s; }

    .cat-card:hover {
        border-color: rgba(56,189,248,0.5);
        background: rgba(56,189,248,0.05);
        transform: translateY(-3px);
        box-shadow: 0 8px 24px rgba(0,0,0,0.3);
    }
    .cat-icon {
        font-size: 28px;
        width: 48px; height: 48px;
        background: rgba(56,189,248,0.08);
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .cat-info .cat-name {
        font-size: 14px;
        font-weight: 700;
        color: #e2e8f0;
        margin-bottom: 2px;
    }
    .cat-info .cat-desc {
        font-size: 12px;
        color: #64748b;
    }

    /* ══════════════════════════════════════
       구분선
    ══════════════════════════════════════ */
    .divider {
        border: none;
        border-top: 1px solid #1e293b;
        margin: 40px 0 0;
    }

    /* ══════════════════════════════════════
       검색 + 상품 목록 영역 (기존 jsr-wrap 대체)
    ══════════════════════════════════════ */
    .product-list-section {
        max-width: 1100px;
        margin: 0 auto 60px;
        padding: 0 24px;
    }

    .search-bar {
        display: flex;
        gap: 10px;
        margin-bottom: 20px;
        align-items: center;
    }
    .search-bar .jsr-input {
        flex: 1;
        max-width: 480px;
        font-size: 14px;
        padding: 11px 16px;
    }

    .cat-filter {
        display: flex;
        gap: 6px;
        flex-wrap: wrap;
        margin-bottom: 20px;
    }
    .cat-filter a {
        padding: 6px 16px;
        border-radius: 20px;
        font-size: 13px;
        font-weight: 500;
        color: #94a3b8;
        border: 1px solid #334155;
        background: #1e293b;
        text-decoration: none;
        transition: all 0.15s;
    }
    .cat-filter a:hover,
    .cat-filter a.active {
        background: rgba(56,189,248,0.12);
        border-color: #38bdf8;
        color: #38bdf8;
    }

    .search-result-info {
        font-size: 13px;
        color: #64748b;
        margin-bottom: 12px;
    }
    .search-result-info b { color: #38bdf8; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/nav.jsp" %>

<%-- ══ 히어로 배너 ══ --%>
<section class="hero">
    <div class="hero-content">
        <div class="hero-badge">🔥 이번 주 특가</div>
        <h1 class="hero-title">보안 · 전자기기<br><span>특별전 진행 중</span></h1>
        <p class="hero-desc">
            신규 회원 첫 구매 <strong style="color:#f1f5f9">10% 할인</strong> &nbsp;|&nbsp;
            오늘 한정 무료배송<br>
            보안용품부터 최신 전자기기까지 한 곳에서
        </p>
        <div class="hero-actions">
            <a href="#product-list" class="hero-btn-primary">지금 쇼핑하기 →</a>
            <a href="?category=보안용품" class="hero-btn-secondary">보안용품 특가 보기</a>
        </div>
    </div>

    <div class="hero-cards">
        <div class="hero-mini-card">
            <div class="mc-icon">🔒</div>
            <div class="mc-label">보안용품</div>
            <div class="mc-val">최대 40%↓</div>
        </div>
        <div class="hero-mini-card">
            <div class="mc-icon">💾</div>
            <div class="mc-label">저장장치</div>
            <div class="mc-val">특가 진행</div>
        </div>
        <div class="hero-mini-card">
            <div class="mc-icon">📦</div>
            <div class="mc-label">무료배송</div>
            <div class="mc-val">오늘 한정</div>
        </div>
    </div>
</section>

<%-- ══ 이벤트 스트립 ══ --%>
<div class="event-strip">
    <div class="event-strip-inner">
        <a href="#" class="event-pill"><span class="pill-badge">HOT</span> 오늘의 핫딜</a>
        <a href="?category=보안용품" class="event-pill"><span class="pill-badge green">NEW</span> 신상 보안용품</a>
        <a href="?category=전자기기" class="event-pill"><span class="pill-badge blue">추천</span> 전자기기 특가</a>
        <a href="?category=저장장치" class="event-pill"><span class="pill-badge amber">SALE</span> 저장장치 할인</a>
        <a href="?category=주변기기" class="event-pill">🖱️ 주변기기 모아보기</a>
        <a href="#" class="event-pill">🎁 신규 회원 혜택</a>
        <a href="#" class="event-pill">🚚 오늘 주문 당일 배송</a>
    </div>
</div>

<%-- ══ 추천 상품 카드 ══ --%>
<div class="shop-section">
    <div class="section-header">
        <div class="section-title">🏆 <span>인기 상품</span> 추천</div>
        <a href="#product-list" class="section-more">전체보기 ›</a>
    </div>

    <div class="product-cards">
        <c:forEach var="p" items="${jsrProducts}" varStatus="s" end="5">
        <a href="<%= request.getContextPath() %>/product/detail?productId=${p.productId}"
           class="pcard">
            <div class="pcard-img">
                <c:choose>
                    <c:when test="${not empty p.imageUrl}">
                        <img src="<%= request.getContextPath() %>/static/images/${p.imageUrl}"
                             alt="${p.name}"
                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                        <span style="display:none;align-items:center;justify-content:center;width:100%;height:100%;font-size:40px">📦</span>
                    </c:when>
                    <c:otherwise>
                        <c:choose>
                            <c:when test="${p.category == '전자기기'}">💻</c:when>
                            <c:when test="${p.category == '주변기기'}">🖱️</c:when>
                            <c:when test="${p.category == '저장장치'}">💾</c:when>
                            <c:when test="${p.category == '보안용품'}">🔒</c:when>
                            <c:otherwise>📦</c:otherwise>
                        </c:choose>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${s.index == 0}"><span class="pcard-badge badge-hot">HOT</span></c:when>
                    <c:when test="${s.index == 1}"><span class="pcard-badge badge-best">BEST</span></c:when>
                    <c:when test="${s.index == 2}"><span class="pcard-badge badge-new">NEW</span></c:when>
                    <c:when test="${s.index == 3}"><span class="pcard-badge badge-sale">SALE</span></c:when>
                    <c:when test="${s.index == 4}"><span class="pcard-badge badge-hot">인기</span></c:when>
                    <c:otherwise><span class="pcard-badge badge-new">추천</span></c:otherwise>
                </c:choose>
            </div>
            <div class="pcard-body">
                <div class="pcard-cat">${p.category}</div>
                <div class="pcard-name">${p.name}</div>
                <div class="pcard-price"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</div>
                <div class="pcard-stock ${p.stock <= 10 ? 'low' : ''}">
                    재고 ${p.stock}개${p.stock <= 10 ? ' ⚠️ 품절 임박' : ''}
                </div>
            </div>
        </a>
        </c:forEach>

        <%-- 상품이 없을 때 플레이스홀더 --%>
        <c:if test="${empty jsrProducts}">
            <c:forEach begin="1" end="6">
            <div class="pcard">
                <div class="pcard-img" style="color:#334155">📦</div>
                <div class="pcard-body">
                    <div class="pcard-cat">-</div>
                    <div class="pcard-name" style="color:#475569">상품 없음</div>
                    <div class="pcard-price" style="color:#475569">-</div>
                </div>
            </div>
            </c:forEach>
        </c:if>
    </div>

    <%-- ══ 카테고리 바로가기 ══ --%>
    <div class="section-header">
        <div class="section-title">🗂️ 카테고리 <span>바로가기</span></div>
    </div>

    <div class="cat-grid">
        <a href="<%= request.getContextPath() %>/products?category=전자기기" class="cat-card">
            <div class="cat-icon">💻</div>
            <div class="cat-info">
                <div class="cat-name">전자기기</div>
                <div class="cat-desc">노트북 · 태블릿 · 모니터</div>
            </div>
        </a>
        <a href="<%= request.getContextPath() %>/products?category=주변기기" class="cat-card">
            <div class="cat-icon">🖱️</div>
            <div class="cat-info">
                <div class="cat-name">주변기기</div>
                <div class="cat-desc">키보드 · 마우스 · 웹캠</div>
            </div>
        </a>
        <a href="<%= request.getContextPath() %>/products?category=저장장치" class="cat-card">
            <div class="cat-icon">💾</div>
            <div class="cat-info">
                <div class="cat-name">저장장치</div>
                <div class="cat-desc">SSD · HDD · USB</div>
            </div>
        </a>
        <a href="<%= request.getContextPath() %>/products?category=보안용품" class="cat-card">
            <div class="cat-icon">🔒</div>
            <div class="cat-info">
                <div class="cat-name">보안용품</div>
                <div class="cat-desc">프라이버시 · 잠금장치</div>
            </div>
        </a>
    </div>
</div>

<%-- ══ 구분선 ══ --%>
<hr class="divider">

<%-- ══ 전체 상품 목록 (기존 기능 유지) ══ --%>
<div class="product-list-section" id="product-list">

    <div class="section-header">
        <div class="section-title">📋 전체 <span>상품 목록</span></div>
    </div>

    <%-- 검색 --%>
    <form method="get" action="<%= request.getContextPath() %>/products" class="search-bar">
        <input type="text" name="keyword" value="${keyword}" class="jsr-input"
               placeholder="상품명 또는 키워드를 입력하세요.">
        <input type="submit" value="검색" class="jsr-btn">
        <c:if test="${not empty keyword}">
            <a href="<%= request.getContextPath() %>/products" class="jsr-btn-sm">초기화</a>
        </c:if>
    </form>

    <%-- 카테고리 필터 --%>
    <div class="cat-filter">
        <a href="<%= request.getContextPath() %>/products"
           class="${empty param.category ? 'active' : ''}">전체</a>
        <a href="?category=전자기기"
           class="${param.category == '전자기기' ? 'active' : ''}">💻 전자기기</a>
        <a href="?category=주변기기"
           class="${param.category == '주변기기' ? 'active' : ''}">🖱️ 주변기기</a>
        <a href="?category=저장장치"
           class="${param.category == '저장장치' ? 'active' : ''}">💾 저장장치</a>
        <a href="?category=보안용품"
           class="${param.category == '보안용품' ? 'active' : ''}">🔒 보안용품</a>
    </div>
<c:if test="${not empty keyword}">
    <p class="search-result-info">
        "<b>${keyword}</b>" 검색 결과: <b>${jsrProducts.size()}건</b>
    </p>
    </c:if>

    <table class="jsr-table">
        <thead>
        <tr>
            <th>번호</th>
            <th>이미지</th>
            <th>상품명</th>
            <th>카테고리</th>
            <th>가격</th>
            <th>재고</th>
            <th>상세</th>
            <th>담기</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="p" items="${jsrProducts}">
        <tr>
            <td style="color:#64748b;font-family:monospace">${p.productId}</td>
            <td style="padding:6px 10px">
                <c:choose>
                    <c:when test="${not empty p.imageUrl}">
                        <img src="<%= request.getContextPath() %>/static/images/${p.imageUrl}"
                             alt="${p.name}"
                             style="width:52px;height:52px;object-fit:cover;border-radius:8px;border:1px solid #334155;display:block"
                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                        <span style="display:none;width:52px;height:52px;border-radius:8px;background:#263248;border:1px solid #334155;align-items:center;justify-content:center;font-size:22px">📦</span>
                    </c:when>
                    <c:otherwise>
                        <span style="display:flex;width:52px;height:52px;border-radius:8px;background:#263248;border:1px solid #334155;align-items:center;justify-content:center;font-size:22px">
                            <c:choose>
                                <c:when test="${p.category == '전자기기'}">💻</c:when>
                                <c:when test="${p.category == '주변기기'}">🖱️</c:when>
                                <c:when test="${p.category == '저장장치'}">💾</c:when>
                                <c:when test="${p.category == '보안용품'}">🔒</c:when>
                                <c:otherwise>📦</c:otherwise>
                            </c:choose>
                        </span>
                    </c:otherwise>
                </c:choose>
            </td>
            <td style="font-weight:600">${p.name}</td>
            <td>
                <span style="font-size:12px;background:#263248;border:1px solid #3f526b;
                             border-radius:4px;padding:2px 8px;color:#94a3b8">
                    ${p.category}
                </span>
            </td>
            <td style="font-weight:700;color:#38bdf8;font-family:monospace">
                <fmt:formatNumber value="${p.price}" pattern="#,###"/>원
            </td>
            <td style="color:${p.stock <= 10 ? '#f59e0b' : '#94a3b8'}">${p.stock}개</td>
            <td>
                <a href="<%= request.getContextPath() %>/product/detail?productId=${p.productId}"
                   class="jsr-btn-sm">상세</a>
            </td>
            <td>
                <form method="post" action="<%= request.getContextPath() %>/cart/add" style="display:inline">
                    <input type="hidden" name="productId" value="${p.productId}">
                    <input type="hidden" name="quantity" value="1">
                    <input type="submit" value="담기" class="jsr-btn-sm">
                </form>
            </td>
        </tr>
        </c:forEach>
        <c:if test="${empty jsrProducts}">
        <tr>
            <td colspan="8" style="text-align:center;padding:40px;color:#475569">
                검색 결과가 없습니다.
            </td>
        </tr>
        </c:if>
        </tbody>
    </table>
</div>

</body>
</html>
