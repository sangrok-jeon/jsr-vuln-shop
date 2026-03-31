package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/board", "/board/write", "/board/detail",
             "/board/edit", "/board/delete",
             "/board/answer", "/board/answer/delete"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize       = 1024 * 1024 * 10,
    maxRequestSize    = 1024 * 1024 * 15
)
public class BoardServlet extends HttpServlet {

    private static final String[] ALLOWED_CONTENT_TYPES = {
        "image/jpeg", "image/png", "image/gif"
    };

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsrUser user = (JsrUser) request.getSession().getAttribute("jsrUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        boolean isAdmin = "ADMIN".equalsIgnoreCase(user.getRole());
        String path = request.getServletPath();

        if (path.equals("/board/write")) {
            String type = request.getParameter("type");
            if ("NOTICE".equals(type) && !isAdmin) {
                response.sendRedirect(request.getContextPath() + "/board?error=noperm");
                return;
            }
            request.setAttribute("writeType", type != null ? type : "INQUIRY");
            request.getRequestDispatcher("/WEB-INF/views/board_write_view.jsp")
                   .forward(request, response);

        } else if (path.equals("/board/detail")) {
            long boardId = Long.parseLong(request.getParameter("boardId"));
            JsrBoard board = getBoardById(boardId);
            if (board == null) {
                response.sendRedirect(request.getContextPath() + "/board?error=notfound");
                return;
            }
            if ("INQUIRY".equals(board.getBoardType())) {
                if (!isAdmin && board.getUserId() != user.getUserId()) {
                    response.sendRedirect(request.getContextPath()
                        + "/board?error=idor&boardId=" + boardId);
                    return;
                }
            }
            board.setAnswer(getAnswer(boardId));
            request.setAttribute("jsrBoard", board);
            request.setAttribute("jsrUser", user);
            request.getRequestDispatcher("/WEB-INF/views/board_detail_view.jsp")
                   .forward(request, response);

        } else if (path.equals("/board/edit")) {
            long boardId = Long.parseLong(request.getParameter("boardId"));
            JsrBoard board = getBoardById(boardId);
            if (board == null) {
                response.sendRedirect(request.getContextPath() + "/board");
                return;
            }
            request.setAttribute("jsrBoard", board);
            request.setAttribute("writeType", board.getBoardType());
            request.getRequestDispatcher("/WEB-INF/views/board_write_view.jsp")
                   .forward(request, response);

        } else if (path.equals("/board/delete")) {
            long boardId = Long.parseLong(request.getParameter("boardId"));
            JsrBoard board = getBoardById(boardId);
            String type = (board != null) ? board.getBoardType() : "INQUIRY";
            deleteBoard(boardId);
            response.sendRedirect(request.getContextPath() + "/board?tab=" + type + "&deleted=1");

        } else if (path.equals("/board/answer/delete")) {
            long answerId = Long.parseLong(request.getParameter("answerId"));
            long boardId  = Long.parseLong(request.getParameter("boardId"));
            deleteAnswer(answerId);
            response.sendRedirect(request.getContextPath() + "/board/detail?boardId=" + boardId);

        } else {
            // 목록
            String tab  = request.getParameter("tab") != null ? request.getParameter("tab") : "NOTICE";
            int    page = 1;
            try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}

            List<JsrBoard> noticeList;
            List<JsrBoard> inquiryList;

            noticeList = getNoticeList();
            if (isAdmin) {
                inquiryList = getInquiryList(page, null);
            } else {
                inquiryList = getInquiryList(page, user.getUserId());
            }

            int totalInquiry = isAdmin ? getInquiryCount(null) : getInquiryCount(user.getUserId());
            int totalPages   = (int) Math.ceil(totalInquiry / 10.0);
            if (totalPages < 1) totalPages = 1;

            request.setAttribute("jsrNotices",    noticeList);
            request.setAttribute("jsrInquiries",  inquiryList);
            request.setAttribute("jsrTab",        tab);
            request.setAttribute("jsrPage",       page);
            request.setAttribute("jsrTotalPages", totalPages);
            request.setAttribute("jsrIsAdmin",    isAdmin);
            request.getRequestDispatcher("/WEB-INF/views/board_list_view.jsp")
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

        boolean isAdmin = "ADMIN".equalsIgnoreCase(user.getRole());
        String path = request.getServletPath();

        if (path.equals("/board/write")) {
            String type    = request.getParameter("boardType");
            String title   = request.getParameter("title");
            String content = request.getParameter("content");
            if ("NOTICE".equals(type) && !isAdmin) {
                response.sendRedirect(request.getContextPath() + "/board?error=noperm");
                return;
            }

            // 파일 업로드 처리
            String savedFileName = null;
            try {
                Part filePart = request.getPart("attachFile");
                if (filePart != null && filePart.getSize() > 0) {
                    savedFileName = handleFileUpload(filePart, request);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            long boardId = insertBoard(user.getUserId(), user.getUsername(),
                                       type != null ? type : "INQUIRY",
                                       title, content, savedFileName);
            response.sendRedirect(request.getContextPath() + "/board/detail?boardId=" + boardId);

        } else if (path.equals("/board/edit")) {
            long   boardId = Long.parseLong(request.getParameter("boardId"));
            String title   = request.getParameter("title");
            String content = request.getParameter("content");

            String savedFileName = null;
            try {
                Part filePart = request.getPart("attachFile");
                if (filePart != null && filePart.getSize() > 0) {
                    savedFileName = handleFileUpload(filePart, request);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            updateBoard(boardId, title, content, savedFileName);
            response.sendRedirect(request.getContextPath() + "/board/detail?boardId=" + boardId);

        } else if (path.equals("/board/answer")) {
            long   boardId = Long.parseLong(request.getParameter("boardId"));
            String content = request.getParameter("content");
            String role    = request.getParameter("role");

            if (!"ADMIN".equals(role)) {
                response.sendRedirect(request.getContextPath()
                    + "/board/detail?boardId=" + boardId + "&error=noperm");
                return;
            }
            JsrAnswer existing = getAnswer(boardId);
            if (existing != null) updateAnswer(existing.getAnswerId(), content);
            else                  insertAnswer(boardId, user.getUsername(), content);
            response.sendRedirect(request.getContextPath()
                + "/board/detail?boardId=" + boardId + "&answered=1");
        }
    }

    private String handleFileUpload(Part filePart, HttpServletRequest request) throws IOException {
        String contentType = filePart.getContentType();

        boolean allowed = false;
        for (String ct : ALLOWED_CONTENT_TYPES) {
            if (ct.equals(contentType)) { allowed = true; break; }
        }
        if (!allowed) return null;

        String originalName = extractFileName(filePart);
        if (originalName == null || originalName.isEmpty()) return null;

        String saveFileName = System.currentTimeMillis() + "_" + originalName;

        String uploadDir = request.getServletContext().getRealPath("/uploads");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        Path savePath = Paths.get(uploadDir, saveFileName);
        try (InputStream is = filePart.getInputStream()) {
            Files.copy(is, savePath, StandardCopyOption.REPLACE_EXISTING);
        }

        return saveFileName;
    }

    private String extractFileName(Part part) {
        String cd = part.getHeader("content-disposition");
        if (cd == null) return null;
        for (String token : cd.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1)
                            .trim().replace("\"", "");
            }
        }
        return null;
    }

    // ── DB 헬퍼 ────────────────────────────────────────────────

    private List<JsrBoard> getNoticeList() {
        List<JsrBoard> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "SELECT b.*, a.ANSWER_ID " +
                "FROM JSR_BOARD b LEFT JOIN JSR_BOARD_ANSWER a ON b.BOARD_ID = a.BOARD_ID " +
                "WHERE b.BOARD_TYPE='NOTICE' ORDER BY b.BOARD_ID DESC");
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapBoardWithAnswerFlag(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return list;
    }

    private List<JsrBoard> getInquiryList(int page, Long userId) {
        List<JsrBoard> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        int offset = (page - 1) * 10;
        try {
            conn = DBUtil.getConnection();
            String innerWhere = userId == null
                ? "b.BOARD_TYPE='INQUIRY'"
                : "b.BOARD_TYPE='INQUIRY' AND b.USER_ID=?";
            String sql =
                "SELECT * FROM (" +
                "  SELECT sub.*, ROWNUM RN FROM (" +
                "    SELECT b.BOARD_ID, b.USER_ID, b.USERNAME, b.BOARD_TYPE," +
                "           b.TITLE, b.CONTENT, b.ATTACH_FILE, b.CREATED_AT, a.ANSWER_ID " +
                "    FROM JSR_BOARD b LEFT JOIN JSR_BOARD_ANSWER a ON b.BOARD_ID = a.BOARD_ID " +
                "    WHERE " + innerWhere + " ORDER BY b.BOARD_ID DESC" +
                "  ) sub WHERE ROWNUM <= ?" +
                ") WHERE RN > ?";
            ps = conn.prepareStatement(sql);
            int idx = 1;
            if (userId != null) ps.setLong(idx++, userId);
            ps.setInt(idx++, offset + 10);
            ps.setInt(idx,   offset);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapBoardWithAnswerFlag(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return list;
    }

    private int getInquiryCount(Long userId) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            String sql = userId == null
                ? "SELECT COUNT(*) FROM JSR_BOARD WHERE BOARD_TYPE='INQUIRY'"
                : "SELECT COUNT(*) FROM JSR_BOARD WHERE BOARD_TYPE='INQUIRY' AND USER_ID=?";
            ps = conn.prepareStatement(sql);
            if (userId != null) ps.setLong(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return 0;
    }

    private JsrBoard getBoardById(long boardId) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("SELECT * FROM JSR_BOARD WHERE BOARD_ID=?");
            ps.setLong(1, boardId);
            rs = ps.executeQuery();
            if (rs.next()) return mapBoard(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return null;
    }

    private long insertBoard(long userId, String username, String type,
                             String title, String content, String attachFile) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        long boardId = 0;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "INSERT INTO JSR_BOARD (BOARD_ID,USER_ID,USERNAME,BOARD_TYPE,TITLE,CONTENT,ATTACH_FILE,CREATED_AT) " +
                "VALUES (JSR_BOARD_SEQ.NEXTVAL,?,?,?,?,?,?,SYSDATE)",
                new String[]{"BOARD_ID"});
            ps.setLong(1, userId);
            ps.setString(2, username);
            ps.setString(3, type);
            ps.setString(4, title);
            ps.setString(5, content);
            ps.setString(6, attachFile);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) boardId = rs.getLong(1);
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return boardId;
    }

    private void updateBoard(long boardId, String title, String content, String attachFile) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            if (attachFile != null) {
                ps = conn.prepareStatement(
                    "UPDATE JSR_BOARD SET TITLE=?,CONTENT=?,ATTACH_FILE=? WHERE BOARD_ID=?");
                ps.setString(1, title); ps.setString(2, content);
                ps.setString(3, attachFile); ps.setLong(4, boardId);
            } else {
                ps = conn.prepareStatement(
                    "UPDATE JSR_BOARD SET TITLE=?,CONTENT=? WHERE BOARD_ID=?");
                ps.setString(1, title); ps.setString(2, content); ps.setLong(3, boardId);
            }
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private void deleteBoard(long boardId) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("DELETE FROM JSR_BOARD_ANSWER WHERE BOARD_ID=?");
            ps.setLong(1, boardId); ps.executeUpdate(); DBUtil.close(ps);
            ps = conn.prepareStatement("DELETE FROM JSR_BOARD WHERE BOARD_ID=?");
            ps.setLong(1, boardId); ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private JsrAnswer getAnswer(long boardId) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("SELECT * FROM JSR_BOARD_ANSWER WHERE BOARD_ID=?");
            ps.setLong(1, boardId); rs = ps.executeQuery();
            if (rs.next()) {
                JsrAnswer a = new JsrAnswer();
                a.setAnswerId(rs.getLong("ANSWER_ID"));
                a.setBoardId(boardId);
                a.setAdminName(rs.getString("ADMIN_NAME"));
                a.setContent(rs.getString("CONTENT"));
                a.setCreatedAt(rs.getString("CREATED_AT"));
                return a;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, ps, conn); }
        return null;
    }

    private void insertAnswer(long boardId, String adminName, String content) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "INSERT INTO JSR_BOARD_ANSWER (ANSWER_ID,BOARD_ID,ADMIN_NAME,CONTENT,CREATED_AT) " +
                "VALUES (JSR_ANSWER_SEQ.NEXTVAL,?,?,?,SYSDATE)");
            ps.setLong(1, boardId); ps.setString(2, adminName); ps.setString(3, content);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private void updateAnswer(long answerId, String content) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "UPDATE JSR_BOARD_ANSWER SET CONTENT=?,CREATED_AT=SYSDATE WHERE ANSWER_ID=?");
            ps.setString(1, content); ps.setLong(2, answerId);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private void deleteAnswer(long answerId) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement("DELETE FROM JSR_BOARD_ANSWER WHERE ANSWER_ID=?");
            ps.setLong(1, answerId); ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(ps, conn); }
    }

    private JsrBoard mapBoard(ResultSet rs) throws SQLException {
        JsrBoard b = new JsrBoard();
        b.setBoardId(rs.getLong("BOARD_ID"));
        b.setUserId(rs.getLong("USER_ID"));
        b.setUsername(rs.getString("USERNAME"));
        b.setBoardType(rs.getString("BOARD_TYPE"));
        b.setTitle(rs.getString("TITLE"));
        b.setContent(rs.getString("CONTENT"));
        b.setCreatedAt(rs.getString("CREATED_AT"));
        try { b.setAttachFile(rs.getString("ATTACH_FILE")); } catch (SQLException ignored) {}
        return b;
    }

    private JsrBoard mapBoardWithAnswerFlag(ResultSet rs) throws SQLException {
        JsrBoard b = mapBoard(rs);
        long answerId = rs.getLong("ANSWER_ID");
        if (!rs.wasNull() && answerId > 0) {
            JsrAnswer dummy = new JsrAnswer();
            dummy.setAnswerId(answerId);
            b.setAnswer(dummy);
        }
        return b;
    }
}
