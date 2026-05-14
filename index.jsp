<%-- index.jsp - Landing Page --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("user_id") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Study Planner - Bangladesh</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .hero {
            min-height: 100vh;
            background: linear-gradient(135deg, #1a56a0 0%, #2e86c1 60%, #1a3a6b 100%);
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            text-align: center; padding: 40px 20px; color: white;
        }
        .hero h1 { font-size: clamp(1.8rem, 5vw, 3rem); font-weight: 800; margin-bottom: 12px; }
        .hero p  { font-size: 1.1rem; opacity: 0.9; max-width: 560px; margin: 0 auto 32px; }
        .hero-btns { display: flex; gap: 16px; flex-wrap: wrap; justify-content: center; }
        .btn-hero {
            padding: 14px 32px; border-radius: 50px; font-size: 1rem;
            font-weight: 700; text-decoration: none; transition: all 0.2s;
        }
        .btn-white { background: white; color: #1a56a0; }
        .btn-white:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.2); }
        .btn-outline { border: 2px solid white; color: white; background: transparent; }
        .btn-outline:hover { background: white; color: #1a56a0; }
        .features {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px; max-width: 900px; margin: 40px auto 0; width: 100%;
        }
        .feat { background: rgba(255,255,255,0.12); border-radius: 12px; padding: 20px; }
        .feat .icon { font-size: 2rem; margin-bottom: 8px; }
        .feat h3 { font-size: 1rem; margin-bottom: 6px; }
        .feat p { font-size: 0.83rem; opacity: 0.85; }
    </style>
</head>
<body>
<div class="hero">
    <div>📚</div>
    <h1>AI Study Planner &amp;<br>Exam Predictor</h1>
    <p>Bangladesh-focused personalized study planning for SSC, HSC &amp; University students. Study smarter, score higher.</p>
    <div class="hero-btns">
        <a href="register.jsp" class="btn-hero btn-white">Get Started Free</a>
        <a href="login.jsp" class="btn-hero btn-outline">Login</a>
        <a href="admin/login.jsp" class="btn-hero btn-outline">Admin Panel</a>
    </div>
    <div class="features">
        <div class="feat"><div class="icon">🗓️</div><h3>Smart Study Plan</h3><p>Auto-generated daily routine based on your subjects</p></div>
        <div class="feat"><div class="icon">🔍</div><h3>Weak Subject Detection</h3><p>AI finds your weak areas and focuses your study</p></div>
        <div class="feat"><div class="icon">❓</div><h3>Exam Predictions</h3><p>Probable questions from past board exam patterns</p></div>
        <div class="feat"><div class="icon">📊</div><h3>Progress Tracking</h3><p>Monitor your improvement with visual charts</p></div>
    </div>
</div>
</body>
</html>
