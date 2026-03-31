package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/point", "/point/charge", "/point/use"})
public class PointServlet extends HttpServlet {

    // ── 정상 제한값 (서버사이드 검증) ──────────────────────────
    private static final int MAX_CHARGE_ONCE = 100_000;   // 1회 최대 충전 10만P
    private static final int MAX_POINT_TOTAL = 500_000;   // 최대 보유 50만P

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        JsrUser fresh = getUserById(user.getUserId());
        List<JsrPointHistory> history = getHistory(user.getUserId());

        request.setAttribute("jsrUser",         fresh);
        request.setAttribute("jsrHistory",       history);
        request.setAttribute("jsrMaxChargeOnce", MAX_CHARGE_ONCE);
        request.setAttribute("jsrMaxTotal",      MAX_POINT_TOTAL);
        request.getRequestDispatcher("/WEB-INF/views/point_view.jsp")
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

        String path      = request.getServletPath();
        String amountStr = request.getParameter("amount");

        // ── 빈값 / 형식 오류 방어 (500 에러 방지) ──────────────
        if (amountStr == null || amountStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/point?error=empty");
            return;
        }
        int amount;
        try {
            amount = Integer.parseInt(amountStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/point?error=invalid");
            return;
        }

        JsrUser fresh = getUserById(user.getUserId());
        if (fresh == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (path.contains("charge")) {
            // ── 충전 ──────────────────────────────────────────
            // 검증 1: 0 이하 차단
            if (amount <= 0) {
                response.sendRedirect(request.getContextPath() + "/point?error=negative");
                return;
            }


            int newPoint = fresh.getPoint() + amount;
            updatePoint(user.getUserId(), newPoint);
            saveHistory(user.getUserId(), "CHARGE", amount, newPoint, "포인트 충전");
            fresh.setPoint(newPoint);
            request.getSession().setAttribute("jsrUser", fresh);
            response.sendRedirect(request.getContextPath() + "/point?charged=1");

        } else if (path.contains("use")) {
            // ── 사용 ──────────────────────────────────────────
            if (amount <= 0) {
                response.sendRedirect(request.getContextPath() + "/point?error=negative");
                return;
            }
            int newPoint = fresh.getPoint() - amount;
            updatePoint(user.getUserId(), newPoint);
            saveHistory(user.getUserId(), "USE", amount, newPoint, "포인트 사용");
            fresh.setPoint(newPoint);
            request.getSession().setAttribute("jsrUser", fresh);
            response.sendRedirect(request.getContextPath() + "/point?used=1");
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
                u.setPoint(rs.getInt("POINT"));
                u.setRole(rs.getString("ROLE"));
                u.setEmail(rs.getString("EMAIL"));
                u.setAddress(rs.getString("ADDRESS"));
                u.setPhone(rs.getString("PHONE"));
                return u;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return null;
    }

    private void updatePoint(long userId, int point) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("UPDATE JSR_USERS SET POINT=? WHERE USER_ID=?");
            ps.setInt(1, point);
            ps.setLong(2, userId);
            ps.executeUpdate();
            
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private void saveHistory(long userId, String type, int amount, int balanceAfter, String desc) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "INSERT INTO JSR_POINT_HISTORY " +
                "(HISTORY_ID,USER_ID,TYPE,AMOUNT,BALANCE_AFTER,DESCRIPTION,CREATED_AT) " +
                "VALUES (JSR_POINT_SEQ.NEXTVAL,?,?,?,?,?,SYSDATE)");
            ps.setLong(1, userId);
            ps.setString(2, type);
            ps.setInt(3, amount);
            ps.setInt(4, balanceAfter);
            ps.setString(5, desc);
            ps.executeUpdate();
            
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private List<JsrPointHistory> getHistory(long userId) {
        List<JsrPointHistory> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "SELECT * FROM JSR_POINT_HISTORY WHERE USER_ID=? ORDER BY HISTORY_ID DESC");
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                JsrPointHistory h = new JsrPointHistory();
                h.setHistoryId(rs.getLong("HISTORY_ID"));
                h.setType(rs.getString("TYPE"));
                h.setAmount(rs.getInt("AMOUNT"));
                h.setBalanceAfter(rs.getInt("BALANCE_AFTER"));
                h.setDescription(rs.getString("DESCRIPTION"));
                h.setCreatedAt(rs.getString("CREATED_AT"));
                list.add(h);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return list;
    }
}
