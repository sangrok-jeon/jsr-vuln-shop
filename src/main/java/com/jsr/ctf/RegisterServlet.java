package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userid   = request.getParameter("userid");
        String password = request.getParameter("password");
        String email    = request.getParameter("email");
        String address  = request.getParameter("address");
        String phone    = request.getParameter("phone");
        String passwordHash = PasswordUtil.hash(password);

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "INSERT INTO JSR_USERS (USER_ID, USERNAME, PASSWORD, EMAIL, ROLE, POINT, ADDRESS, PHONE, CREATED_AT) " +
                "VALUES (JSR_USER_SEQ.NEXTVAL, ?, ?, ?, 'USER', 0, ?, ?, SYSDATE)");
            ps.setString(1, userid);
            ps.setString(2, passwordHash);
            ps.setString(3, email);
            ps.setString(4, address);
            ps.setString(5, phone);
            ps.executeUpdate();
            response.sendRedirect(request.getContextPath() + "/login?registered=1");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/register?error=1");
        } finally {
            DBUtil.close(ps, conn);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/register.jsp")
               .forward(request, response);
    }
}