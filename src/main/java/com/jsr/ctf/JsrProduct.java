package com.jsr.ctf;

public class JsrProduct {
    private long   productId;
    private String name;
    private String description;
    private int    price;
    private int    stock;
    private String category;
    private String imageUrl;
    private String createdAt;

    public long   getProductId()   { return productId; }
    public String getName()        { return name; }
    public String getDescription() { return description; }
    public int    getPrice()       { return price; }
    public int    getStock()       { return stock; }
    public String getCategory()    { return category; }
    public String getImageUrl()    { return imageUrl; }
    public String getCreatedAt()   { return createdAt; }

    public void setProductId(long v)    { this.productId = v; }
    public void setName(String v)       { this.name = v; }
    public void setDescription(String v){ this.description = v; }
    public void setPrice(int v)         { this.price = v; }
    public void setStock(int v)         { this.stock = v; }
    public void setCategory(String v)   { this.category = v; }
    public void setImageUrl(String v)   { this.imageUrl = v; }
    public void setCreatedAt(String v)  { this.createdAt = v; }
}
