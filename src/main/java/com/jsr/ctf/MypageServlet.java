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
            // ⚠️ CSRF: 토큰 검증 없음
            String email   = request.getParameter("email");
            String address = request.getParameter("address");
            String phone   = request.getParameter("phone");
            updateUserInfo(user.getUserId(), email, address, phone);

            /**
             * ⚠️ 수직 권한 상승 취약점 핵심:
             *
             * mypage_view.jsp 기본정보 수정 폼에는 다음 hidden 필드가 포함됨:
             *   <input type="hidden" name="userId" value="2">
             *   <input type="hidden" name="role"   value="USER">
             *
             * 서버는 세션이 아닌 클라이언트가 전송한 role 파라미터를 DB에 반영.
             * 공격 시나리오:
             *   1. Ctrl+U 소스 보기로 hidden 필드 발견
             *   2. Burp Suite로 요청 가로채기
             *   3. role=USER → role=ADMIN 으로 변조 후 전송
             *   4. 일반 유저 → 관리자 승격 완료
             */
            String roleParam   = request.getParameter("role");
            String userIdParam = request.getParameter("userId");
            if (roleParam != null && userIdParam != null) {
                try {
                    long targetId = Long.parseLong(userIdParam);
                    updateRole(targetId, roleParam); // ⚠️ 파라미터 그대로 신뢰
                    if (user.getUserId() == targetId) {
                        user.setRole(roleParam);
                        request.getSession().setAttribute("jsrUser", user);
                    }
                } catch (NumberFormatException ignored) {}
            }

            JsrUser fresh = getUserById(user.getUserId());
            request.getSession().setAttribute("jsrUser", fresh);
            response.sendRedirect(request.getContextPath() + "/mypage?updated=1");

        } else if (path.equals("/mypage/pw_change")) {
            // ⚠️ CSRF: 현재 비밀번호 확인 없음, 토큰 없음
            String newPassword = request.getParameter("password");
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

    private void updateRole(long userId, String role) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("UPDATE JSR_USERS SET ROLE=? WHERE USER_ID=?");
            ps.setString(1, role); // ⚠️ 클라이언트 전송값 그대로 신뢰
            ps.setLong(2, userId);
            ps.executeUpdate(); 
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private void updatePassword(long userId, String password) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("UPDATE JSR_USERS SET PASSWORD=? WHERE USER_ID=?");
            ps.setString(1, password); // ⚠️ 평문 저장
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
