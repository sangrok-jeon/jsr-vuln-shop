package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/admin/dashboard", "/admin/users",
             "/admin/user_point", "/admin/user_delete", "/admin/user_role",
             "/admin/products", "/admin/product_add",
             "/admin/product_update", "/admin/product_delete",
             "/admin/orders", "/admin/order_status"})
public class AdminServlet extends HttpServlet {

    private boolean checkAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/products");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAdmin(request, response)) return;
        String path = request.getServletPath();

        if (path.equals("/admin/users")) {
            request.setAttribute("jsrUsers", getAllUsers());
            request.getRequestDispatcher("/WEB-INF/views/admin/users_view.jsp")
                   .forward(request, response);

        } else if (path.equals("/admin/products")) {
            request.setAttribute("jsrProducts", getAllProducts());
            request.getRequestDispatcher("/WEB-INF/views/admin/products_view.jsp")
                   .forward(request, response);

        } else if (path.equals("/admin/orders")) {
            request.setAttribute("jsrOrders", getAllOrders());
            request.getRequestDispatcher("/WEB-INF/views/admin/orders_view.jsp")
                   .forward(request, response);

        } else {
            // dashboard
            request.setAttribute("jsrTotalUsers",    count("SELECT COUNT(*) FROM JSR_USERS"));
            request.setAttribute("jsrTotalProducts", count("SELECT COUNT(*) FROM JSR_PRODUCTS"));
            request.setAttribute("jsrTotalOrders",   count("SELECT COUNT(*) FROM JSR_ORDERS"));
            request.setAttribute("jsrTotalRevenue",  count("SELECT NVL(SUM(TOTAL_PRICE),0) FROM JSR_ORDERS"));
            request.getRequestDispatcher("/WEB-INF/views/admin/dashboard_view.jsp")
                   .forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAdmin(request, response)) return;
        String path = request.getServletPath();

        if (path.equals("/admin/user_point")) {
            long userId = Long.parseLong(request.getParameter("userId"));
            int  point  = Integer.parseInt(request.getParameter("point"));
            exec("UPDATE JSR_USERS SET POINT=? WHERE USER_ID=?", point, userId);
            response.sendRedirect(request.getContextPath() + "/admin/users?updated=1");

        } else if (path.equals("/admin/user_delete")) {
            long userId = Long.parseLong(request.getParameter("userId"));
            exec("DELETE FROM JSR_USERS WHERE USER_ID=?", userId);
            response.sendRedirect(request.getContextPath() + "/admin/users?deleted=1");

        } else if (path.equals("/admin/user_role")) {
            long   userId = Long.parseLong(request.getParameter("userId"));
            String role   = request.getParameter("role");
            exec("UPDATE JSR_USERS SET ROLE=? WHERE USER_ID=?", role, userId);

            // 본인 세션도 즉시 반영
            JsrUser sessionUser = (JsrUser) request.getSession().getAttribute("jsrUser");
            if (sessionUser != null && sessionUser.getUserId() == userId) {
                sessionUser.setRole(role);
                request.getSession().setAttribute("jsrUser", sessionUser);
            }
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");

        } else if (path.equals("/admin/product_add")) {
            String name  = request.getParameter("name");
            String desc  = request.getParameter("description");
            int    price = Integer.parseInt(request.getParameter("price"));
            int    stock = Integer.parseInt(request.getParameter("stock"));
            String cat   = request.getParameter("category");
            Connection conn = null; PreparedStatement ps = null;
            try {
                conn = DBUtil.getConnection();
                ps = conn.prepareStatement(
                    "INSERT INTO JSR_PRODUCTS (PRODUCT_ID,NAME,DESCRIPTION,PRICE,STOCK,CATEGORY,CREATED_AT) " +
                    "VALUES (JSR_PRODUCT_SEQ.NEXTVAL,?,?,?,?,?,SYSDATE)");
                ps.setString(1, name); ps.setString(2, desc); ps.setInt(3, price);
                ps.setInt(4, stock); ps.setString(5, cat);
                ps.executeUpdate(); 
            } catch (SQLException e) { e.printStackTrace(); }
            finally { DBUtil.close(ps, conn); }
            response.sendRedirect(request.getContextPath() + "/admin/products?added=1");

        } else if (path.equals("/admin/product_update")) {
            long   productId = Long.parseLong(request.getParameter("productId"));
            String name  = request.getParameter("name");
            String desc  = request.getParameter("description");
            int    price = Integer.parseInt(request.getParameter("price"));
            int    stock = Integer.parseInt(request.getParameter("stock"));
            String cat   = request.getParameter("category");
            exec("UPDATE JSR_PRODUCTS SET NAME=?,DESCRIPTION=?,PRICE=?,STOCK=?,CATEGORY=? WHERE PRODUCT_ID=?",
                 name, desc, price, stock, cat, productId);
            response.sendRedirect(request.getContextPath() + "/admin/products?updated=1");

        } else if (path.equals("/admin/product_delete")) {
            long productId = Long.parseLong(request.getParameter("productId"));
            exec("DELETE FROM JSR_PRODUCTS WHERE PRODUCT_ID=?", productId);
            response.sendRedirect(request.getContextPath() + "/admin/products?deleted=1");

        } else if (path.equals("/admin/order_status")) {
            long   orderId = Long.parseLong(request.getParameter("orderId"));
            String status  = request.getParameter("status");
            exec("UPDATE JSR_ORDERS SET STATUS=? WHERE ORDER_ID=?", status, orderId);
            response.sendRedirect(request.getContextPath() + "/admin/orders?updated=1");
        }
    }

    // ── DB 헬퍼 ────────────────────────────────────────────────

    private List<JsrUser> getAllUsers() {
        List<JsrUser> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("SELECT * FROM JSR_USERS ORDER BY USER_ID");
            rs = ps.executeQuery();
            while (rs.next()) {
                JsrUser u = new JsrUser();
                u.setUserId(rs.getLong("USER_ID"));
                u.setUsername(rs.getString("USERNAME"));
                u.setPassword(rs.getString("PASSWORD"));
                u.setEmail(rs.getString("EMAIL"));
                u.setRole(rs.getString("ROLE"));
                u.setPoint(rs.getInt("POINT"));
                list.add(u);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return list;
    }

    private List<JsrProduct> getAllProducts() {
        List<JsrProduct> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("SELECT * FROM JSR_PRODUCTS ORDER BY PRODUCT_ID");
            rs = ps.executeQuery();
            while (rs.next()) {
                JsrProduct p = new JsrProduct();
                p.setProductId(rs.getLong("PRODUCT_ID"));
                p.setName(rs.getString("NAME"));
                p.setPrice(rs.getInt("PRICE"));
                p.setStock(rs.getInt("STOCK"));
                p.setCategory(rs.getString("CATEGORY"));
                p.setDescription(rs.getString("DESCRIPTION"));
                p.setImageUrl(rs.getString("IMAGE_URL"));
                list.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return list;
    }

    private List<JsrOrder> getAllOrders() {
        List<JsrOrder> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("SELECT * FROM JSR_ORDERS ORDER BY ORDER_ID DESC");
            rs = ps.executeQuery();
            while (rs.next()) {
                JsrOrder o = new JsrOrder();
                o.setOrderId(rs.getLong("ORDER_ID"));
                o.setUsername(rs.getString("USERNAME"));
                o.setProductName(rs.getString("PRODUCT_NAME"));
                o.setQuantity(rs.getInt("QUANTITY"));
                o.setTotalPrice(rs.getInt("TOTAL_PRICE"));
                o.setStatus(rs.getString("STATUS"));
                o.setCreatedAt(rs.getString("CREATED_AT"));
                list.add(o);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return list;
    }

    private int count(String sql) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return 0;
    }

    private void exec(String sql, Object... params) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) {
                if (params[i] instanceof Long)         ps.setLong(i+1, (Long) params[i]);
                else if (params[i] instanceof Integer) ps.setInt(i+1, (Integer) params[i]);
                else                                   ps.setString(i+1, (String) params[i]);
            }
            ps.executeUpdate();
            
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }
}
