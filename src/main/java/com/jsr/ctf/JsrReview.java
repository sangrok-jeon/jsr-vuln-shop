package com.jsr.ctf;

public class JsrReview {
    private long   reviewId;
    private long   productId;
    private long   userId;
    private String username;
    private String content;
    private int    rating;
    private String createdAt;

    public long   getReviewId()  { return reviewId; }
    public long   getProductId() { return productId; }
    public long   getUserId()    { return userId; }
    public String getUsername()  { return username; }
    public String getContent()   { return content; }
    public int    getRating()    { return rating; }
    public String getCreatedAt() { return createdAt; }

    public void setReviewId(long v)    { this.reviewId = v; }
    public void setProductId(long v)   { this.productId = v; }
    public void setUserId(long v)      { this.userId = v; }
    public void setUsername(String v)  { this.username = v; }
    public void setContent(String v)   { this.content = v; }
    public void setRating(int v)       { this.rating = v; }
    public void setCreatedAt(String v) { this.createdAt = v; }
}
