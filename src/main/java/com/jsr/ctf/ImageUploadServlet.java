package com.jsr.ctf;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.sql.*;

@WebServlet("/admin/product_image_upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1MB
    maxFileSize       = 1024 * 1024 * 10,  // 10MB
    maxRequestSize    = 1024 * 1024 * 15   // 15MB
)
public class ImageUploadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 로그인 체크
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("jsrUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pidStr = request.getParameter("productId");
        if (pidStr == null || pidStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=noid");
            return;
        }
        long productId = Long.parseLong(pidStr);

        Part filePart = request.getPart("imageFile");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=nofile");
            return;
        }

        // 확장자 추출 및 검증
        String originalName = getSubmittedFileName(filePart);
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf(".")).toLowerCase();
        }
        if (!ext.matches("\\.(jpg|jpeg|png|gif|webp)")) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalidtype");
            return;
        }

        // 저장 파일명: {productId}{ext}  예) 3.png
        String saveFileName = productId + ext;
        String relPath      = "products/" + saveFileName;  // DB 저장 경로

        // 실제 저장 폴더: webapp/static/images/products/
        String uploadDir = getServletContext().getRealPath("/static/images/products");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        // 기존 파일 삭제 (확장자 변경 대응)
        for (String oldExt : new String[]{".jpg", ".jpeg", ".png", ".gif", ".webp"}) {
            File old = new File(uploadDir, productId + oldExt);
            if (old.exists()) old.delete();
        }

        // 파일 저장
        Path savePath = Paths.get(uploadDir, saveFileName);
        try (InputStream is = filePart.getInputStream()) {
            Files.copy(is, savePath, StandardCopyOption.REPLACE_EXISTING);
        }

        // DB 업데이트
        updateImageUrl(productId, relPath);

        response.sendRedirect(request.getContextPath() + "/admin/products?uploaded=1");
    }

    private String getSubmittedFileName(Part part) {
        String cd = part.getHeader("content-disposition");
        if (cd == null) return null;
        for (String token : cd.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                String name = token.substring(token.indexOf('=') + 1)
                                   .trim().replace("\"", "");
                return Paths.get(name).getFileName().toString();
            }
        }
        return null;
    }

    private void updateImageUrl(long productId, String imageUrl) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "UPDATE JSR_PRODUCTS SET IMAGE_URL = ? WHERE PRODUCT_ID = ?");
            ps.setString(1, imageUrl);
            ps.setLong(2, productId);
            ps.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(ps, conn);
        }
    }
}
