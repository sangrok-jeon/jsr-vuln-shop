package com.jsr.ctf;

public class JsrOrder {
    private long   orderId;
    private long   userId;
    private String username;
    private long   productId;
    private String productName;
    private int    quantity;
    private int    price;
    private int    totalPrice;
    private String status;
    private String address;
    private String createdAt;
    private String imageUrl;    // 상품 이미지 경로 (JOIN)

    public long   getOrderId()     { return orderId; }
    public long   getUserId()      { return userId; }
    public String getUsername()    { return username; }
    public long   getProductId()   { return productId; }
    public String getProductName() { return productName; }
    public int    getQuantity()    { return quantity; }
    public int    getPrice()       { return price; }
    public int    getTotalPrice()  { return totalPrice; }
    public String getStatus()      { return status; }
    public String getAddress()     { return address; }
    public String getCreatedAt()   { return createdAt; }
    public String getImageUrl()    { return imageUrl; }

    public void setOrderId(long v)      { this.orderId = v; }
    public void setUserId(long v)       { this.userId = v; }
    public void setUsername(String v)   { this.username = v; }
    public void setProductId(long v)    { this.productId = v; }
    public void setProductName(String v){ this.productName = v; }
    public void setQuantity(int v)      { this.quantity = v; }
    public void setPrice(int v)         { this.price = v; }
    public void setTotalPrice(int v)    { this.totalPrice = v; }
    public void setStatus(String v)     { this.status = v; }
    public void setAddress(String v)    { this.address = v; }
    public void setCreatedAt(String v)  { this.createdAt = v; }
    public void setImageUrl(String v)   { this.imageUrl = v; }
}
