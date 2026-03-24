package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/cart", "/cart/add", "/cart/update", "/cart/delete"})
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<JsrCartItem> cart = getCart(user.getUserId());
        int total = cart.stream().mapToInt(JsrCartItem::getSubTotal).sum();

        request.setAttribute("jsrCartItems", cart);
        request.setAttribute("jsrCartTotal", total);
        request.getRequestDispatcher("/WEB-INF/views/cart_view.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        if (path.contains("add")) {
            long productId = Long.parseLong(request.getParameter("productId"));
            int  quantity  = Integer.parseInt(request.getParameter("quantity") != null
                                ? request.getParameter("quantity") : "1");
            addToCart(user.getUserId(), productId, quantity);
            response.sendRedirect(request.getContextPath() + "/cart");

        } else if (path.contains("update")) {
            long cartId  = Long.parseLong(request.getParameter("cartId"));
            int  quantity = Integer.parseInt(request.getParameter("quantity"));
            updateCart(cartId, quantity);
            response.sendRedirect(request.getContextPath() + "/cart");

        } else if (path.contains("delete")) {
            long cartId = Long.parseLong(request.getParameter("cartId"));
            deleteCart(cartId);
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private List<JsrCartItem> getCart(long userId) {
        List<JsrCartItem> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "SELECT c.CART_ID, c.USER_ID, c.PRODUCT_ID, c.QUANTITY, " +
                "p.NAME, p.PRICE, p.IMAGE_URL " +
                "FROM JSR_CART c JOIN JSR_PRODUCTS p ON c.PRODUCT_ID = p.PRODUCT_ID " +
                "WHERE c.USER_ID=? ORDER BY c.CART_ID DESC");
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                JsrCartItem item = new JsrCartItem();
                item.setCartId(rs.getLong("CART_ID"));
                item.setUserId(userId);
                item.setProductId(rs.getLong("PRODUCT_ID"));
                item.setProductName(rs.getString("NAME"));
                item.setPrice(rs.getInt("PRICE"));
                item.setQuantity(rs.getInt("QUANTITY"));
                item.setImageUrl(rs.getString("IMAGE_URL"));
                list.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }

    private void addToCart(long userId, long productId, int quantity) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "SELECT CART_ID, QUANTITY FROM JSR_CART WHERE USER_ID=? AND PRODUCT_ID=?");
            ps.setLong(1, userId);
            ps.setLong(2, productId);
            rs = ps.executeQuery();
            if (rs.next()) {
                long cartId = rs.getLong("CART_ID");
                int  newQty = rs.getInt("QUANTITY") + quantity;
                DBUtil.close(rs, ps);
                ps = conn.prepareStatement("UPDATE JSR_CART SET QUANTITY=? WHERE CART_ID=?");
                ps.setInt(1, newQty);
                ps.setLong(2, cartId);
                ps.executeUpdate();
            } else {
                DBUtil.close(rs, ps);
                ps = conn.prepareStatement(
                    "INSERT INTO JSR_CART (CART_ID,USER_ID,PRODUCT_ID,QUANTITY,CREATED_AT) " +
                    "VALUES (JSR_CART_SEQ.NEXTVAL,?,?,?,SYSDATE)");
                ps.setLong(1, userId);
                ps.setLong(2, productId);
                ps.setInt(3, quantity);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, ps, conn);
        }
    }

    private void updateCart(long cartId, int quantity) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            if (quantity <= 0) {
                ps = conn.prepareStatement("DELETE FROM JSR_CART WHERE CART_ID=?");
            } else {
                ps = conn.prepareStatement("UPDATE JSR_CART SET QUANTITY=? WHERE CART_ID=?");
                ps.setInt(1, quantity);
            }
            ps.setLong(quantity <= 0 ? 1 : 2, cartId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(ps, conn);
        }
    }

    private void deleteCart(long cartId) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("DELETE FROM JSR_CART WHERE CART_ID=?");
            ps.setLong(1, cartId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(ps, conn);
        }
    }
}
