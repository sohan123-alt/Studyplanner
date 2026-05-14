<%-- includes/header.jsp --%>
<%
    // Redirect to login if not logged in
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String userName = (String) session.getAttribute("user_name");
    String userLevel = (String) session.getAttribute("user_level");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Study Planner - Bangladesh</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<nav class="navbar">
    <a class="navbar-brand" href="<%= request.getContextPath() %>/dashboard.jsp">
         Study<span>Planner</span> BD
    </a>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/dashboard.jsp">Home</a>
        <a href="<%= request.getContextPath() %>/subjects.jsp">Subjects</a>
        <a href="<%= request.getContextPath() %>/studyplan.jsp">Plan</a>
        <a href="<%= request.getContextPath() %>/predictions.jsp">Questions</a>
        <a href="<%= request.getContextPath() %>/progress.jsp">Progress</a>
        <a href="<%= request.getContextPath() %>/logout.jsp" class="btn-logout">Logout</a>
    </div>
</nav>
<div class="main-wrapper">
