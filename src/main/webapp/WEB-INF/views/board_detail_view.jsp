<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>${jsrBoard.title} - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .detail-wrap { max-width:800px; margin:36px auto 60px; padding:0 24px; animation:fadeUp .35s ease both; }
    @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }

    /* 글 카드 */
    .post-card { background:#1e293b; border:1px solid #334155; border-radius:12px; overflow:hidden; margin-bottom:16px; }
    .post-header { padding:18px 22px; border-bottom:1px solid #334155; }
    .post-title-row { display:flex; align-items:center; gap:10px; margin-bottom:10px; }
    .post-title { font-size:1.15rem; font-weight:800; color:#f1f5f9; word-break:break-word; flex:1; }
    .type-badge { font-size:11px; font-weight:700; padding:2px 8px; border-radius:4px; white-space:nowrap; }
    .type-notice  { background:rgba(56,189,248,0.15); color:#38bdf8; border:1px solid rgba(56,189,248,0.3); }
    .type-inquiry { background:rgba(100,116,139,0.15); color:#94a3b8; border:1px solid #334155; }
    .post-meta  { display:flex; align-items:center; gap:14px; font-size:12px; color:#64748b; flex-wrap:wrap; }
    .post-meta .author { color:#94a3b8; font-weight:600; }
    .post-body  { padding:22px; min-height:80px; color:#cbd5e1; line-height:1.7; font-size:14px; word-break:break-word; }
    .attach-box { padding:10px 22px; border-top:1px solid #1e3a52; background:rgba(56,189,248,0.04); display:flex; align-items:center; gap:10px; font-size:13px; }
    .attach-link { color:#38bdf8; text-decoration:none; font-family:monospace; }
    .attach-link:hover { text-decoration:underline; }
    .post-actions { padding:12px 22px; border-top:1px solid #334155; display:flex; gap:8px; justify-content:flex-end; }

    /* 관리자 답변 */
    .answer-card { border-radius:12px; overflow:hidden; margin-bottom:24px; border:1px solid rgba(56,189,248,0.25); background:linear-gradient(135deg,rgba(56,189,248,0.06) 0%,rgba(99,102,241,0.04) 100%); }
    .answer-header { padding:14px 22px; border-bottom:1px solid rgba(56,189,248,0.15); display:flex; align-items:center; justify-content:space-between; }
    .answer-header-left { display:flex; align-items:center; gap:10px; }
    .answer-badge { background:#38bdf8; color:#0f172a; font-size:11px; font-weight:800; padding:3px 9px; border-radius:4px; }
    .answer-admin { font-size:13px; color:#94a3b8; font-weight:600; }
    .answer-date  { font-size:11px; color:#475569; font-family:monospace; }
    .answer-body  { padding:22px; color:#bfdbfe; line-height:1.7; font-size:14px; word-break:break-word; }

    /* 답변 대기 */
    .answer-pending { background:#1e293b; border:1px solid #334155; border-radius:12px; padding:28px; text-align:center; margin-bottom:24px; color:#475569; }

    /* 답변 작성 폼 */
    .answer-form-card { background:#1e293b; border:1px solid #334155; border-radius:12px; padding:22px; margin-bottom:24px; }
    .answer-form-card h3 { font-size:13px; color:#64748b; text-transform:uppercase; letter-spacing:.4px; margin-bottom:14px; margin-top:0; }
    .answer-textarea { width:100%; min-height:90px; background:#0f172a; border:1px solid #334155; border-radius:8px; color:#f1f5f9; font-size:14px; padding:10px 12px; outline:none; font-family:inherit; transition:border-color .15s; box-sizing:border-box; resize:vertical; margin-bottom:12px; }
    .answer-textarea:focus { border-color:#38bdf8; }

    .alert { padding:10px 14px; border-radius:8px; font-size:13px; margin-bottom:16px; }
    .alert-success { background:rgba(34,197,94,0.1); border:1px solid rgba(34,197,94,0.3); color:#86efac; }
    .alert-error   { background:rgba(239,68,68,0.1); border:1px solid rgba(239,68,68,0.3); color:#fca5a5; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="detail-wrap">
<c:if test="${param.answered == '1'}"><div class="alert alert-success">답변이 등록되었습니다.</div></c:if>
    <c:if test="${param.error == 'noperm'}">
        <div class="alert alert-error">관리자만 답변할 수 있습니다.</div>
</c:if>

    <c:if test="${jsrBoard != null}">

    <%-- ── 글 카드 ── --%>
    <div class="post-card">
        <div class="post-header">
            <div class="post-title-row">
<div class="post-title">${jsrBoard.title}</div>
                <span class="type-badge ${jsrBoard.boardType == 'NOTICE' ? 'type-notice' : 'type-inquiry'}">
                    ${jsrBoard.boardType == 'NOTICE' ? '공지' : '문의'}
                </span>
            </div>
            <div class="post-meta">
                <span style="font-family:monospace;color:#475569">#${jsrBoard.boardId}</span>
                <span class="author">${jsrBoard.username}</span>
<span>${jsrBoard.createdAt}</span>
            </div>
        </div>
<div class="post-body">${jsrBoard.content}</div>
        <%-- 첨부파일 (웹 루트 /uploads/ 에 저장 → URL 직접 접근으로 웹쉘 실행 가능) --%>
        <c:if test="${not empty jsrBoard.attachFile}">
        <div class="attach-box">
            <span style="color:#475569">첨부:</span>
            <a class="attach-link"
               href="<%= request.getContextPath() %>/uploads/${jsrBoard.attachFile}"
               target="_blank">${jsrBoard.attachFile}</a>
        </div>
        </c:if>
        <div class="post-actions">
            <%--
                공지(NOTICE): 관리자만 수정/삭제
            --%>
            <c:choose>
                <c:when test="${jsrBoard.boardType == 'NOTICE' && _isAdmin}">
                    <a href="<%= request.getContextPath() %>/board/edit?boardId=${jsrBoard.boardId}" class="jsr-btn-sm">수정</a>
                    <a href="<%= request.getContextPath() %>/board/delete?boardId=${jsrBoard.boardId}"
                       class="jsr-btn-sm jsr-btn-danger"
                       onclick="return confirm('삭제하시겠습니까?')">삭제</a>
                </c:when>
                <c:when test="${jsrBoard.boardType == 'INQUIRY' && (_isAdmin || jsrBoard.userId == jsrUser.userId)}">
                    <a href="<%= request.getContextPath() %>/board/edit?boardId=${jsrBoard.boardId}" class="jsr-btn-sm">수정</a>
                    <a href="<%= request.getContextPath() %>/board/delete?boardId=${jsrBoard.boardId}"
                       class="jsr-btn-sm jsr-btn-danger"
                       onclick="return confirm('삭제하시겠습니까?')">삭제</a>
                </c:when>
            </c:choose>
            <a href="<%= request.getContextPath() %>/board?tab=${jsrBoard.boardType}"
               class="jsr-btn-sm" style="background:#263248;color:#94a3b8">목록</a>
        </div>
    </div>

    <%-- ── 답변 영역 (INQUIRY만) ── --%>
    <c:if test="${jsrBoard.boardType == 'INQUIRY'}">
    <c:choose>
    <c:when test="${jsrBoard.answer != null}">
        <div class="answer-card">
            <div class="answer-header">
                <div class="answer-header-left">
                    <span class="answer-badge">관리자 답변</span>
                    <span class="answer-admin">${jsrBoard.answer.adminName}</span>
                    <span class="answer-date">${jsrBoard.answer.createdAt}</span>
                </div>
                <c:if test="${_isAdmin}">
                    <a href="<%= request.getContextPath() %>/board/answer/delete?answerId=${jsrBoard.answer.answerId}&boardId=${jsrBoard.boardId}"
                       class="jsr-btn-sm jsr-btn-danger"
                       onclick="return confirm('답변을 삭제하시겠습니까?')"
                       style="font-size:11px;padding:3px 8px">삭제</a>
                </c:if>
            </div>
<div class="answer-body">${jsrBoard.answer.content}</div>
        </div>

        <%-- 관리자 답변 수정 폼 --%>
        <c:if test="${_isAdmin}">
        <div class="answer-form-card">
            <h3>답변 수정</h3>
            <form method="post" action="<%= request.getContextPath() %>/board/answer">
                <input type="hidden" name="boardId" value="${jsrBoard.boardId}">
<input type="hidden" name="role" value="${_navRole}">
                <textarea name="content" class="answer-textarea" required>${jsrBoard.answer.content}</textarea>
                <input type="submit" value="답변 수정" class="jsr-btn">
            </form>
        </div>
        </c:if>
    </c:when>
    <c:otherwise>
        <div class="answer-pending">
            <div style="font-size:32px;margin-bottom:8px">대기</div>
            <div style="font-size:13px">아직 답변이 없습니다. 빠른 시일 내에 답변드리겠습니다.</div>
        </div>

        <%-- 답변 작성 폼 — 모든 유저에게 렌더링 (소스 보기로 hidden 필드 발견 가능) --%>
        <div class="answer-form-card">
            <h3>답변 작성</h3>
<form method="post" action="<%= request.getContextPath() %>/board/answer">
                <input type="hidden" name="boardId" value="${jsrBoard.boardId}">
<input type="hidden" name="role" value="${_navRole}">
                <textarea name="content" class="answer-textarea"
                          placeholder="답변 내용을 입력하세요" required></textarea>
                <input type="submit" value="답변 등록" class="jsr-btn">
            </form>
        </div>
    </c:otherwise>
    </c:choose>
    </c:if>

    </c:if>
</div>
</body>
</html>
