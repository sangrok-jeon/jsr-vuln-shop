package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userid   = request.getParameter("userid");
        String password = request.getParameter("password");

        JsrUser loginUser = null;
        Connection conn = null;
        Statement  stmt = null;
        ResultSet  rs   = null;

        try {
            System.out.println("==== [DEBUG] LoginServlet doPost called ====");
            System.out.println("[DEBUG] userid   = [" + userid + "]");
            System.out.println("[DEBUG] password = [" + password + "]");

            conn = DBUtil.getConnection();
            System.out.println("[DEBUG] conn = " + conn);

            Statement checkStmt = conn.createStatement();

            ResultSet checkRs1 = checkStmt.executeQuery(
                    "SELECT SYS_CONTEXT('USERENV','SESSION_USER') FROM DUAL");
            if (checkRs1.next()) {
                System.out.println("[DEBUG] DB USER = " + checkRs1.getString(1));
            }
            checkRs1.close();

            ResultSet checkRs2 = checkStmt.executeQuery("SELECT COUNT(*) FROM JSR_USERS");
            if (checkRs2.next()) {
                System.out.println("[DEBUG] JSR_USERS COUNT = " + checkRs2.getInt(1));
            }
            checkRs2.close();
            checkStmt.close();

           
            userid   = filterSqli(userid);
            password = filterSqli(password);

            String sql = "SELECT * FROM JSR_USERS "
                    + "WHERE USERNAME = '" + userid + "' "
                    + "AND PASSWORD = '" + password + "'";

            System.out.println("[DEBUG] sql = " + sql);

            stmt = conn.createStatement();
            rs   = stmt.executeQuery(sql);

            if (rs.next()) {
                System.out.println("[DEBUG] LOGIN SUCCESS");
                loginUser = new JsrUser();
                loginUser.setUserId(rs.getLong("USER_ID"));
                loginUser.setUsername(rs.getString("USERNAME"));
                loginUser.setPassword(rs.getString("PASSWORD"));
                loginUser.setEmail(rs.getString("EMAIL"));
                loginUser.setRole(rs.getString("ROLE"));
                loginUser.setPoint(rs.getInt("POINT"));
                loginUser.setAddress(rs.getString("ADDRESS"));
                loginUser.setPhone(rs.getString("PHONE"));
            } else {
                System.out.println("[DEBUG] LOGIN FAIL - no row");
            }
        } catch (SQLException e) {
                System.out.println("[DEBUG] sqlState = " + e.getSQLState());
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, stmt, conn);
        }

        if (loginUser != null) {
            HttpSession session = request.getSession();
            session.setAttribute("jsrUser", loginUser);

            if ("ADMIN".equals(loginUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/products");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/login?error=1");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/login.jsp")
               .forward(request, response);
    }

    /**
     * ⚠️ 불완전한 SQLi 필터링
     *
     * 차단: --, #, 인라인주석
     * 통과: ' OR '1'='1 (주석 없이 따옴표로 닫기)
     *
     * 공격 시나리오:
     *   admin'--   → -- 제거 후 문법 오류 (차단)
     *   ' OR '1'='1 → 주석 없이 통과 → 전체 유저 반환 → 로그인 성공
     */
    private String filterSqli(String input) {
        if (input == null) return input;
        // -- 주석 차단
        input = input.replaceAll("--", "");
        // # 주석 차단
        input = input.replaceAll("#", "");
        // /**/ 주석 차단
        input = input.replaceAll("/\\*.*?\\*/", "");
        return input;
    }
}
