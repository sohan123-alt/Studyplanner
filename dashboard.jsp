<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<meta charset="UTF-8">
<%@ page import="java.sql.*" %>
<%@ include file="includes/db.jsp" %>
<%@ include file="includes/header.jsp" %>
<%
    int userId = (Integer) session.getAttribute("user_id");
    int subjectCount = 0, planCount = 0, weakCount = 0;
    int totalScore = 0, scoreEntries = 0;
    String recentPlan = "No plan yet";

    Connection con = null;
    try {
        con = getConnection();

        // Count subjects
        PreparedStatement ps = con.prepareStatement(
            "SELECT COUNT(*) FROM Subjects WHERE user_id=?");
        ps.setInt(1, userId); ResultSet rs = ps.executeQuery(); rs.next();
        subjectCount = rs.getInt(1);

        // Count study plans
        ps = con.prepareStatement("SELECT COUNT(*) FROM StudyPlan WHERE user_id=?");
        ps.setInt(1, userId); rs = ps.executeQuery(); rs.next();
        planCount = rs.getInt(1);

        // Weak subjects (score < 50%)
        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM Progress WHERE user_id=? AND (score/max_score*100) < 50");
        ps.setInt(1, userId); rs = ps.executeQuery(); rs.next();
        weakCount = rs.getInt(1);

        // Average score
        ps = con.prepareStatement(
            "SELECT SUM(score), SUM(max_score) FROM Progress WHERE user_id=?");
        ps.setInt(1, userId); rs = ps.executeQuery(); rs.next();
        int s = rs.getInt(1), m = rs.getInt(2);
        if (m > 0) totalScore = (int)((double)s/m*100);

        // Latest plan entry
        ps = con.prepareStatement(
            "SELECT task_desc, plan_date FROM StudyPlan WHERE user_id=? AND ROWNUM=1 ORDER BY plan_date");
        ps.setInt(1, userId); rs = ps.executeQuery();
        if (rs.next()) recentPlan = rs.getString("task_desc");
    } catch(Exception e) {
        out.println("<div class='alert alert-danger'>DB Error: "+e.getMessage()+"</div>");
    } finally {
        if (con!=null) try{con.close();}catch(Exception ignored){}
    }
%>

<h1 class="page-title">👋 Welcome, <%= userName %>!</h1>
<p style="color:#718096;margin-bottom:24px;">
    Academic Level: <strong><%= userLevel %></strong> &nbsp;|&nbsp;
    Your personalized study dashboard
</p>

<!-- Stats -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-num"><%= subjectCount %></div>
        <div class="stat-label">📚 Subjects</div>
    </div>
    <div class="stat-card green">
        <div class="stat-num"><%= planCount %></div>
        <div class="stat-label">🗓️ Study Tasks</div>
    </div>
    <div class="stat-card red">
        <div class="stat-num"><%= weakCount %></div>
        <div class="stat-label">⚠️ Weak Subjects</div>
    </div>
    <div class="stat-card orange">
        <div class="stat-num"><%= totalScore %>%</div>
        <div class="stat-label">📈 Avg Score</div>
    </div>
</div>

<!-- Quick Actions -->
<div class="grid-2">
    <div class="card">
        <div class="card-title"><span class="icon">⚡</span>Quick Actions</div>
        <div style="display:flex;flex-direction:column;gap:10px;">
            <a href="subjects.jsp" class="btn btn-primary">➕ Add Subject</a>
            <a href="syllabus.jsp" class="btn btn-success">📄 Upload Syllabus</a>
            <a href="studyplan.jsp" class="btn btn-warning">🗓️ Generate Study Plan</a>
            <a href="progress.jsp" class="btn btn-secondary">📊 Update Progress</a>
        </div>
    </div>
    <div class="card">
        <div class="card-title"><span class="icon">💡</span>Study Tips</div>
        <div class="alert alert-info">
            <strong>Today's Reminder:</strong> <%= recentPlan %>
        </div>
        <div class="subject-item">
            <strong>📌 Rule 1:</strong> Study weak subjects first when your mind is fresh.
        </div>
        <div class="subject-item strong">
            <strong>📌 Rule 2:</strong> Revise strong subjects 30 min before bed.
        </div>
        <div class="subject-item average">
            <strong>📌 Rule 3:</strong> Practice predicted questions 2 weeks before exams.
        </div>
    </div>
</div>

<!-- Readiness Bar -->
<div class="card">
    <div class="card-title"><span class="icon">🎯</span>Exam Readiness</div>
    <p style="color:#4a5568;margin-bottom:8px;">
        Overall readiness based on your progress scores:
        <strong style="color:<%= totalScore>=70?"#27ae60":totalScore>=40?"#e67e22":"#e74c3c" %>">
            <%= totalScore %>%
        </strong>
    </p>
    <div class="progress-bar-wrap">
        <div class="progress-bar <%= totalScore>=70?"green":totalScore>=40?"orange":"red" %>"
             style="width:<%= totalScore %>%"></div>
    </div>
    <p style="font-size:0.82rem;color:#718096;margin-top:8px;">
        <% if(totalScore>=70){ %>🟢 You're on track! Keep it up.
        <% }else if(totalScore>=40){ %>🟡 Fair progress. Focus on weak subjects.
        <% }else{ %>🔴 Needs improvement. Add subjects and track progress!<% } %>
    </p>
</div>

<div class="grid-2">
    <div class="card">
        <div class="card-title"><span class="icon">❓</span>Exam Predictions</div>
        <p style="color:#4a5568;margin-bottom:12px;">
            Check AI-predicted questions for your upcoming exams.
        </p>
        <a href="predictions.jsp" class="btn btn-primary">View Predictions</a>
    </div>
    <div class="card">
        <div class="card-title"><span class="icon">🔍</span>Weak Subject Analysis</div>
        <p style="color:#4a5568;margin-bottom:12px;">
            See which subjects need more attention based on your scores.
        </p>
        <a href="weak_subjects.jsp" class="btn btn-danger">View Analysis</a>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>
