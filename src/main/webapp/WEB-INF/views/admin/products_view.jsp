<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>상품 관리 - JSR Shop</title>
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
        margin-bottom: 28px;
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

    .alert-box {
        padding: 10px 16px;
        border-radius: 8px;
        font-size: 13px;
        margin-bottom: 20px;
    }
    .alert-success { background:rgba(34,197,94,0.1); border:1px solid rgba(34,197,94,0.3); color:#86efac; }
    .alert-error   { background:rgba(239,68,68,0.1);  border:1px solid rgba(239,68,68,0.3);  color:#fca5a5; }

    .add-form-box {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 12px;
        padding: 24px;
        margin-bottom: 32px;
    }
    .add-form-box h3 {
        font-size: 14px;
        color: #94a3b8;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 16px;
    }
    .add-form-row {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        align-items: flex-end;
    }
    .add-form-row .field { display: flex; flex-direction: column; gap: 5px; }
    .add-form-row .field label {
        font-size: 11px; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.4px;
    }
    .f-name  { flex: 2; min-width: 140px; }
    .f-desc  { flex: 3; min-width: 160px; }
    .f-price { width: 100px; }
    .f-stock { width: 80px; }
    .f-cat   { width: 110px; }

    .section-title {
        font-size: 14px; color: #94a3b8;
        text-transform: uppercase; letter-spacing: 0.5px;
        margin-bottom: 14px;
    }
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
    .btn-row { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }

    /* 썸네일 */
    .prod-thumb {
        width: 48px; height: 48px;
        border-radius: 8px; object-fit: cover;
        border: 1px solid #334155; display: block;
    }
    .prod-thumb-ph {
        width: 48px; height: 48px;
        border-radius: 8px; background: #263248;
        border: 1px solid #334155;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px;
    }

    /* 모달 */
    .modal-overlay {
        display: none;
        position: fixed; inset: 0;
        background: rgba(0,0,0,0.75);
        z-index: 1000;
        align-items: center; justify-content: center;
    }
    .modal-overlay.open { display: flex; }
    .modal-box {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 16px;
        padding: 28px;
        width: 440px; max-width: 95vw;
        animation: fadeUp 0.25s ease both;
    }
    .modal-box h3 { font-size: 16px; font-weight: 700; color: #f1f5f9; margin-bottom: 20px; }

    /* 업로드 존 */
    .upload-zone {
        border: 2px dashed #334155;
        border-radius: 12px;
        padding: 28px;
        text-align: center;
        cursor: pointer;
        transition: border-color 0.2s, background 0.2s;
        margin-bottom: 14px;
        position: relative;
    }
    .upload-zone:hover, .upload-zone.dragover {
        border-color: #38bdf8;
        background: rgba(56,189,248,0.05);
    }
    .upload-zone input[type=file] {
        position: absolute; inset: 0; opacity: 0;
        cursor: pointer; width: 100%; height: 100%;
    }
    .uz-icon { font-size: 34px; margin-bottom: 8px; }
    .uz-text { font-size: 13px; color: #64748b; line-height: 1.6; }
    .uz-text strong { color: #38bdf8; }

    .upload-preview {
        display: none;
        width: 100%; max-height: 200px;
        object-fit: contain; border-radius: 8px;
        margin-bottom: 12px; border: 1px solid #334155;
    }
    .modal-footer {
        display: flex; gap: 10px;
        justify-content: flex-end; margin-top: 16px;
    }
    .btn-cancel {
        background: transparent; border: 1px solid #334155;
        color: #94a3b8; border-radius: 8px;
        padding: 8px 18px; cursor: pointer;
        font-size: 13px; transition: all 0.15s;
    }
    .btn-cancel:hover { border-color: #64748b; color: #f1f5f9; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<%-- ══ 이미지 업로드 모달 ══ --%>
<div class="modal-overlay" id="uploadModal">
    <div class="modal-box">
        <h3 id="modalTitle">이미지 업로드</h3>
        <form method="post"
              action="<%= request.getContextPath() %>/admin/product_image_upload"
              enctype="multipart/form-data" id="uploadForm">
            <input type="hidden" name="productId" id="modalProductId">

            <img id="uploadPreview" class="upload-preview" src="" alt="미리보기">

            <div class="upload-zone" id="uploadZone">
                <input type="file" name="imageFile" id="imageFileInput"
                       accept="image/jpeg,image/png,image/gif,image/webp"
                       onchange="previewImage(this)">
                <div class="uz-icon" id="uzIcon">FILE</div>
                <div class="uz-text">
                    클릭하거나 이미지를 드래그하세요<br>
                    <strong>JPG · PNG · GIF · WEBP</strong> / 최대 10MB
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal()">취소</button>
                <input type="submit" value="업로드" class="jsr-btn"
                       id="uploadBtn" disabled>
            </div>
        </form>
    </div>
</div>

<div class="admin-wrap">
    <div class="admin-header">
        <h2>상품 관리</h2>
        <a href="<%= request.getContextPath() %>/admin/dashboard" class="back-link">← 대시보드</a>
    </div>

    <%-- 알림 --%>
    <c:if test="${param.uploaded == '1'}">
        <div class="alert-box alert-success">이미지가 업로드되었습니다.</div>
    </c:if>
    <c:if test="${param.added == '1'}">
        <div class="alert-box alert-success">상품이 추가되었습니다.</div>
    </c:if>
    <c:if test="${param.updated == '1'}">
        <div class="alert-box alert-success">상품이 수정되었습니다.</div>
    </c:if>
    <c:if test="${param.deleted == '1'}">
        <div class="alert-box alert-success">상품이 삭제되었습니다.</div>
    </c:if>
    <c:if test="${param.error == 'nofile'}">
        <div class="alert-box alert-error">파일을 선택해주세요.</div>
    </c:if>
    <c:if test="${param.error == 'invalidtype'}">
        <div class="alert-box alert-error">JPG, PNG, GIF, WEBP 형식만 가능합니다.</div>
    </c:if>

    <%-- ── 상품 추가 폼 ── --%>
    <div class="add-form-box">
        <h3>+ 새 상품 추가</h3>
        <form method="post" action="<%= request.getContextPath() %>/admin/product_add">
            <div class="add-form-row">
                <div class="field f-name">
                    <label>상품명</label>
                    <input type="text" name="name" class="jsr-input" placeholder="상품명" required>
                </div>
                <div class="field f-desc">
                    <label>설명</label>
                    <input type="text" name="description" class="jsr-input" placeholder="상품 설명">
                </div>
                <div class="field f-price">
                    <label>가격 (원)</label>
                    <input type="number" name="price" class="jsr-input" placeholder="가격" min="0" required>
                </div>
                <div class="field f-stock">
                    <label>재고</label>
                    <input type="number" name="stock" class="jsr-input" placeholder="재고" min="0" required>
                </div>
                <div class="field f-cat">
                    <label>카테고리</label>
                    <select name="category" class="jsr-input" style="padding:9px 10px">
                        <option value="전자기기">전자기기</option>
                        <option value="주변기기">주변기기</option>
                        <option value="저장장치">저장장치</option>
                        <option value="보안용품">보안용품</option>
                    </select>
                </div>
                <div class="field" style="justify-content:flex-end">
                    <input type="submit" value="추가" class="jsr-btn">
                </div>
            </div>
        </form>
    </div>

    <%-- ── 상품 목록 ── --%>
    <div class="section-title">상품 목록 (${jsrProducts.size()}개)</div>

    <table class="jsr-table">
        <thead>
        <tr>
            <th>ID</th>
            <th>이미지</th>
            <th>상품명</th>
            <th>카테고리</th>
            <th>가격</th>
            <th>재고</th>
            <th>수정</th>
            <th>이미지</th>
            <th>삭제</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="p" items="${jsrProducts}">
        <tr>
            <td style="color:#64748b;font-family:monospace">${p.productId}</td>

            <%-- 썸네일 --%>
            <td style="padding:8px 10px">
                <c:choose>
                    <c:when test="${not empty p.imageUrl}">
                        <img src="<%= request.getContextPath() %>/static/images/${p.imageUrl}"
                             alt="${p.name}" class="prod-thumb"
                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                        <span class="prod-thumb-ph" style="display:none">이미지</span>
                    </c:when>
                    <c:otherwise>
                        <span class="prod-thumb-ph">
                            <c:choose>
                                <c:when test="${p.category=='전자기기'}">PC</c:when>
                                <c:when test="${p.category=='주변기기'}">ACC</c:when>
                                <c:when test="${p.category=='저장장치'}">저장</c:when>
                                <c:when test="${p.category=='보안용품'}">보안</c:when>
                                <c:otherwise>이미지</c:otherwise>
                            </c:choose>
                        </span>
                    </c:otherwise>
                </c:choose>
            </td>

            <td style="font-weight:600">${p.name}</td>
            <td>
                <span style="font-size:11px;background:#263248;border:1px solid #3f526b;
                             border-radius:4px;padding:2px 8px;color:#94a3b8">
                    ${p.category}
                </span>
            </td>
            <td style="color:#38bdf8;font-family:monospace;font-weight:700">
                <fmt:formatNumber value="${p.price}" pattern="#,###"/>원
            </td>
            <td style="color:${p.stock <= 10 ? '#f59e0b' : '#94a3b8'}">${p.stock}</td>

            <%-- 인라인 수정 --%>
            <td>
                <form method="post" action="<%= request.getContextPath() %>/admin/product_update">
                    <input type="hidden" name="productId" value="${p.productId}">
                    <div class="btn-row">
                        <input type="text"   name="name"        value="${p.name}"        class="edit-input" style="width:95px">
                        <input type="text"   name="description" value="${p.description}" class="edit-input" style="width:105px">
                        <input type="number" name="price"       value="${p.price}"       class="edit-input" style="width:72px">
                        <input type="number" name="stock"       value="${p.stock}"       class="edit-input" style="width:52px">
                        <select name="category" class="edit-input" style="width:82px">
                            <option value="전자기기" ${p.category=='전자기기'?'selected':''}>전자기기</option>
                            <option value="주변기기" ${p.category=='주변기기'?'selected':''}>주변기기</option>
                            <option value="저장장치" ${p.category=='저장장치'?'selected':''}>저장장치</option>
                            <option value="보안용품" ${p.category=='보안용품'?'selected':''}>보안용품</option>
                        </select>
                        <input type="submit" value="수정" class="jsr-btn-sm">
                    </div>
                </form>
            </td>

            <%-- 이미지 업로드 버튼 --%>
            <td>
                <button type="button" class="jsr-btn-sm"
                        onclick="openModal(${p.productId}, '${p.name}')">
                    업로드
                </button>
            </td>

            <%-- 삭제 --%>
            <td>
                <form method="post" action="<%= request.getContextPath() %>/admin/product_delete"
                      onsubmit="return confirm('상품 [${p.name}]을 삭제하시겠습니까?')">
                    <input type="hidden" name="productId" value="${p.productId}">
                    <input type="submit" value="삭제" class="jsr-btn-sm jsr-btn-danger">
                </form>
            </td>
        </tr>
        </c:forEach>
        <c:if test="${empty jsrProducts}">
        <tr><td colspan="9" style="text-align:center;padding:30px;color:#475569">등록된 상품이 없습니다.</td></tr>
        </c:if>
        </tbody>
    </table>
</div>

<script>
function openModal(productId, productName) {
    document.getElementById('modalProductId').value = productId;
    document.getElementById('modalTitle').textContent = '이미지 업로드 — ' + productName;
    document.getElementById('uploadPreview').style.display = 'none';
    document.getElementById('uploadPreview').src = '';
    document.getElementById('imageFileInput').value = '';
    document.getElementById('uploadBtn').disabled = true;
    document.getElementById('uzIcon').textContent = 'FILE';
    document.getElementById('uploadModal').classList.add('open');
}
function closeModal() {
    document.getElementById('uploadModal').classList.remove('open');
}
function previewImage(input) {
    if (!input.files[0]) return;
    const reader = new FileReader();
    reader.onload = function(e) {
        const preview = document.getElementById('uploadPreview');
        preview.src = e.target.result;
        preview.style.display = 'block';
        document.getElementById('uzIcon').textContent = 'OK';
        document.getElementById('uploadBtn').disabled = false;
    };
    reader.readAsDataURL(input.files[0]);
}

// 배경 클릭 닫기
document.getElementById('uploadModal').addEventListener('click', function(e) {
    if (e.target === this) closeModal();
});

// 드래그앤드롭
const zone = document.getElementById('uploadZone');
zone.addEventListener('dragover',  e => { e.preventDefault(); zone.classList.add('dragover'); });
zone.addEventListener('dragleave', () => zone.classList.remove('dragover'));
zone.addEventListener('drop', e => {
    e.preventDefault();
    zone.classList.remove('dragover');
    const input = document.getElementById('imageFileInput');
    const dt = e.dataTransfer;
    // DataTransfer를 FileInput에 주입
    try {
        const list = new DataTransfer();
        list.items.add(dt.files[0]);
        input.files = list.files;
    } catch(err) { /* IE fallback */ }
    previewImage(input);
});
</script>
</body>
</html>
