package com.jsr.ctf;

public class JsrBoard {
    private long   boardId;
    private long   userId;
    private String username;
    private String boardType;  // NOTICE / INQUIRY
    private String title;
    private String content;
    private String createdAt;
    private JsrAnswer answer;
    private String attachFile; // ⚠️ 업로드된 파일명 (웹쉘 가능)

    public long      getBoardId()    { return boardId; }
    public long      getUserId()     { return userId; }
    public String    getUsername()   { return username; }
    public String    getBoardType()  { return boardType; }
    public String    getTitle()      { return title; }
    public String    getContent()    { return content; }
    public String    getCreatedAt()  { return createdAt; }
    public JsrAnswer getAnswer()     { return answer; }
    public String    getAttachFile() { return attachFile; }

    public void setBoardId(long v)      { this.boardId = v; }
    public void setUserId(long v)       { this.userId = v; }
    public void setUsername(String v)   { this.username = v; }
    public void setBoardType(String v)  { this.boardType = v; }
    public void setTitle(String v)      { this.title = v; }
    public void setContent(String v)    { this.content = v; }
    public void setCreatedAt(String v)  { this.createdAt = v; }
    public void setAnswer(JsrAnswer v)  { this.answer = v; }
    public void setAttachFile(String v) { this.attachFile = v; }
}
