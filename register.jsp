<%-- register.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="includes/db.jsp" %>
<%
    if (session.getAttribute("user_id") != null) {
        response.sendRedirect("dashboard.jsp"); return;
    }
    String msg = "";
    String msgType = "";

    if ("POST".equals(request.getMethod())) {
        String fullName = request.getParameter("full_name").trim();
        String email    = request.getParameter("email").trim();
        String phone    = request.getParameter("phone").trim();
        String password = request.getParameter("password");
        String level    = request.getParameter("academic_level");
        String inst     = request.getParameter("institution").trim();

        // Basic validation
        if (fullName.isEmpty() || email.isEmpty() || password.isEmpty()) {
            msg = "Please fill in all required fields.";
            msgType = "danger";
        } else if (password.length() < 4) {
            msg = "Password must be at least 4 characters.";
            msgType = "danger";
        } else {
            Connection con = null;
            try {
                con = getConnection();
                // Check duplicate email
                PreparedStatement chk = con.prepareStatement(
                    "SELECT COUNT(*) FROM Users4 WHERE email=?");
                chk.setString(1, email);
                ResultSet rs = chk.executeQuery();
                rs.next();
                if (rs.getInt(1) > 0) {
                    msg = "Email already registered. Please login.";
                    msgType = "danger";
                } else {
                    PreparedStatement ins = con.prepareStatement(
                        "INSERT INTO Users4 (full_name,email,phone,password,academic_level,institution) VALUES(?,?,?,?,?,?)");
                    ins.setString(1, fullName);
                    ins.setString(2, email);
                    ins.setString(3, phone);
                    ins.setString(4, password); // In production: hash the password
                    ins.setString(5, level);
                    ins.setString(6, inst);
                    ins.executeUpdate();
                    msg = "Registration successful! Please login.";
                    msgType = "success";
                }
            } catch (Exception e) {
                msg = "Database error: " + e.getMessage();
                msgType = "danger";
            } finally {
                if (con != null) try { con.close(); } catch(Exception ignored){}
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Register - Study Planner</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="auth-page">
<div class="auth-box">
    <div class="auth-logo">
        <h2>📚 StudyPlanner BD</h2>
        <p>Create your free account</p>
    </div>
    <% if (!msg.isEmpty()) { %>
        <div class="alert alert-<%= msgType %>"><%= msg %></div>
        <% if ("success".equals(msgType)) { %>
            <div style="text-align:center;margin-bottom:12px;">
                <a href="login.jsp" class="btn btn-primary">Go to Login &rarr;</a>
            </div>
        <% } %>
    <% } %>
    <form method="post" action="register.jsp">
        <div class="form-group">
            <label>Full Name *</label>
            <input type="text" name="full_name" class="form-control" placeholder="Your full name" required>
        </div>
        <div class="form-group">
            <label>Email Address *</label>
            <input type="email" name="email" class="form-control" placeholder="you@example.com" required>
        </div>
        <div class="form-group">
            <label>Phone Number</label>
            <input type="text" name="phone" class="form-control" placeholder="01XXXXXXXXX">
        </div>
        <div class="form-group">
            <label>Academic Level *</label>
            <select name="academic_level" class="form-control">
                <option value="SSC">SSC (Class 9-10)</option>
                <option value="HSC">HSC (Class 11-12)</option>
                <option value="University">University</option>
            </select>
        </div>
        <div class="form-group">
            <label>School / College / University</label>
            <input type="text" name="institution" class="form-control" placeholder="Institution name">
        </div>
        <div class="form-group">
            <label>Password *</label>
            <input type="password" name="password" class="form-control" placeholder="Min. 4 characters" required>
        </div>
        <button type="submit" class="btn btn-primary btn-block">Create Account</button>
    </form>
    <p style="text-align:center;margin-top:16px;font-size:0.9rem;color:#718096;">
        Already have an account? <a href="login.jsp" style="color:#1a56a0;font-weight:600;">Login</a>
    </p>
</div>
</div>
</body>
</html>
