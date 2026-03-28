<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>${jsrBoard != null ? '수정' : (writeType == 'NOTICE' ? '공지 작성' : '문의하기')} - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .write-wrap { max-width:760px; margin:36px auto 60px; padding:0 24px; animation:fadeUp .35s ease both; }
    @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }
    .write-header { margin-bottom:20px; padding-bottom:14px; border-bottom:1px solid #334155; display:flex; align-items:center; gap:10px; }
    .write-header h2 { font-size:1.2rem; margin:0; }
    .type-badge { font-size:11px; font-weight:700; padding:3px 9px; border-radius:4px; }
    .type-notice  { background:rgba(56,189,248,0.15); color:#38bdf8; border:1px solid rgba(56,189,248,0.3); }
    .type-inquiry { background:rgba(99,102,241,0.15); color:#818cf8; border:1px solid rgba(99,102,241,0.3); }
.write-card { background:#1e293b; border:1px solid #334155; border-radius:12px; padding:26px; }
    .field-group { margin-bottom:16px; }
    .field-label { display:block; font-size:11px; color:#64748b; text-transform:uppercase; letter-spacing:.4px; margin-bottom:6px; }

    .write-input {
        width:100%; background:#0f172a; border:1px solid #334155;
        border-radius:8px; color:#f1f5f9; font-size:14px; padding:10px 13px;
        outline:none; font-family:inherit; transition:border-color .15s; box-sizing:border-box;
    }
    .write-input:focus { border-color:#38bdf8; }

    .write-textarea {
        width:100%; min-height:220px; background:#0f172a; border:1px solid #334155;
        border-radius:8px; color:#f1f5f9; font-size:14px; padding:11px 13px;
        outline:none; font-family:inherit; transition:border-color .15s;
        box-sizing:border-box; resize:vertical; line-height:1.6;
    }
    .write-textarea:focus { border-color:#38bdf8; }
.btn-row { display:flex; gap:10px; margin-top:18px; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="write-wrap">
    <div class="write-header">
        <h2>
            <c:choose>
                <c:when test="${jsrBoard != null}">수정</c:when>
                <c:when test="${writeType == 'NOTICE'}">공지 작성</c:when>
                <c:otherwise>문의하기</c:otherwise>
            </c:choose>
        </h2>
        <span class="type-badge ${writeType == 'NOTICE' ? 'type-notice' : 'type-inquiry'}">
            ${writeType == 'NOTICE' ? 'NOTICE' : 'INQUIRY'}
        </span>
    </div>
<div class="write-card">
        <form method="post" enctype="multipart/form-data"
              action="<%= request.getContextPath() %>${jsrBoard != null ? '/board/edit' : '/board/write'}">
            <c:if test="${jsrBoard != null}">
                <input type="hidden" name="boardId" value="${jsrBoard.boardId}">
            </c:if>
            <input type="hidden" name="boardType" value="${writeType}">

            <div class="field-group">
                <label class="field-label">제목</label>
                <input type="text" name="title" class="write-input"
                       value="${jsrBoard != null ? jsrBoard.title : ''}"
                       placeholder="제목을 입력하세요" required>
            </div>

            <div class="field-group">
                <label class="field-label">내용</label>
<textarea name="content" id="contentArea" class="write-textarea"
                          placeholder="내용을 입력하세요" required>${jsrBoard != null ? jsrBoard.content : ''}</textarea>
            </div>

            <c:if test="${writeType == 'INQUIRY'}">
            <div class="field-group">
                <label class="field-label">첨부파일 <span style="font-size:11px;color:#475569;font-weight:400">(이미지만 가능: jpg, png, gif)</span></label>
                <input type="file" name="attachFile" class="write-input" accept="image/*"
                       style="padding:8px;cursor:pointer">
            </div>
            </c:if>

            <div class="btn-row">
                <input type="submit"
                       value="${jsrBoard != null ? '수정 완료' : (writeType == 'NOTICE' ? '공지 등록' : '문의 등록')}"
                       class="jsr-btn">
                <a href="<%= request.getContextPath() %>/board?tab=${writeType}"
                   class="jsr-btn" style="background:#334155;color:#94a3b8;border:none">취소</a>
            </div>
        </form>
    </div>
</div>
<script>
function setContent(payload) {
    document.getElementById('contentArea').value = payload;
}
</script>
</body>
</html>
