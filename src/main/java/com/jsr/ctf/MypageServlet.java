package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/mypage", "/mypage/update", "/mypage/pw_change"})
public class MypageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        JsrUser fresh = getUserById(user.getUserId());
        List<JsrOrder> orders = getRecentOrders(user.getUserId());

        request.setAttribute("jsrUser",   fresh);
        request.setAttribute("jsrOrders", orders);
        request.getRequestDispatcher("/WEB-INF/views/mypage_view.jsp")
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

        if (path.equals("/mypage/update")) {
            String email   = request.getParameter("email");
            String address = request.getParameter("address");
            String phone   = request.getParameter("phone");
            updateUserInfo(user.getUserId(), email, address, phone);

            JsrUser fresh = getUserById(user.getUserId());
            request.getSession().setAttribute("jsrUser", fresh);
            response.sendRedirect(request.getContextPath() + "/mypage?updated=1");

        } else if (path.equals("/mypage/pw_change")) {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("password");
            String confirmPassword = request.getParameter("password2");
            JsrUser fresh = getUserById(user.getUserId());

            if (fresh == null || currentPassword == null
                    || !PasswordUtil.matches(currentPassword, fresh.getPassword())) {
                response.sendRedirect(request.getContextPath() + "/mypage?pwError=current");
                return;
            }
            if (newPassword == null || newPassword.trim().isEmpty()
                    || !newPassword.equals(confirmPassword)) {
                response.sendRedirect(request.getContextPath() + "/mypage?pwError=mismatch");
                return;
            }

            updatePassword(user.getUserId(), newPassword);
            response.sendRedirect(request.getContextPath() + "/mypage?pwChanged=1");
        }
    }

    // ── DB 헬퍼 ────────────────────────────────────────────────

    private JsrUser getUserById(long userId) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("SELECT * FROM JSR_USERS WHERE USER_ID=?");
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                JsrUser u = new JsrUser();
                u.setUserId(rs.getLong("USER_ID"));
                u.setUsername(rs.getString("USERNAME"));
                u.setPassword(rs.getString("PASSWORD"));
                u.setEmail(rs.getString("EMAIL"));
                u.setRole(rs.getString("ROLE"));
                u.setPoint(rs.getInt("POINT"));
                u.setAddress(rs.getString("ADDRESS"));
                u.setPhone(rs.getString("PHONE"));
                return u;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return null;
    }

    private void updateUserInfo(long userId, String email, String address, String phone) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "UPDATE JSR_USERS SET EMAIL=?,ADDRESS=?,PHONE=? WHERE USER_ID=?");
            ps.setString(1, email); ps.setString(2, address);
            ps.setString(3, phone); ps.setLong(4, userId);
            ps.executeUpdate(); 
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private void updatePassword(long userId, String password) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("UPDATE JSR_USERS SET PASSWORD=? WHERE USER_ID=?");
            ps.setString(1, PasswordUtil.hash(password));
            ps.setLong(2, userId);
            ps.executeUpdate(); 
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private List<JsrOrder> getRecentOrders(long userId) {
        List<JsrOrder> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "SELECT * FROM JSR_ORDERS WHERE USER_ID=? ORDER BY ORDER_ID DESC");
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                JsrOrder o = new JsrOrder();
                o.setOrderId(rs.getLong("ORDER_ID"));
                o.setProductName(rs.getString("PRODUCT_NAME"));
                o.setTotalPrice(rs.getInt("TOTAL_PRICE"));
                o.setStatus(rs.getString("STATUS"));
                o.setCreatedAt(rs.getString("CREATED_AT"));
                list.add(o);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return list;
    }
}
