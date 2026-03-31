# 04. Inquiry Security

## 媛쒖슂

1:1 臾몄쓽 湲곕뒫?먯꽌?????臾몄쓽湲 ?곸꽭議고쉶??李⑤떒?섏?留??섏젙怨???젣 ?붿껌?먮뒗 ?숈씪???묒꽦??寃利앹씠 ?곸슜?섏? ?딅뒗??  
洹?寃곌낵 ?ㅻⅨ ?ъ슜??怨꾩젙?쇰줈 ??몄쓽 臾몄쓽湲??吏곸젒 ?섏젙?섍굅????젣?????덈떎.

## 吏꾩엯??- `/jsr/board?tab=INQUIRY`
- `/jsr/board/detail`
- `/jsr/board/edit`
- `/jsr/board/delete`

## ?ы븿 ?댁뒋

| 援щ텇 | 痍⑥빟??| ?ㅻ챸 |
| --- | --- | --- |
| 二쇱슂 痍⑥빟??| Broken Access Control / IDOR | 臾몄쓽湲 ?섏젙怨???젣 ?붿껌?먯꽌 ?묒꽦???먮뒗 愿由ъ옄 ?щ?瑜?寃利앺븯吏 ?딆븘 ?ㅻⅨ ?ъ슜?먭? ??몄쓽 臾몄쓽瑜??섏젙?섍굅????젣?????덈떎. |
| 愿???댁뒋 | Hidden Field Role Trust | ?듬? ?깅줉 ?붿껌?먯꽌 hidden `role` 媛믪쓣 ?좊ː?섎?濡??쒕쾭 ?몄뀡 湲곗? 沅뚰븳 寃利앹씠 ?꾩슂?섎떎. |

## 痍⑥빟??遺遺?
臾몄쓽湲 ?곸꽭議고쉶(`/board/detail`)???묒꽦???먮뒗 愿由ъ옄留??묎렐?????덈룄濡??쒗븳?섏뼱 ?덉?留? ?섏젙(`/board/edit`)怨???젣(`/board/delete`)??媛숈? `boardId`留??뚮㈃ ?ㅽ뻾?쒕떎.  
?숈씪??寃뚯떆??湲곕뒫 ?덉뿉?쒕룄 ?묎렐 ?듭젣媛 ?쇨??섏? ?딆븘 臾몄쓽湲 臾대떒 ?섏젙怨???젣媛 媛?ν븯??

## 痍⑥빟??肄붾뱶

?뚯씪: [`src/main/java/com/jsr/ctf/BoardServlet.java`](../src/main/java/com/jsr/ctf/BoardServlet.java)

```java
} else if (path.equals("/board/edit")) {
    long boardId = Long.parseLong(request.getParameter("boardId"));
    JsrBoard board = getBoardById(boardId);
    if (board == null) {
        response.sendRedirect(request.getContextPath() + "/board");
        return;
    }
    request.setAttribute("jsrBoard", board);
    request.setAttribute("writeType", board.getBoardType());
    request.getRequestDispatcher("/WEB-INF/views/board_write_view.jsp")
           .forward(request, response);

} else if (path.equals("/board/delete")) {
    long boardId = Long.parseLong(request.getParameter("boardId"));
    JsrBoard board = getBoardById(boardId);
    String type = (board != null) ? board.getBoardType() : "INQUIRY";
    deleteBoard(boardId);
    response.sendRedirect(request.getContextPath() + "/board?tab=" + type + "&deleted=1");
}
```

```java
} else if (path.equals("/board/edit")) {
    long boardId = Long.parseLong(request.getParameter("boardId"));
    String title = request.getParameter("title");
    String content = request.getParameter("content");

    updateBoard(boardId, title, content, savedFileName);
    response.sendRedirect(request.getContextPath() + "/board/detail?boardId=" + boardId);
}
```

?뚯씪: [`src/main/webapp/WEB-INF/views/board_detail_view.jsp`](../src/main/webapp/WEB-INF/views/board_detail_view.jsp)

```jsp
<form method="post" action="<%= request.getContextPath() %>/board/answer">
    <input type="hidden" name="boardId" value="${jsrBoard.boardId}">
    <input type="hidden" name="role" value="${_navRole}">
    <textarea name="content" class="answer-textarea" required></textarea>
    <input type="submit" value="?듬? ?깅줉" class="jsr-btn">
</form>
```

## 痍⑥빟??肄붾뱶 ?숈옉 ?ㅻ챸

- ?곸꽭議고쉶???묒꽦???먮뒗 愿由ъ옄 ?щ?瑜??뺤씤?섏?留??섏젙怨???젣??媛숈? 寃利??놁씠 `boardId`留뚯쑝濡?泥섎━?쒕떎.
- ?ㅻⅨ ?ъ슜??怨꾩젙????몄쓽 `boardId`瑜??뚮㈃ ?섏젙 ?섏씠吏??吏꾩엯?섍퀬 ?댁슜??蹂寃쏀븷 ???덈떎.
- ??젣 ?붿껌???숈씪??寃利??놁씠 ?ㅽ뻾?섏뼱 ??몄쓽 臾몄쓽湲???쒓굅?????덈떎.
- ?듬? ?깅줉 ??떆 hidden `role` 媛믪쓣 ?④퍡 ?꾩넚?섎?濡??쒕쾭媛 ?몄뀡 沅뚰븳 ????붿껌 ?뚮씪誘명꽣瑜??좊ː?섎㈃ 沅뚰븳 寃利??고쉶 ?꾪뿕??諛쒖깮?쒕떎.

## 痍⑥빟??肄붾뱶 利앹쟻?먮즺

### 1. ?먮낯 臾몄쓽湲 ?곸꽭 ?붾㈃

- `test001` 怨꾩젙???묒꽦??臾몄쓽湲 `#9`??湲곗? ?곹깭?대떎.

![?먮낯 臾몄쓽湲 ?곸꽭 ?붾㈃](images/04-inquiry-security/01-original-inquiry-detail.png)

### 2. ???臾몄쓽湲 ?섏젙 ?섏씠吏 臾대떒 ?묎렐

- `test002` 怨꾩젙??吏곸젒 `/board/edit?boardId=9`???묎렐???섏젙 ?붾㈃???댁뿀??

![???臾몄쓽湲 ?섏젙 ?섏씠吏 臾대떒 ?묎렐](images/04-inquiry-security/02-unauthorized-edit-access.png)

### 3. ???臾몄쓽湲 ?섏젙 寃곌낵 ?뺤씤

- `test001` 怨꾩젙?쇰줈 ?ㅼ떆 ?뺤씤?덉쓣 ??蹂몃Ц??`test002媛 ?섏젙??`?쇰줈 諛붾뚯뿀??

![???臾몄쓽湲 ?섏젙 寃곌낵 ?뺤씤](images/04-inquiry-security/03-inquiry-modified-result.png)

### 4. ???臾몄쓽湲 ??젣 ?깃났

- `test002` 怨꾩젙??吏곸젒 `/board/delete?boardId=9` ?붿껌??蹂대궡 ??젣瑜??섑뻾?덈떎.

![???臾몄쓽湲 ??젣 ?깃났](images/04-inquiry-security/04-unauthorized-delete-success.png)

### 5. ??젣 ??臾몄쓽湲 ?щ씪吏??뺤씤

- `test001` 怨꾩젙?쇰줈 ?ㅼ떆 議고쉶?덉쓣 ??臾몄쓽湲??紐⑸줉?먯꽌 ?щ씪議뚮떎.

![??젣 ??臾몄쓽湲 ?щ씪吏??뺤씤](images/04-inquiry-security/05-inquiry-deleted-confirmed.png)

## ?곹뼢

- ???臾몄쓽湲 臾대떒 ?섏젙 媛??- ???臾몄쓽湲 臾대떒 ??젣 媛??- 臾몄쓽 ?대젰 ?꾨?議?媛??- 寃뚯떆??湲곕뒫 ???묎렐 ?듭젣 ?뺤콉 遺덉씪移?
## ???諛⑹븞

- 臾몄쓽湲 ?섏젙怨???젣 ?꾩뿉 ?묒꽦???먮뒗 愿由ъ옄 沅뚰븳???쒕쾭?먯꽌 寃利앺븯湲?- 寃뚯떆湲 ??낆씠 `NOTICE`??寃쎌슦 愿由ъ옄留??섏젙怨???젣瑜??덉슜?섍린
- ?듬? ?깅줉怨???젣??hidden `role` 媛믪씠 ?꾨땲???몄뀡??愿由ъ옄 沅뚰븳?쇰줈 寃利앺븯湲?- 愿由ъ옄 ?꾩슜 ?듬? ?쇱? ?쒕쾭 ?뚮뜑留??④퀎?먯꽌 愿由ъ옄?먭쾶留??몄텧?섍린

## ?섏젙 肄붾뱶 ?덉떆

?곸슜 釉뚮옖移? [`patched`](https://github.com/sangrok-jeon/jsr-vuln-shop/tree/patched)

?곸슜 ?뚯씪:

- [`patched/src/main/java/com/jsr/ctf/BoardServlet.java`](https://github.com/sangrok-jeon/jsr-vuln-shop/blob/patched/src/main/java/com/jsr/ctf/BoardServlet.java)
- [`patched/src/main/webapp/WEB-INF/views/board_detail_view.jsp`](https://github.com/sangrok-jeon/jsr-vuln-shop/blob/patched/src/main/webapp/WEB-INF/views/board_detail_view.jsp)

```java
private boolean canManageBoard(JsrBoard board, JsrUser user, boolean isAdmin) {
    if (board == null) return false;
    if ("NOTICE".equals(board.getBoardType())) return isAdmin;
    return isAdmin || board.getUserId() == user.getUserId();
}
```

```java
} else if (path.equals("/board/edit")) {
    long boardId = Long.parseLong(request.getParameter("boardId"));
    JsrBoard board = getBoardById(boardId);
    if (board == null) {
        response.sendRedirect(request.getContextPath() + "/board?error=notfound");
        return;
    }
    if (!canManageBoard(board, user, isAdmin)) {
        response.sendRedirect(request.getContextPath()
            + "/board?error=" + getBoardAccessError(board, isAdmin) + "&boardId=" + boardId);
        return;
    }
    request.setAttribute("jsrBoard", board);
    request.setAttribute("writeType", board.getBoardType());
    request.getRequestDispatcher("/WEB-INF/views/board_write_view.jsp")
           .forward(request, response);
}
```

```java
} else if (path.equals("/board/delete")) {
    long boardId = Long.parseLong(request.getParameter("boardId"));
    JsrBoard board = getBoardById(boardId);
    if (board == null) {
        response.sendRedirect(request.getContextPath() + "/board?error=notfound");
        return;
    }
    if (!canManageBoard(board, user, isAdmin)) {
        response.sendRedirect(request.getContextPath()
            + "/board?error=" + getBoardAccessError(board, isAdmin) + "&boardId=" + boardId);
        return;
    }
    deleteBoard(boardId);
    response.sendRedirect(request.getContextPath()
        + "/board?tab=" + board.getBoardType() + "&deleted=1");
}
```

```java
} else if (path.equals("/board/answer")) {
    long boardId = Long.parseLong(request.getParameter("boardId"));
    JsrBoard board = getBoardById(boardId);
    if (board == null) {
        response.sendRedirect(request.getContextPath() + "/board?error=notfound");
        return;
    }

    String content = request.getParameter("content");
    if (!isAdmin || !"INQUIRY".equals(board.getBoardType())) {
        response.sendRedirect(request.getContextPath()
            + "/board/detail?boardId=" + boardId + "&error=noperm");
        return;
    }
```

```jsp
<c:if test="${_isAdmin}">
    <div class="answer-form-card">
        <h3>?듬? ?묒꽦</h3>
        <form method="post" action="<%= request.getContextPath() %>/board/answer">
            <input type="hidden" name="boardId" value="${jsrBoard.boardId}">
            <textarea name="content" class="answer-textarea"
                      placeholder="?듬? ?댁슜???낅젰?섏꽭?? required></textarea>
            <input type="submit" value="?듬? ?깅줉" class="jsr-btn">
        </form>
    </div>
</c:if>
```

## ???肄붾뱶 ?숈옉 ?ㅻ챸

- ?섏젙怨???젣 ?붿껌? 癒쇱? `boardId`濡?寃뚯떆湲??議고쉶????`canManageBoard()`濡??묒꽦???먮뒗 愿由ъ옄 ?щ?瑜?寃利앺븳??
- ?쇰컲 ?ъ슜?먭? ??몄쓽 臾몄쓽湲???묎렐?섎㈃ 利됱떆 `error=idor`濡?由щ떎?대젆?몃릺???섏젙怨???젣媛 ?ㅽ뻾?섏? ?딅뒗??
- ?듬? ?깅줉怨???젣??hidden `role` 媛믪씠 ?꾨땲???몄뀡??愿由ъ옄 沅뚰븳?쇰줈留??덉슜?쒕떎.
- ?듬? ?묒꽦 ?쇰룄 愿由ъ옄?먭쾶留??뚮뜑留곷릺誘濡??쇰컲 ?ъ슜?먮뒗 釉뚮씪?곗? ?붾㈃?먯꽌 愿由ъ옄???붿껌??留뚮뱾 ???녿떎.

## ?????利앹쟻?먮즺

### 1. 대응 코드 적용 후 기준 문의글 확인

- `test001` 계정이 새로 작성한 문의글 `#10`의 기준 상태이다.

![대응 코드 적용 후 기준 문의글 확인](images/04-inquiry-security/06-remediated-inquiry-detail.png)

### 2. 타인 문의글 수정 접근 차단 결과

- `test002` 계정이 `/board/edit?boardId=10`으로 접근을 시도했지만 `error=idor`로 차단되었다.

![타인 문의글 수정 접근 차단 결과](images/04-inquiry-security/07-unauthorized-edit-blocked-result.png)

### 3. 타인 문의글 삭제 직접 시도

- `test002` 계정이 `/board/delete?boardId=10` 요청을 직접 실행했다.

![타인 문의글 삭제 직접 시도](images/04-inquiry-security/08-unauthorized-delete-attempt-fixed.png)

### 4. 삭제 접근 차단 결과

- 삭제 요청 역시 `error=idor`로 차단되어 문의글이 그대로 유지되었다.

![삭제 접근 차단 결과](images/04-inquiry-security/09-unauthorized-delete-blocked-result.png)
