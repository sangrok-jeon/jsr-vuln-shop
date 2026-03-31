<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>${jsrProduct.name} - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .detail-wrap {
        max-width: 960px;
        margin: 36px auto 60px;
        padding: 0 24px;
        animation: fadeUp 0.35s ease both;
    }
    @keyframes fadeUp {
        from { opacity:0; transform:translateY(14px); }
        to   { opacity:1; transform:translateY(0); }
    }

    /* 상품 상단 레이아웃 */
    .product-layout {
        display: grid;
        grid-template-columns: 360px 1fr;
        gap: 36px;
        margin-bottom: 36px;
    }
    @media (max-width: 700px) {
        .product-layout { grid-template-columns: 1fr; }
    }

    /* 이미지 박스 */
    .product-img-box {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 16px;
        overflow: hidden;
        aspect-ratio: 1 / 1;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 80px;
        position: relative;
    }
    .product-img-box img {
        width: 100%; height: 100%;
        object-fit: cover;
    }

    /* 상품 정보 */
    .product-info {
        display: flex;
        flex-direction: column;
        gap: 14px;
    }
    .product-cat-badge {
        display: inline-block;
        font-size: 12px;
        background: #263248;
        border: 1px solid #3f526b;
        border-radius: 4px;
        padding: 3px 10px;
        color: #94a3b8;
        width: fit-content;
    }
    .product-name {
        font-size: 1.6rem;
        font-weight: 800;
        color: #f1f5f9;
        line-height: 1.3;
        letter-spacing: -0.5px;
    }
    .product-desc {
        font-size: 14px;
        color: #94a3b8;
        line-height: 1.7;
        padding: 14px;
        background: #1e293b;
        border-radius: 8px;
        border: 1px solid #334155;
    }
    .product-price {
        font-size: 2rem;
        font-weight: 800;
        color: #38bdf8;
        font-family: 'JetBrains Mono', monospace;
        letter-spacing: -1px;
    }
    .product-stock {
        font-size: 13px;
        color: #64748b;
    }
    .product-stock.low { color: #f59e0b; font-weight: 600; }
/* 구매 액션 */
    .buy-actions {
        display: flex;
        flex-direction: column;
        gap: 10px;
        padding-top: 6px;
    }
    .qty-row {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 14px;
        color: #94a3b8;
    }
    .qty-row input[type=number] {
        width: 70px;
        background: #263248;
        border: 1px solid #3f526b;
        border-radius: 6px;
        color: #f1f5f9;
        font-size: 15px;
        font-weight: 700;
        padding: 7px 10px;
        outline: none;
        text-align: center;
    }
    .btn-row { display: flex; gap: 10px; flex-wrap: wrap; }

    /* 리뷰 */
    .review-section { margin-top: 40px; }
    .review-section h3 {
        font-size: 1rem;
        font-weight: 700;
        color: #f1f5f9;
        margin-bottom: 16px;
        padding-bottom: 10px;
        border-bottom: 1px solid #334155;
    }
    .jsr-review { margin-bottom: 12px; }

    /* 리뷰 작성 */
    .review-form-box {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 12px;
        padding: 20px;
        margin-top: 20px;
    }
    .review-form-box h4 {
        font-size: 14px;
        color: #94a3b8;
        margin-bottom: 14px;
    }
    .review-form-box select,
    .review-form-box textarea {
        margin-bottom: 10px;
    }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="detail-wrap">

    <c:if test="${jsrProduct != null}">

    <div class="product-layout">

        <%-- 이미지 --%>
        <div class="product-img-box">
            <c:choose>
                <c:when test="${not empty jsrProduct.imageUrl}">
                    <img src="<%= request.getContextPath() %>/static/images/${jsrProduct.imageUrl}"
                         alt="${jsrProduct.name}"
                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                    <span style="display:none;align-items:center;justify-content:center;font-size:80px">이미지</span>
                </c:when>
                <c:otherwise>
                    <c:choose>
                        <c:when test="${jsrProduct.category == '전자기기'}">PC</c:when>
                        <c:when test="${jsrProduct.category == '주변기기'}">ACC</c:when>
                        <c:when test="${jsrProduct.category == '저장장치'}">저장</c:when>
                        <c:when test="${jsrProduct.category == '보안용품'}">보안</c:when>
                        <c:otherwise>이미지</c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- 상품 정보 --%>
        <div class="product-info">
            <span class="product-cat-badge">${jsrProduct.category}</span>
            <div class="product-name">${jsrProduct.name}</div>
            <div class="product-desc">${jsrProduct.description}</div>
            <div class="product-price">
                <fmt:formatNumber value="${jsrProduct.price}" pattern="#,###"/>원
            </div>
            <div class="product-stock ${jsrProduct.stock <= 10 ? 'low' : ''}">
                재고 ${jsrProduct.stock}개${jsrProduct.stock <= 10 ? ' 품절 임박' : ''}
            </div>
<div class="buy-actions">
                <%-- 장바구니 담기 --%>
                <form method="post" action="<%= request.getContextPath() %>/cart/add">
                    <div class="qty-row">
                        수량:
                        <input type="number" name="quantity" value="1" min="1" max="${jsrProduct.stock}">
                        <input type="hidden" name="productId" value="${jsrProduct.productId}">
                        <input type="submit" value="장바구니 담기" class="jsr-btn">
                    </div>
                </form>

                <form method="post" action="<%= request.getContextPath() %>/order/proc">
                    <input type="hidden" name="productId"  value="${jsrProduct.productId}">
                    <input type="hidden" name="quantity"   value="1">
                    <input type="hidden" name="price"      value="${jsrProduct.price}">
                    <input type="hidden" name="totalPrice" value="${jsrProduct.price}">
                    <input type="submit" value="바로 구매" class="jsr-btn jsr-btn-danger">
                </form>
                
</div>
        </div>
    </div>

    <hr>

    <%-- 리뷰 목록 --%>
    <div class="review-section">
        <h3>리뷰 (${jsrReviews.size()}개)</h3>

        <c:forEach var="r" items="${jsrReviews}">
        <div class="jsr-review">
            <b>${r.username}</b>
            <c:forEach begin="1" end="${r.rating}">⭐</c:forEach>
            <span class="jsr-date">${r.createdAt}</span>
            <br>
<p>${r.content}</p>
        </div>
        </c:forEach>

        <c:if test="${empty jsrReviews}">
        <p style="color:#475569;font-size:14px">아직 리뷰가 없습니다. 첫 리뷰를 남겨보세요!</p>
        </c:if>

        <c:choose>
        <c:when test="${jsrIsBuyer}">
        <div class="review-form-box">
            <h4>리뷰 작성</h4>
            <form method="post" action="<%= request.getContextPath() %>/product/review">
                <input type="hidden" name="productId" value="${jsrProduct.productId}">
                <p>
                    평점:
                    <select name="rating">
                        <option value="5">⭐⭐⭐⭐⭐ (5점)</option>
                        <option value="4">⭐⭐⭐⭐ (4점)</option>
                        <option value="3">⭐⭐⭐ (3점)</option>
                        <option value="2">⭐⭐ (2점)</option>
                        <option value="1">⭐ (1점)</option>
                    </select>
                </p>
                <p>
                    <textarea name="content" rows="4"
                              style="width:100%;max-width:500px"
                              placeholder="구매하신 상품의 후기를 남겨주세요." required></textarea>
                </p>
                <input type="submit" value="리뷰 등록" class="jsr-btn">
            </form>
        </div>
        </c:when>
        <c:otherwise>
        <div class="review-form-box" style="text-align:center;color:#475569;padding:20px">
            구매하신 고객만 리뷰를 작성할 수 있습니다.
        </div>
        </c:otherwise>
        </c:choose>
    </div>

    </c:if>

    <p style="margin-top:24px">
        <a href="<%= request.getContextPath() %>/products">← 목록으로</a>
    </p>
</div>
</body>
</html>
