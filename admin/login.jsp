<%-- admin/login.jsp - Admin Login Page --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<meta charset="UTF-8">
<%@ page import="java.sql.*" %>
<%@ include file="../includes/db.jsp" %>
<%
    if (session.getAttribute("admin_id") != null) {
        response.sendRedirect("dashboard.jsp"); return;
    }
    String msg = "";
    if ("POST".equals(request.getMethod())) {
        String uname = request.getParameter("username").trim();
        String pass  = request.getParameter("password");
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT admin_id, username FROM Admin1 WHERE username=? AND password=?");
            ps.setString(1, uname); ps.setString(2, pass);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                session.setAttribute("admin_id",   rs.getInt("admin_id"));
                session.setAttribute("admin_name", rs.getString("username"));
                response.sendRedirect("dashboard.jsp");
                return;
            } else {
                msg = "Invalid username or password.";
            }
        } catch(Exception e) {
            msg = "DB Error: " + e.getMessage();
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Admin Login - Study Planner</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>.auth-page{background:linear-gradient(135deg,#2c3e50,#34495e,#2c3e50);}</style>
</head>
<body>
<div class="auth-page">
<div class="auth-box">
    <div class="auth-logo">
        <h2 style="color:#2c3e50;">⚙️ Admin Panel</h2>
        <p>Authorized personnel only</p>
    </div>
    <% if (!msg.isEmpty()) { %>
        <div class="alert alert-danger"><%= msg %></div>
    <% } %>
    <form method="post" action="login.jsp">
        <div class="form-group">
            <label>Username</label>
            <input type="text" name="username" class="form-control" placeholder="admin" required>
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" class="form-control" placeholder="Password" required>
        </div>
        <button type="submit" class="btn btn-block"
                style="background:#2c3e50;color:white;padding:10px;border-radius:8px;font-size:0.95rem;font-weight:700;border:none;cursor:pointer;">
            Admin Login
        </button>
    </form>
    <p style="text-align:center;margin-top:16px;font-size:0.88rem;">
        <a href="<%= request.getContextPath() %>/login.jsp" style="color:#718096;">← Student Login</a>
    </p>
</div>
</div>
</body>
</html>
