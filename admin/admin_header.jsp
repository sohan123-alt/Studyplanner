<%-- admin/includes/admin_header.jsp --%>
<%
    if (session.getAttribute("admin_id") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }
    String adminName = (String) session.getAttribute("admin_name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Study Planner</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .navbar { background: linear-gradient(135deg, #2c3e50, #34495e); }
        .navbar-brand span { color: #f39c12; }
        th { background: #2c3e50; }
        .stat-card { border-top-color: #2c3e50; }
        .stat-num  { color: #2c3e50; }
    </style>
</head>
<body>
<nav class="navbar">
    <a class="navbar-brand" href="<%= request.getContextPath() %>/admin/dashboard.jsp">
         Admin<span>Panel</span>
    </a>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/admin/dashboard.jsp">Dashboard</a>
        <a href="<%= request.getContextPath() %>/admin/manage_users.jsp">Users</a>
        <a href="<%= request.getContextPath() %>/admin/manage_subjects.jsp">Subjects</a>
        <a href="<%= request.getContextPath() %>/admin/manage_syllabus.jsp">Syllabus</a>
        <a href="<%= request.getContextPath() %>/admin/manage_predictions.jsp">Predictions</a>
        <a href="<%= request.getContextPath() %>/admin/logout.jsp" class="btn-logout">Logout</a>
    </div>
</nav>
<div class="main-wrapper">
