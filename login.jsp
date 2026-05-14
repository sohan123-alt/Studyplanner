<%-- login.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="includes/db.jsp" %>
<%
    if (session.getAttribute("user_id") != null) {
        response.sendRedirect("dashboard.jsp"); return;
    }
    String msg = "";

    if ("POST".equals(request.getMethod())) {
        String email    = request.getParameter("email").trim();
        String password = request.getParameter("password");
        Connection con  = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT user_id, full_name, academic_level FROM Users4 WHERE email=? AND password=?");
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                session.setAttribute("user_id",    rs.getInt("user_id"));
                session.setAttribute("user_name",  rs.getString("full_name"));
                session.setAttribute("user_level", rs.getString("academic_level"));
                response.sendRedirect("dashboard.jsp");
                return;
            } else {
                msg = "Invalid email or password.";
            }
        } catch (Exception e) {
            msg = "Database error: " + e.getMessage();
        } finally {
            if (con != null) try { con.close(); } catch(Exception ignored){}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Login - Study Planner</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="auth-page">
<div class="auth-box">
    <div class="auth-logo">
        <h2>📚 StudyPlanner BD</h2>
        <p>Login to your account</p>
    </div>
    <% if (!msg.isEmpty()) { %>
        <div class="alert alert-danger"><%= msg %></div>
    <% } %>
    <form method="post" action="login.jsp">
        <div class="form-group">
            <label>Email Address</label>
            <input type="email" name="email" class="form-control" placeholder="you@example.com" required>
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" class="form-control" placeholder="Your password" required>
        </div>
        <button type="submit" class="btn btn-primary btn-block">Login</button>
    </form>
    <p style="text-align:center;margin-top:16px;font-size:0.9rem;color:#718096;">
        No account? <a href="register.jsp" style="color:#1a56a0;font-weight:600;">Register free</a>
        &nbsp;&nbsp;|&nbsp;&nbsp;
        <a href="admin/login.jsp" style="color:#718096;">Admin Login</a>
    </p>
</div>
</div>
</body>
</html>
