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
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            String sql = "SELECT USER_ID, USERNAME, PASSWORD, EMAIL, ROLE, POINT, ADDRESS, PHONE "
                    + "FROM JSR_USERS WHERE USERNAME = ?";

            ps = conn.prepareStatement(sql);
            ps.setString(1, userid);
            rs = ps.executeQuery();

            if (rs.next() && PasswordUtil.matches(password, rs.getString("PASSWORD"))) {
                loginUser = new JsrUser();
                loginUser.setUserId(rs.getLong("USER_ID"));
                loginUser.setUsername(rs.getString("USERNAME"));
                loginUser.setEmail(rs.getString("EMAIL"));
                loginUser.setRole(rs.getString("ROLE"));
                loginUser.setPoint(rs.getInt("POINT"));
                loginUser.setAddress(rs.getString("ADDRESS"));
                loginUser.setPhone(rs.getString("PHONE"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, ps, conn);
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
}
