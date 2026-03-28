<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Q&A - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    .board-wrap { max-width:900px; margin:36px auto 60px; padding:0 24px; animation:fadeUp .35s ease both; }
    @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }

    .tab-bar { display:flex; gap:0; margin-bottom:24px; border-bottom:2px solid #334155; }
    .tab-btn {
        padding:10px 24px; font-size:14px; font-weight:600; cursor:pointer;
        color:#64748b; border:none; background:none; border-bottom:2px solid transparent;
        margin-bottom:-2px; transition:all .15s; font-family:inherit;
    }
    .tab-btn:hover { color:#e2e8f0; }
    .tab-btn.active { color:#38bdf8; border-bottom-color:#38bdf8; }

    .tab-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:16px; }
    .tab-desc { font-size:12px; color:#475569; }
.idor-box {
        background:rgba(239,68,68,0.08); border:1px solid rgba(239,68,68,0.3);
        border-left:3px solid #ef4444; border-radius:8px;
        padding:10px 14px; font-size:12px; color:#fca5a5; margin-bottom:18px; line-height:1.7;
    }
    .idor-box code { background:rgba(239,68,68,0.15); border-radius:3px; padding:1px 5px; font-family:monospace; color:#ef4444; }

    .inquiry-list { display:flex; flex-direction:column; gap:8px; }
    .inquiry-card {
        background:#1e293b; border:1px solid #334155; border-radius:10px;
        padding:16px 20px; text-decoration:none; display:block; transition:border-color .15s;
    }
    .inquiry-card:hover { border-color:#38bdf8; }

    .card-top { display:flex; align-items:center; gap:10px; margin-bottom:6px; }
    .card-no    { font-size:12px; color:#475569; font-family:monospace; }
    .card-title { font-size:14px; font-weight:700; color:#f1f5f9; flex:1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .badge-answered { font-size:11px; font-weight:700; padding:2px 8px; border-radius:4px; background:rgba(34,197,94,0.15); color:#22c55e; border:1px solid rgba(34,197,94,0.3); }
    .badge-waiting  { font-size:11px; font-weight:700; padding:2px 8px; border-radius:4px; background:rgba(100,116,139,0.1); color:#64748b; border:1px solid #334155; }
    .badge-notice   { font-size:11px; font-weight:700; padding:2px 8px; border-radius:4px; background:rgba(56,189,248,0.15); color:#38bdf8; border:1px solid rgba(56,189,248,0.3); }

    .card-meta { font-size:12px; color:#64748b; display:flex; gap:14px; }
    .card-meta .author { color:#94a3b8; }

    .pagination { display:flex; gap:6px; justify-content:center; margin-top:20px; }
    .page-btn { background:#1e293b; border:1px solid #334155; color:#94a3b8; border-radius:6px; padding:6px 12px; font-size:13px; text-decoration:none; transition:all .15s; }
    .page-btn:hover { border-color:#38bdf8; color:#38bdf8; }
    .page-btn.active { background:#38bdf8; border-color:#38bdf8; color:#0f172a; font-weight:700; }

    .empty-state { text-align:center; padding:50px 20px; color:#475569; }
    .empty-icon  { font-size:40px; margin-bottom:10px; }

    .alert { padding:9px 14px; border-radius:8px; font-size:13px; margin-bottom:14px; }
    .alert-success { background:rgba(34,197,94,0.1); border:1px solid rgba(34,197,94,0.3); color:#86efac; }
    .alert-error   { background:rgba(239,68,68,0.1); border:1px solid rgba(239,68,68,0.3); color:#fca5a5; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="board-wrap">

    <c:if test="${param.deleted == '1'}"><div class="alert alert-success">삭제되었습니다.</div></c:if>
    <c:if test="${param.error == 'noperm'}"><div class="alert alert-error">권한이 없습니다.</div></c:if>
    <c:if test="${param.error == 'idor'}">
는 타인의 문의입니다.
            먼저 관리자 권한을 획득한 후 재시도해보세요!
        </div>
    </c:if>
<div class="tab-bar">
        <button class="tab-btn ${jsrTab == 'NOTICE' ? 'active' : ''}"
                onclick="location.href='<%= request.getContextPath() %>/board?tab=NOTICE'">
            공지사항
        </button>
        <button class="tab-btn ${jsrTab == 'INQUIRY' ? 'active' : ''}"
                onclick="location.href='<%= request.getContextPath() %>/board?tab=INQUIRY'">
            1:1 문의
            <c:if test="${jsrIsAdmin}"><span style="font-size:10px;color:#ef4444;margin-left:3px">(전체)</span></c:if>
        </button>
    </div>

    <%-- ── 공지사항 탭 ── --%>
    <c:if test="${jsrTab == 'NOTICE'}">
        <div class="tab-header">
            <div class="tab-desc">관리자가 작성한 공지사항입니다. 모든 회원이 열람 가능합니다.</div>
            <c:if test="${jsrIsAdmin}">
                <a href="<%= request.getContextPath() %>/board/write?type=NOTICE" class="jsr-btn">공지 작성</a>
            </c:if>
        </div>
        <c:choose>
        <c:when test="${empty jsrNotices}">
            <div class="empty-state"><div class="empty-icon"></div><div>등록된 공지사항이 없습니다.</div></div>
        </c:when>
        <c:otherwise>
        <div class="inquiry-list">
        <c:forEach var="b" items="${jsrNotices}">
        <a href="<%= request.getContextPath() %>/board/detail?boardId=${b.boardId}" class="inquiry-card">
            <div class="card-top">
                <span class="card-no">#${b.boardId}</span>
                <span class="card-title">${b.title}</span>
                <span class="badge-notice">공지</span>
            </div>
            <div class="card-meta">
                <span class="author">${b.username}</span>
                <span>${b.createdAt}</span>
            </div>
        </a>
        </c:forEach>
        </div>
        </c:otherwise>
        </c:choose>
    </c:if>

    <%-- ── 문의 탭 ── --%>
    <c:if test="${jsrTab == 'INQUIRY'}">
        <div class="tab-header">
            <div class="tab-desc">
                <c:choose>
                    <c:when test="${jsrIsAdmin}">🔑 관리자: 모든 회원의 문의를 열람합니다.</c:when>
                    <c:otherwise>내 문의만 표시됩니다. 타인의 문의는 열람 불가합니다.</c:otherwise>
                </c:choose>
            </div>
            <a href="<%= request.getContextPath() %>/board/write?type=INQUIRY" class="jsr-btn">문의하기</a>
        </div>
        <c:choose>
        <c:when test="${empty jsrInquiries}">
            <div class="empty-state">
                <div class="empty-icon"></div>
                <div style="margin-bottom:14px">아직 문의가 없습니다.</div>
                <a href="<%= request.getContextPath() %>/board/write?type=INQUIRY" class="jsr-btn">문의 작성하기</a>
            </div>
        </c:when>
        <c:otherwise>
        <div class="inquiry-list">
        <c:forEach var="b" items="${jsrInquiries}">
        <a href="<%= request.getContextPath() %>/board/detail?boardId=${b.boardId}" class="inquiry-card">
            <div class="card-top">
                <span class="card-no">#${b.boardId}</span>
                <span class="card-title">${b.title}</span>
                <c:choose>
                    <c:when test="${b.answer != null}"><span class="badge-answered">답변완료</span></c:when>
                    <c:otherwise><span class="badge-waiting">답변대기</span></c:otherwise>
                </c:choose>
            </div>
            <div class="card-meta">
                <span class="author">${b.username}</span>
                <span>${b.createdAt}</span>
            </div>
        </a>
        </c:forEach>
        </div>
        <c:if test="${jsrTotalPages > 1}">
        <div class="pagination">
            <c:if test="${jsrPage > 1}"><a href="<%= request.getContextPath() %>/board?tab=INQUIRY&page=${jsrPage-1}" class="page-btn">‹</a></c:if>
            <c:forEach begin="1" end="${jsrTotalPages}" var="p">
                <a href="<%= request.getContextPath() %>/board?tab=INQUIRY&page=${p}"
                   class="page-btn ${p == jsrPage ? 'active' : ''}">${p}</a>
            </c:forEach>
            <c:if test="${jsrPage < jsrTotalPages}"><a href="<%= request.getContextPath() %>/board?tab=INQUIRY&page=${jsrPage+1}" class="page-btn">›</a></c:if>
        </div>
        </c:if>
        </c:otherwise>
        </c:choose>
    </c:if>

</div>
</body>
</html>
