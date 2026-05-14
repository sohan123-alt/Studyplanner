<%-- weak_subjects.jsp - Weak Subject Detection --%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="includes/db.jsp" %>
<%@ include file="includes/header.jsp" %>
<%
    int userId = (Integer) session.getAttribute("user_id");
%>

<h1 class="page-title">🔍 Weak Subject Analysis</h1>
<div class="alert alert-info">
    <strong>How it works:</strong> Subjects where your average score is below 50% are marked as
    <strong>Weak</strong>. Subjects between 50–70% are <strong>Average</strong>.
    Above 70% is <strong>Strong</strong>.
</div>

<div class="card">
    <div class="card-title"><span class="icon">⚠️</span>Weak Subjects (Below 50%)</div>
    <%
        Connection con = null;
        boolean anyWeak = false;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT subject_name, ROUND(AVG(score/max_score*100),1) AS avg_pct " +
                "FROM Progress WHERE user_id=? " +
                "GROUP BY subject_name HAVING AVG(score/max_score*100) < 50 ORDER BY avg_pct ASC");
            ps.setInt(1, userId); ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                anyWeak = true;
                double pct = rs.getDouble("avg_pct");
    %>
    <div class="subject-item weak">
        <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;">
            <div>
                <strong>⚠️ <%= rs.getString("subject_name") %></strong>
                <span class="badge badge-danger" style="margin-left:8px;"><%= pct %>%</span>
            </div>
            <div>
                <span class="badge badge-danger">Weak Subject</span>
            </div>
        </div>
        <div style="margin-top:10px;">
            <div class="progress-bar-wrap">
                <div class="progress-bar red" style="width:<%= pct %>%"></div>
            </div>
        </div>
        <div style="margin-top:10px;font-size:0.88rem;color:#742a2a;">
            💡 <strong>Recommendation:</strong> Allocate 3+ hours/day. Review basics, practice past questions,
            and seek help for difficult topics in <%= rs.getString("subject_name") %>.
        </div>
    </div>
    <%  }
        if (!anyWeak) { %>
    <div class="alert alert-success">
        🎉 No weak subjects found! You're doing great. Keep it up!
    </div>
    <%  }
    } catch(Exception e) {
        out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
    } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    %>
</div>

<div class="card">
    <div class="card-title"><span class="icon">📊</span>Average Subjects (50%–70%)</div>
    <%
        Connection con2 = null;
        boolean anyAvg = false;
        try {
            con2 = getConnection();
            PreparedStatement ps2 = con2.prepareStatement(
                "SELECT subject_name, ROUND(AVG(score/max_score*100),1) AS avg_pct " +
                "FROM Progress WHERE user_id=? " +
                "GROUP BY subject_name HAVING AVG(score/max_score*100) BETWEEN 50 AND 70 ORDER BY avg_pct");
            ps2.setInt(1, userId); ResultSet rs2 = ps2.executeQuery();
            while(rs2.next()) {
                anyAvg = true;
                double pct = rs2.getDouble("avg_pct");
    %>
    <div class="subject-item average">
        <div style="display:flex;justify-content:space-between;align-items:center;">
            <div>
                <strong>📖 <%= rs2.getString("subject_name") %></strong>
                <span class="badge badge-warning" style="margin-left:8px;"><%= pct %>%</span>
            </div>
            <span class="badge badge-warning">Average</span>
        </div>
        <div style="margin-top:8px;">
            <div class="progress-bar-wrap">
                <div class="progress-bar orange" style="width:<%= pct %>%"></div>
            </div>
        </div>
        <div style="font-size:0.85rem;color:#744210;margin-top:8px;">
            💡 <strong>Tip:</strong> You are close to a good grade! Spend 2 hrs/day revising missed concepts.
        </div>
    </div>
    <%  }
        if (!anyAvg) { %>
    <div class="alert alert-info">No average-range subjects at this time.</div>
    <%  }
    } catch(Exception e) {
        out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
    } finally { if(con2!=null) try{con2.close();}catch(Exception ignored){} }
    %>
</div>

<div class="card">
    <div class="card-title"><span class="icon">💪</span>Strong Subjects (Above 70%)</div>
    <%
        Connection con3 = null;
        try {
            con3 = getConnection();
            PreparedStatement ps3 = con3.prepareStatement(
                "SELECT subject_name, ROUND(AVG(score/max_score*100),1) AS avg_pct " +
                "FROM Progress WHERE user_id=? " +
                "GROUP BY subject_name HAVING AVG(score/max_score*100) > 70 ORDER BY avg_pct DESC");
            ps3.setInt(1, userId); ResultSet rs3 = ps3.executeQuery();
            boolean anyStrong = false;
            while(rs3.next()) {
                anyStrong = true;
                double pct = rs3.getDouble("avg_pct");
    %>
    <div class="subject-item strong">
        <div style="display:flex;justify-content:space-between;align-items:center;">
            <div>
                <strong>💪 <%= rs3.getString("subject_name") %></strong>
                <span class="badge badge-success" style="margin-left:8px;"><%= pct %>%</span>
            </div>
            <span class="badge badge-success">Strong</span>
        </div>
        <div style="margin-top:8px;">
            <div class="progress-bar-wrap">
                <div class="progress-bar green" style="width:<%= pct %>%"></div>
            </div>
        </div>
    </div>
    <%  }
        if (!anyStrong) { %><div class="alert alert-info">No strong subjects logged yet.</div><% }
    } catch(Exception e) {
        out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
    } finally { if(con3!=null) try{con3.close();}catch(Exception ignored){} }
    %>
</div>

<div style="text-align:center;margin-top:8px;">
    <a href="progress.jsp" class="btn btn-primary">➕ Add More Scores</a>
    <a href="studyplan.jsp" class="btn btn-success" style="margin-left:10px;">🗓️ Update Study Plan</a>
</div>

<%@ include file="includes/footer.jsp" %>
