package com.jsr.ctf;

public class JsrCartItem {
    private long   cartId;
    private long   userId;
    private long   productId;
    private String productName;
    private int    price;
    private int    quantity;
    private String imageUrl;

    public long   getCartId()      { return cartId; }
    public long   getUserId()      { return userId; }
    public long   getProductId()   { return productId; }
    public String getProductName() { return productName; }
    public int    getPrice()       { return price; }
    public int    getQuantity()    { return quantity; }
    public String getImageUrl()    { return imageUrl; }
    public int    getSubTotal()    { return price * quantity; }

    public void setCartId(long v)       { this.cartId = v; }
    public void setUserId(long v)       { this.userId = v; }
    public void setProductId(long v)    { this.productId = v; }
    public void setProductName(String v){ this.productName = v; }
    public void setPrice(int v)         { this.price = v; }
    public void setQuantity(int v)      { this.quantity = v; }
    public void setImageUrl(String v)   { this.imageUrl = v; }
}
