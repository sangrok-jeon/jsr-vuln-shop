package com.jsr.ctf;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

@WebServlet("/dbtest")
public class DbTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<h3>DB 연결 테스트</h3>");
        try (Connection conn = DBUtil.getConnection()) {
            out.println("<p style='color:green'>✅ DB 연결 성공: jdbc/testCTF123</p>");
            out.println("<p>연결 URL: " + conn.getMetaData().getURL() + "</p>");
        } catch (Exception e) {
            out.println("<p style='color:red'>❌ DB 연결 실패: " + e.getMessage() + "</p>");
            e.printStackTrace(out);
        }
    }
}
