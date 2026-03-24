package com.jsr.ctf;

public class JsrPointHistory {
    private long   historyId;
    private long   userId;
    private String type;
    private int    amount;
    private int    balanceAfter;
    private String description;
    private String createdAt;

    public long   getHistoryId()    { return historyId; }
    public long   getUserId()       { return userId; }
    public String getType()         { return type; }
    public int    getAmount()       { return amount; }
    public int    getBalanceAfter() { return balanceAfter; }
    public String getDescription()  { return description; }
    public String getCreatedAt()    { return createdAt; }

    public void setHistoryId(long v)     { this.historyId = v; }
    public void setUserId(long v)        { this.userId = v; }
    public void setType(String v)        { this.type = v; }
    public void setAmount(int v)         { this.amount = v; }
    public void setBalanceAfter(int v)   { this.balanceAfter = v; }
    public void setDescription(String v) { this.description = v; }
    public void setCreatedAt(String v)   { this.createdAt = v; }
}
