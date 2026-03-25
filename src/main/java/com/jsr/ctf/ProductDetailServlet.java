package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/product/detail", "/product/review"})
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long productId = Long.parseLong(request.getParameter("productId"));

        JsrProduct product = null;
        List<JsrReview> reviews = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            ps = conn.prepareStatement("SELECT * FROM JSR_PRODUCTS WHERE PRODUCT_ID=?");
            ps.setLong(1, productId);
            rs = ps.executeQuery();
            if (rs.next()) {
                product = new JsrProduct();
                product.setProductId(rs.getLong("PRODUCT_ID"));
                product.setName(rs.getString("NAME"));
                product.setDescription(rs.getString("DESCRIPTION"));
                product.setPrice(rs.getInt("PRICE"));
                product.setStock(rs.getInt("STOCK"));
                product.setCategory(rs.getString("CATEGORY"));
                product.setImageUrl(rs.getString("IMAGE_URL"));
            }
            DBUtil.close(rs, ps);

            ps = conn.prepareStatement(
                "SELECT r.*, u.USERNAME FROM JSR_REVIEWS r " +
                "JOIN JSR_USERS u ON r.USER_ID = u.USER_ID " +
                "WHERE r.PRODUCT_ID=? ORDER BY r.REVIEW_ID DESC");
            ps.setLong(1, productId);
            rs = ps.executeQuery();
            while (rs.next()) {
                JsrReview r = new JsrReview();
                r.setReviewId(rs.getLong("REVIEW_ID"));
                r.setProductId(productId);
                r.setUserId(rs.getLong("USER_ID"));
                r.setUsername(rs.getString("USERNAME"));
                r.setContent(rs.getString("CONTENT"));
                r.setRating(rs.getInt("RATING"));
                r.setCreatedAt(rs.getString("CREATED_AT"));
                reviews.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, ps, conn);
        }

        request.setAttribute("jsrProduct", product);
        request.setAttribute("jsrReviews", reviews);
        request.setAttribute("jsrIsBuyer", hasPurchased(user.getUserId(), productId));
        request.getRequestDispatcher("/WEB-INF/views/product_detail_view.jsp")
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

        long   productId = Long.parseLong(request.getParameter("productId"));
        String content   = request.getParameter("content");
        int    rating    = Integer.parseInt(request.getParameter("rating"));

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "INSERT INTO JSR_REVIEWS (REVIEW_ID,PRODUCT_ID,USER_ID,USERNAME,CONTENT,RATING,CREATED_AT) " +
                "VALUES (JSR_REVIEW_SEQ.NEXTVAL,?,?,?,?,?,SYSDATE)");
            ps.setLong(1, productId);
            ps.setLong(2, user.getUserId());
            ps.setString(3, user.getUsername());
            ps.setString(4, content);
            ps.setInt(5, rating);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(ps, conn);
        }

        response.sendRedirect(request.getContextPath() +
            "/product/detail?productId=" + productId);
    }

    private boolean hasPurchased(long userId, long productId) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM JSR_ORDERS " +
                "WHERE USER_ID=? AND PRODUCT_ID=? AND STATUS='PAID'");
            ps.setLong(1, userId);
            ps.setLong(2, productId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return false;
    }
}
