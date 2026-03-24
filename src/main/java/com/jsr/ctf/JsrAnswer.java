package com.jsr.ctf;

public class JsrAnswer {
    private long   answerId;
    private long   boardId;
    private String adminName;
    private String content;
    private String createdAt;

    public long   getAnswerId()  { return answerId; }
    public long   getBoardId()   { return boardId; }
    public String getAdminName() { return adminName; }
    public String getContent()   { return content; }
    public String getCreatedAt() { return createdAt; }

    public void setAnswerId(long v)    { this.answerId = v; }
    public void setBoardId(long v)     { this.boardId = v; }
    public void setAdminName(String v) { this.adminName = v; }
    public void setContent(String v)   { this.content = v; }
    public void setCreatedAt(String v) { this.createdAt = v; }
}
