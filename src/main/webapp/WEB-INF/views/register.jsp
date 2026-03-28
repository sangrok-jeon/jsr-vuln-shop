<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>회원가입 - JSR Shop</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jsr.css">
    <style>
    body {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        background: radial-gradient(ellipse at 40% 20%, rgba(56,189,248,0.06) 0%, transparent 60%), #0f172a;
    }
    .reg-container {
        width: 100%; max-width: 440px;
        padding: 24px;
        animation: fadeUp 0.4s ease both;
    }
    @keyframes fadeUp {
        from { opacity:0; transform:translateY(20px); }
        to   { opacity:1; transform:none; }
    }
    .reg-logo {
        text-align: center; margin-bottom: 28px;
    }
    .reg-logo .logo-icon { font-size: 36px; display:block; margin-bottom:6px; }
    .reg-logo .logo-name { font-size: 20px; font-weight:800; color:#f1f5f9; }
    .reg-logo .logo-sub  { font-size: 12px; color:#475569; margin-top:2px; }

    .reg-card {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 16px;
        padding: 28px;
        margin-bottom: 14px;
    }
    .reg-card h2 { font-size:17px; font-weight:700; color:#f1f5f9; margin-bottom:4px; }
    .reg-card .subtitle { font-size:13px; color:#64748b; margin-bottom:22px; }

    .field-group { display:flex; flex-direction:column; gap:12px; margin-bottom:20px; }
    .field-label {
        font-size: 11px; color:#94a3b8; margin-bottom:5px;
        display:block; text-transform:uppercase; letter-spacing:0.4px;
    }
    .field-wrap { position:relative; }
    .field-icon {
        position:absolute; left:12px; top:50%;
        transform:translateY(-50%); font-size:15px; pointer-events:none;
    }
    .reg-input {
        width: 100%; background:#0f172a; border:1px solid #334155;
        border-radius:10px; color:#f1f5f9; font-size:14px;
        padding:11px 14px 11px 38px; outline:none; font-family:inherit;
        transition:border-color 0.15s, box-shadow 0.15s; box-sizing:border-box;
    }
    .reg-input:focus { border-color:#38bdf8; box-shadow:0 0 0 3px rgba(56,189,248,0.1); }
    .reg-input::placeholder { color:#475569; }

    .reg-btn {
        width: 100%; background:linear-gradient(135deg,#0ea5e9,#38bdf8);
        color:#fff; border:none; border-radius:10px; padding:12px;
        font-size:15px; font-weight:700; cursor:pointer;
        font-family:inherit; transition:opacity 0.15s, transform 0.15s;
    }
    .reg-btn:hover { opacity:.9; transform:translateY(-1px); }
.alert { padding:10px 14px; border-radius:8px; font-size:13px; margin-bottom:16px; }
    .alert-error { background:rgba(239,68,68,0.1); border:1px solid rgba(239,68,68,0.3); color:#fca5a5; }
    .login-link { text-align:center; font-size:13px; color:#64748b; margin-top:14px; }
    .login-link a { color:#38bdf8; text-decoration:none; font-weight:600; }
    </style>
</head>
<body>
<div class="reg-container">
    <div class="reg-logo">
        <span class="logo-icon">JSR</span>
        <div class="logo-name">JSR Shop</div>
        <div class="logo-sub">CTF 보안 취약점 실습 플랫폼</div>
    </div>

    <div class="reg-card">
        <h2>회원가입</h2>
        <p class="subtitle">새 계정을 만드세요</p>

        <% if ("1".equals(request.getParameter("error"))) { %>
        <div class="alert alert-error">이미 사용 중인 아이디입니다.</div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/register">
            <div class="field-group">
                <div>
                    <label class="field-label">아이디</label>
                    <div class="field-wrap">
                        <span class="field-icon"></span>
                        <input type="text" name="userid" class="reg-input"
                               placeholder="아이디 입력" required autocomplete="username">
                    </div>
                </div>
                <div>
                    <label class="field-label">비밀번호 
</label>
                    <div class="field-wrap">
                        <span class="field-icon">SEC</span>
                        <input type="password" name="password" class="reg-input"
                               placeholder="비밀번호 입력" required autocomplete="new-password">
                    </div>
                </div>
                <div>
                    <label class="field-label">이메일</label>
                    <div class="field-wrap">
                        <span class="field-icon"></span>
                        <input type="email" name="email" class="reg-input"
                               placeholder="이메일 입력">
                    </div>
                </div>
                <div>
                    <label class="field-label">주소</label>
                    <div class="field-wrap">
                        <span class="field-icon"></span>
                        <input type="text" name="address" class="reg-input"
                               placeholder="배송 주소 입력">
                    </div>
                </div>
                <div>
                    <label class="field-label">연락처</label>
                    <div class="field-wrap">
                        <span class="field-icon"></span>
                        <input type="text" name="phone" class="reg-input"
                               placeholder="010-0000-0000">
                    </div>
                </div>
            </div>
            <button type="submit" class="reg-btn">가입하기</button>
        </form>
    </div>
<div class="login-link">
        이미 계정이 있으신가요?
        <a href="<%= request.getContextPath() %>/login">로그인</a>
    </div>
</div>
</body>
</html>
