<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>로그인 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    body {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        background: radial-gradient(ellipse at 60% 20%, rgba(56,189,248,0.06) 0%, transparent 60%),
                    #0f172a;
    }
    .login-container {
        width: 100%;
        max-width: 420px;
        padding: 24px;
        animation: fadeUp 0.4s ease both;
    }
    @keyframes fadeUp {
        from { opacity:0; transform:translateY(20px); }
        to   { opacity:1; transform:none; }
    }

    /* 로고 */
    .login-logo {
        text-align: center;
        margin-bottom: 32px;
    }
    .login-logo .logo-icon {
        font-size: 40px;
        display: block;
        margin-bottom: 8px;
    }
    .login-logo .logo-name {
        font-size: 22px;
        font-weight: 800;
        color: #f1f5f9;
        letter-spacing: -0.5px;
    }
    .login-logo .logo-sub {
        font-size: 12px;
        color: #475569;
        margin-top: 2px;
    }

    /* 카드 */
    .login-card {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 16px;
        padding: 32px 28px;
        margin-bottom: 16px;
    }
    .login-card h2 {
        font-size: 18px;
        font-weight: 700;
        color: #f1f5f9;
        margin-bottom: 4px;
    }
    .login-card .subtitle {
        font-size: 13px;
        color: #64748b;
        margin-bottom: 24px;
    }

    /* 필드 */
    .field-group {
        display: flex;
        flex-direction: column;
        gap: 12px;
        margin-bottom: 20px;
    }
    .field-label {
        font-size: 12px;
        color: #94a3b8;
        margin-bottom: 5px;
        display: block;
        text-transform: uppercase;
        letter-spacing: 0.4px;
    }
    .field-wrap { position: relative; }
    .field-icon {
        position: absolute;
        left: 12px; top: 50%;
        transform: translateY(-50%);
        font-size: 15px;
        pointer-events: none;
    }
    .login-input {
        width: 100%;
        background: #0f172a;
        border: 1px solid #334155;
        border-radius: 10px;
        color: #f1f5f9;
        font-size: 14px;
        padding: 11px 14px 11px 38px;
        outline: none;
        font-family: inherit;
        transition: border-color 0.15s, box-shadow 0.15s;
        box-sizing: border-box;
    }
    .login-input:focus {
        border-color: #38bdf8;
        box-shadow: 0 0 0 3px rgba(56,189,248,0.1);
    }
    .login-input::placeholder { color: #475569; }

    .login-btn {
        width: 100%;
        background: linear-gradient(135deg, #0ea5e9, #38bdf8);
        color: #fff;
        border: none;
        border-radius: 10px;
        padding: 12px;
        font-size: 15px;
        font-weight: 700;
        cursor: pointer;
        font-family: inherit;
        transition: opacity 0.15s, transform 0.15s;
        letter-spacing: 0.3px;
    }
    .login-btn:hover { opacity: 0.9; transform: translateY(-1px); }
    .login-btn:active { transform: none; }

    .divider {
        display: flex; align-items: center; gap: 12px;
        color: #334155; font-size: 12px; margin: 18px 0;
    }
    .divider::before, .divider::after {
        content:''; flex:1; height:1px; background:#334155;
    }
.account-row .role-badge {
        font-size: 10px; font-weight: 700;
        padding: 1px 6px; border-radius: 3px;
        font-family: inherit;
    }
    .rb-admin { background:#ef4444; color:#fff; }
    .rb-user  { background:#334155; color:#94a3b8; }

    /* 알림 */
    .alert { padding:10px 14px; border-radius:8px; font-size:13px; margin-bottom:16px; }
    .alert-error   { background:rgba(239,68,68,0.1); border:1px solid rgba(239,68,68,0.3); color:#fca5a5; }
    .alert-success { background:rgba(34,197,94,0.1); border:1px solid rgba(34,197,94,0.3); color:#86efac; }

    .register-link {
        text-align: center;
        font-size: 13px;
        color: #64748b;
    }
    .register-link a { color: #38bdf8; text-decoration: none; font-weight: 600; }
    .register-link a:hover { text-decoration: underline; }
    </style>
</head>
<body>
<div class="login-container">
    <div class="login-logo">
        <span class="logo-icon">JSR</span>
        <div class="logo-name">JSR Shop</div>
        <div class="logo-sub">보안 취약점 실습 플랫폼</div>
    </div>

    <div class="login-card">
        <h2>로그인</h2>
        <p class="subtitle">계정에 로그인하세요</p>

        <% if ("1".equals(request.getParameter("error"))) { %>
        <div class="alert alert-error">아이디 또는 비밀번호가 틀렸습니다.</div>
        <% } %>
        <% if ("1".equals(request.getParameter("registered"))) { %>
        <div class="alert alert-success">회원가입 완료! 로그인하세요.</div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/login">
            <div class="field-group">
                <div>
                    <label class="field-label">아이디</label>
                    <div class="field-wrap">
                        <span class="field-icon"></span>
                        <input type="text" name="userid" class="login-input"
                               placeholder="아이디를 입력하세요" autocomplete="username">
                    </div>
                </div>
                <div>
                    <label class="field-label">비밀번호</label>
                    <div class="field-wrap">
                        <span class="field-icon">SEC</span>
                        <input type="password" name="password" class="login-input"
                               placeholder="비밀번호를 입력하세요" autocomplete="current-password">
                    </div>
                </div>
            </div>
            <button type="submit" class="login-btn">로그인</button>
        </form>

        <div class="divider">또는</div>

        <div class="register-link">
            계정이 없으신가요?
            <a href="<%= request.getContextPath() %>/register">회원가입</a>
        </div>
    </div>

</div>
</body>
</html>
