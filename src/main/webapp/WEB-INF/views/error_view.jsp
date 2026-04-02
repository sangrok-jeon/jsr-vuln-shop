<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%
    Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
    Throwable error = (Throwable) request.getAttribute("javax.servlet.error.exception");
    String uri = (String) request.getAttribute("javax.servlet.error.request_uri");

    boolean invalidInput = false;
    if (statusCode != null && statusCode == 404) {
        invalidInput = true;
    }
    if (error instanceof NumberFormatException) {
        invalidInput = true;
    }

    String title = invalidInput ? "유효하지 않은 요청입니다." : "요청을 처리할 수 없습니다.";
    String description = invalidInput
            ? "요청 파라미터 형식이 올바르지 않거나 존재하지 않는 경로입니다."
            : "잠시 후 다시 시도해주세요. 문제가 계속되면 관리자에게 문의해주세요.";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= title %></title>
    <style>
        body {
            margin: 0;
            font-family: "Malgun Gothic", sans-serif;
            background: #111827;
            color: #e5e7eb;
        }
        .wrap {
            max-width: 760px;
            margin: 80px auto;
            padding: 0 24px;
        }
        .card {
            background: #1f2937;
            border: 1px solid #374151;
            border-radius: 18px;
            padding: 32px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.25);
        }
        h1 {
            margin: 0 0 12px;
            font-size: 34px;
            line-height: 1.2;
        }
        p {
            margin: 0 0 12px;
            color: #cbd5e1;
            line-height: 1.7;
        }
        .meta {
            margin-top: 18px;
            padding: 14px 16px;
            border-radius: 12px;
            background: #111827;
            color: #93c5fd;
            font-size: 14px;
            word-break: break-all;
        }
        .actions {
            margin-top: 24px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }
        .btn {
            display: inline-block;
            padding: 12px 18px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 700;
        }
        .btn-primary {
            background: #38bdf8;
            color: #0f172a;
        }
        .btn-secondary {
            background: #374151;
            color: #e5e7eb;
        }
    </style>
</head>
<body>
<div class="wrap">
    <div class="card">
        <h1><%= title %></h1>
        <p><%= description %></p>
        <p>입력값을 다시 확인한 뒤, 정상 경로로 재접속해주세요.</p>
        <% if (uri != null) { %>
        <div class="meta">요청 경로: <%= uri %></div>
        <% } %>
        <div class="actions">
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/products">상품 목록으로</a>
            <a class="btn btn-secondary" href="javascript:history.back()">이전 페이지</a>
        </div>
    </div>
</div>
</body>
</html>
