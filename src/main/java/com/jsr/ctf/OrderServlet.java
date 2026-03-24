package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/order", "/order/proc", "/order/complete", "/order/list", "/order/detail"})
public class OrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        if (path.equals("/order/complete")) {
            long orderId = Long.parseLong(request.getParameter("orderId"));
            request.setAttribute("jsrOrder", getOrderById(orderId));
            request.getRequestDispatcher("/WEB-INF/views/order_complete_view.jsp")
                   .forward(request, response);

        } else if (path.equals("/order/list")) {
            request.setAttribute("jsrOrders", getOrdersByUser(user.getUserId()));
            request.getRequestDispatcher("/WEB-INF/views/order_list_view.jsp")
                   .forward(request, response);

        } else if (path.equals("/order/detail")) {
            // ⚠️ IDOR: 소유자 검증 없음 → orderId 변조로 타인 주문 조회 가능
            long orderId = Long.parseLong(request.getParameter("orderId"));
            request.setAttribute("jsrOrder", getOrderById(orderId));
            request.getRequestDispatcher("/WEB-INF/views/order_detail_view.jsp")
                   .forward(request, response);

        } else {
            // /order - 주문 폼
            String productIdStr = request.getParameter("productId");
            String qtyStr       = request.getParameter("quantity");
            if (productIdStr != null) {
                long productId = Long.parseLong(productIdStr);
                int  quantity  = qtyStr != null ? Integer.parseInt(qtyStr) : 1;
                JsrProduct product = getProductById(productId);
                request.setAttribute("jsrProduct", product);
                request.setAttribute("jsrQty", quantity);
                if (product != null) {
                    request.setAttribute("jsrOrderTotal", product.getPrice() * quantity);
                }
            } else {
                List<JsrCartItem> cart = getCart(user.getUserId());
                int total = cart.stream().mapToInt(JsrCartItem::getSubTotal).sum();
                request.setAttribute("jsrCartItems", cart);
                request.setAttribute("jsrCartTotal", total);
                request.setAttribute("jsrOrderTotal", total);
            }
            request.setAttribute("jsrUser", user);
            request.setAttribute("jsrCurrentPoint", getUserPoint(user.getUserId()));
            request.getRequestDispatcher("/WEB-INF/views/order_view.jsp")
                   .forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long   productId  = Long.parseLong(request.getParameter("productId"));
        int    quantity   = Integer.parseInt(request.getParameter("quantity"));
        int    price      = Integer.parseInt(request.getParameter("price"));       // ⚠️ 가격 변조 취약점
        int    totalPrice = Integer.parseInt(request.getParameter("totalPrice"));  // ⚠️ 검증 없음
        String address    = request.getParameter("address");
        if (address == null || address.isEmpty()) address = user.getAddress();

        JsrProduct product = getProductById(productId);

        // ── 포인트 잔액 체크 ──────────────────────────
        // DB에서 현재 포인트 재조회 (세션값 신뢰 X)
        int currentPoint = getUserPoint(user.getUserId());

        if (currentPoint < totalPrice) {
            // ⚠️ 포인트 부족 → 결제 불가
            // totalPrice는 클라이언트 전송값(변조 가능) 그대로 비교 → 가격 변조 시 통과 가능
            if (productId > 0) {
                request.setAttribute("jsrProduct", product);
                request.setAttribute("jsrQty", quantity);
                request.setAttribute("jsrOrderTotal", totalPrice);
            } else {
                List<JsrCartItem> cart = getCart(user.getUserId());
                request.setAttribute("jsrCartItems", cart);
                request.setAttribute("jsrCartTotal", totalPrice);
                request.setAttribute("jsrOrderTotal", totalPrice);
            }
            request.setAttribute("jsrCurrentPoint", currentPoint);
            request.setAttribute("jsrShortfall", totalPrice - currentPoint);
            request.setAttribute("jsrUser", user);
            request.setAttribute("errorMsg", "포인트가 부족합니다.");
            request.getRequestDispatcher("/WEB-INF/views/order_view.jsp")
                   .forward(request, response);
            return;
        }

        // ── 결제 처리 ──────────────────────────────────
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        long orderId = 0;
        try {
            conn = DBUtil.getConnection();

            // 1. 주문 INSERT (⚠️ price/totalPrice = 클라이언트 값 그대로)
            ps = conn.prepareStatement(
                "INSERT INTO JSR_ORDERS " +
                "(ORDER_ID,USER_ID,USERNAME,PRODUCT_ID,PRODUCT_NAME,QUANTITY,PRICE,TOTAL_PRICE,STATUS,ADDRESS,CREATED_AT) " +
                "VALUES (JSR_ORDER_SEQ.NEXTVAL,?,?,?,?,?,?,?,'PAID',?,SYSDATE)",
                new String[]{"ORDER_ID"});
            ps.setLong(1, user.getUserId());
            ps.setString(2, user.getUsername());
            ps.setLong(3, productId);
            ps.setString(4, product != null ? product.getName() : "");
            ps.setInt(5, quantity);
            ps.setInt(6, price);
            ps.setInt(7, totalPrice);
            ps.setString(8, address);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) orderId = rs.getLong(1);

            // 2. 포인트 차감 (⚠️ 변조된 totalPrice만큼만 차감 → 가격 변조 시 이득)
            DBUtil.close(rs, ps);
            ps = conn.prepareStatement(
                "UPDATE JSR_USERS SET POINT = POINT - ? WHERE USER_ID = ?");
            ps.setInt(1, totalPrice);
            ps.setLong(2, user.getUserId());
            ps.executeUpdate();

            // 3. 포인트 이력
            DBUtil.close(ps);
            ps = conn.prepareStatement(
                "INSERT INTO JSR_POINT_HISTORY(HISTORY_ID,USER_ID,AMOUNT,DESCRIPTION,CREATED_AT) " +
                "VALUES(JSR_POINT_SEQ.NEXTVAL,?,?,'주문결제(ORDER_ID:'||?||')',SYSDATE)");
            ps.setLong(1, user.getUserId());
            ps.setInt(2, -totalPrice);
            ps.setLong(3, orderId);
            ps.executeUpdate();

            // 4. 장바구니 비우기
            DBUtil.close(ps);
            ps = conn.prepareStatement("DELETE FROM JSR_CART WHERE USER_ID=?");
            ps.setLong(1, user.getUserId());
            ps.executeUpdate();



            // 세션 포인트 업데이트
            user.setPoint(currentPoint - totalPrice);
            request.getSession().setAttribute("jsrUser", user);

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, ps, conn);
        }

        response.sendRedirect(request.getContextPath() + "/order/complete?orderId=" + orderId);
    }

    // ── DB 헬퍼 ────────────────────────────────────────────────

    private int getUserPoint(long userId) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("SELECT POINT FROM JSR_USERS WHERE USER_ID=?");
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("POINT");
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return 0;
    }

    private JsrOrder getOrderById(long orderId) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            // ⚠️ IDOR: WHERE USER_ID 조건 없음
            ps = conn.prepareStatement(
                "SELECT o.*, p.IMAGE_URL FROM JSR_ORDERS o " +
                "LEFT JOIN JSR_PRODUCTS p ON o.PRODUCT_ID = p.PRODUCT_ID " +
                "WHERE o.ORDER_ID=?");
            ps.setLong(1, orderId);
            rs = ps.executeQuery();
            if (rs.next()) return mapOrder(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return null;
    }

    private List<JsrOrder> getOrdersByUser(long userId) {
        List<JsrOrder> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "SELECT o.*, p.IMAGE_URL FROM JSR_ORDERS o " +
                "LEFT JOIN JSR_PRODUCTS p ON o.PRODUCT_ID = p.PRODUCT_ID " +
                "WHERE o.USER_ID=? ORDER BY o.ORDER_ID DESC");
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapOrder(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return list;
    }

    private JsrProduct getProductById(long productId) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("SELECT * FROM JSR_PRODUCTS WHERE PRODUCT_ID=?");
            ps.setLong(1, productId);
            rs = ps.executeQuery();
            if (rs.next()) {
                JsrProduct p = new JsrProduct();
                p.setProductId(rs.getLong("PRODUCT_ID"));
                p.setName(rs.getString("NAME"));
                p.setDescription(rs.getString("DESCRIPTION"));
                p.setPrice(rs.getInt("PRICE"));
                p.setStock(rs.getInt("STOCK"));
                p.setCategory(rs.getString("CATEGORY"));
                p.setImageUrl(rs.getString("IMAGE_URL"));
                return p;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return null;
    }

    private List<JsrCartItem> getCart(long userId) {
        List<JsrCartItem> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "SELECT c.CART_ID,c.PRODUCT_ID,c.QUANTITY,p.NAME,p.PRICE,p.IMAGE_URL " +
                "FROM JSR_CART c JOIN JSR_PRODUCTS p ON c.PRODUCT_ID=p.PRODUCT_ID " +
                "WHERE c.USER_ID=?");
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                JsrCartItem item = new JsrCartItem();
                item.setCartId(rs.getLong("CART_ID"));
                item.setProductId(rs.getLong("PRODUCT_ID"));
                item.setProductName(rs.getString("NAME"));
                item.setPrice(rs.getInt("PRICE"));
                item.setQuantity(rs.getInt("QUANTITY"));
                item.setImageUrl(rs.getString("IMAGE_URL"));
                list.add(item);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return list;
    }

    private JsrOrder mapOrder(ResultSet rs) throws SQLException {
        JsrOrder o = new JsrOrder();
        o.setOrderId(rs.getLong("ORDER_ID"));
        o.setUserId(rs.getLong("USER_ID"));
        o.setUsername(rs.getString("USERNAME"));
        o.setProductId(rs.getLong("PRODUCT_ID"));
        o.setProductName(rs.getString("PRODUCT_NAME"));
        o.setQuantity(rs.getInt("QUANTITY"));
        o.setPrice(rs.getInt("PRICE"));
        o.setTotalPrice(rs.getInt("TOTAL_PRICE"));
        o.setStatus(rs.getString("STATUS"));
        o.setAddress(rs.getString("ADDRESS"));
        o.setCreatedAt(rs.getString("CREATED_AT"));
        try { o.setImageUrl(rs.getString("IMAGE_URL")); } catch (SQLException ignored) {}
        return o;
    }
}
