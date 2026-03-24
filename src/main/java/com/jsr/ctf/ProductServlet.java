package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword  = request.getParameter("keyword");
        String category = request.getParameter("category");
        if (keyword  == null) keyword  = "";
        if (category == null) category = "";

        List<JsrProduct> products = new ArrayList<>();
        Connection conn = null;
        Statement  stmt = null;
        PreparedStatement ps = null;
        ResultSet  rs   = null;

        try {
            conn = DBUtil.getConnection();

            if (!keyword.isEmpty()) {
                /*
                 * ⚠️ SQL Injection 취약 검색
                 * 공격 예시:
                 *   ' UNION SELECT USER_ID,USERNAME,PASSWORD,EMAIL,ROLE,POINT,NULL,NULL FROM JSR_USERS--
                 */
                String sql = "SELECT * FROM JSR_PRODUCTS "
                           + "WHERE NAME LIKE '%" + keyword + "%' "
                           + "OR DESCRIPTION LIKE '%" + keyword + "%' "
                           + "ORDER BY PRODUCT_ID DESC";
                stmt = conn.createStatement();
                rs   = stmt.executeQuery(sql);
            } else if (!category.isEmpty()) {
                ps = conn.prepareStatement(
                    "SELECT * FROM JSR_PRODUCTS WHERE CATEGORY=? ORDER BY PRODUCT_ID DESC");
                ps.setString(1, category);
                rs = ps.executeQuery();
            } else {
                ps = conn.prepareStatement(
                    "SELECT * FROM JSR_PRODUCTS ORDER BY PRODUCT_ID DESC");
                rs = ps.executeQuery();
            }

            while (rs.next()) {
                JsrProduct p = new JsrProduct();
                p.setProductId(rs.getLong("PRODUCT_ID"));
                p.setName(rs.getString("NAME"));
                p.setDescription(rs.getString("DESCRIPTION"));
                p.setPrice(rs.getInt("PRICE"));
                p.setStock(rs.getInt("STOCK"));
                p.setCategory(rs.getString("CATEGORY"));
                p.setImageUrl(rs.getString("IMAGE_URL"));
                products.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, stmt != null ? stmt : ps, conn);
        }

        request.setAttribute("jsrProducts", products);
        request.setAttribute("keyword",  keyword);
        request.setAttribute("category", category);
        request.getRequestDispatcher("/WEB-INF/views/product_view.jsp")
               .forward(request, response);
    }
}
