<%-- admin/dashboard.jsp - Admin Dashboard --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/db.jsp" %>
<%@ include file="admin_header.jsp" %>
<%
    int totalUsers = 0, totalSubjects = 0, totalPredictions = 0, totalProgress = 0;
    Connection con = null;
    try {
        con = getConnection();
        ResultSet rs;
        PreparedStatement ps;

        ps = con.prepareStatement("SELECT COUNT(*) FROM Users4");
        rs = ps.executeQuery(); rs.next(); totalUsers = rs.getInt(1);

        ps = con.prepareStatement("SELECT COUNT(*) FROM Subjects");
        rs = ps.executeQuery(); rs.next(); totalSubjects = rs.getInt(1);

        ps = con.prepareStatement("SELECT COUNT(*) FROM Predictions");
        rs = ps.executeQuery(); rs.next(); totalPredictions = rs.getInt(1);

        ps = con.prepareStatement("SELECT COUNT(*) FROM Progress");
        rs = ps.executeQuery(); rs.next(); totalProgress = rs.getInt(1);
    } catch(Exception e) {
        out.println("<div class='alert alert-danger'>DB Error: "+e.getMessage()+"</div>");
    } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
%>

<h1 class="page-title">Admin Dashboard</h1>
<p style="color:#718096;margin-bottom:24px;">Welcome back, <strong><%= adminName %></strong>! Here's your system overview.</p>

<!-- Stats -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-num"><%= totalUsers %></div>
        <div class="stat-label">👨‍🎓 Total Students</div>
    </div>
    <div class="stat-card green">
        <div class="stat-num"><%= totalSubjects %></div>
        <div class="stat-label">📚 Total Subjects</div>
    </div>
    <div class="stat-card purple">
        <div class="stat-num"><%= totalPredictions %></div>
        <div class="stat-label">❓ Predictions</div>
    </div>
    <div class="stat-card orange">
        <div class="stat-num"><%= totalProgress %></div>
        <div class="stat-label">📊 Progress Entries</div>
    </div>
</div>

<!-- Quick Nav -->
<div class="grid-2">
    <div class="card">
        <div class="card-title"><span class="icon">🔧</span>Quick Management</div>
        <div style="display:flex;flex-direction:column;gap:10px;">
            <a href="manage_users.jsp"       class="btn btn-primary">👨‍🎓 Manage Users</a>
            <a href="manage_subjects.jsp"    class="btn btn-success">📚 Manage Subjects</a>
            <a href="manage_syllabus.jsp"    class="btn btn-warning">📄 Manage Syllabus</a>
            <a href="manage_predictions.jsp" class="btn btn-secondary">❓ Manage Predictions</a>
        </div>
    </div>

    <!-- Recent Users -->
    <div class="card">
        <div class="card-title"><span class="icon">🆕</span>Recently Registered Students</div>
        <%
            Connection con2 = null;
            try {
                con2 = getConnection();
                PreparedStatement ps2 = con2.prepareStatement(
                    "SELECT full_name, email, academic_level, created_at FROM Users4 ORDER BY created_at DESC FETCH FIRST 5 ROWS ONLY");
                ResultSet rs2 = ps2.executeQuery();
                boolean found = false;
                while(rs2.next()) {
                    found = true;
        %>
        <div class="subject-item" style="padding:10px 14px;">
            <strong><%= rs2.getString("full_name") %></strong>
            <span class="badge badge-primary" style="margin-left:6px;"><%= rs2.getString("academic_level") %></span>
            <div style="font-size:0.8rem;color:#718096;margin-top:2px;">
                <%= rs2.getString("email") %> &nbsp;|&nbsp; <%= rs2.getDate("created_at") %>
            </div>
        </div>
        <%  }
            if (!found) { %><div class="alert alert-info">No students registered yet.</div><% }
            } catch(Exception e) {
                out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
            } finally { if(con2!=null) try{con2.close();}catch(Exception ignored){} }
        %>
    </div>
</div>

<!-- Recent Progress Entries -->
<div class="card">
    <div class="card-title"><span class="icon">📈</span>Recent Progress Entries (All Students)</div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr><th>#</th><th>Student</th><th>Subject</th><th>Score</th><th>Percentage</th><th>Date</th></tr>
            </thead>
            <tbody>
            <%
                Connection con3 = null;
                int cnt = 1;
                try {
                    con3 = getConnection();
                    PreparedStatement ps3 = con3.prepareStatement(
                        "SELECT u.full_name, p.subject_name, p.score, p.max_score, p.recorded_at " +
                        "FROM Progress p JOIN Users4 u ON p.user_id = u.user_id " +
                        "ORDER BY p.recorded_at DESC FETCH FIRST 10 ROWS ONLY");
                    ResultSet rs3 = ps3.executeQuery();
                    boolean any = false;
                    while(rs3.next()) {
                        any = true;
                        double pct = (double)rs3.getInt("score") / rs3.getInt("max_score") * 100;
                        String badge = pct>=70?"badge-success":pct>=40?"badge-warning":"badge-danger";
            %>
                <tr>
                    <td><%= cnt++ %></td>
                    <td><%= rs3.getString("full_name") %></td>
                    <td><%= rs3.getString("subject_name") %></td>
                    <td><%= rs3.getInt("score") %> / <%= rs3.getInt("max_score") %></td>
                    <td><span class="badge <%= badge %>"><%= String.format("%.1f",pct) %>%</span></td>
                    <td><%= rs3.getDate("recorded_at") %></td>
                </tr>
            <%      }
                    if (!any) { %><tr><td colspan="6" style="text-align:center;color:#718096;">No data.</td></tr><% }
                } catch(Exception e) {
                    out.println("<tr><td colspan='6'>Error: "+e.getMessage()+"</td></tr>");
                } finally { if(con3!=null) try{con3.close();}catch(Exception ignored){} }
            %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>
