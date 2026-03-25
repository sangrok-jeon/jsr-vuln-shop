package com.jsr.ctf;

import java.io.Serializable;

public class JsrUser implements Serializable {
    private long   userId;
    private String username;
    private String password;
    private String email;
    private String role;      // USER / ADMIN
    private int    point;
    private String address;
    private String phone;
    private String createdAt;

    public long   getUserId()    { return userId; }
    public String getUsername()  { return username; }
    public String getPassword()  { return password; }
    public String getEmail()     { return email; }
    public String getRole()      { return role; }
    public int    getPoint()     { return point; }
    public String getAddress()   { return address; }
    public String getPhone()     { return phone; }
    public String getCreatedAt() { return createdAt; }

    public void setUserId(long v)     { this.userId = v; }
    public void setUsername(String v) { this.username = v; }
    public void setPassword(String v) { this.password = v; }
    public void setEmail(String v)    { this.email = v; }
    public void setRole(String v)     { this.role = v; }
    public void setPoint(int v)       { this.point = v; }
    public void setAddress(String v)  { this.address = v; }
    public void setPhone(String v)    { this.phone = v; }
    public void setCreatedAt(String v){ this.createdAt = v; }
}
