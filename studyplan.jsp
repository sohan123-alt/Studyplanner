<%-- studyplan.jsp - AI Study Plan Generator --%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ include file="includes/db.jsp" %>
<%@ include file="includes/header.jsp" %>
<%
    int userId = (Integer) session.getAttribute("user_id");
    String msg = ""; String msgType = "";

    // ── Generate Plan Logic ────────────────────────────────────
    if ("POST".equals(request.getMethod()) && "generate".equals(request.getParameter("action"))) {
        int daysAhead = 14; // generate 2 weeks plan
        String[] taskTypes = {"New Topic Study", "Revision", "Practice Questions", "New Topic Study", "Revision"};
        Connection con = null;
        try {
            con = getConnection();
            // Fetch user's subjects
            PreparedStatement ps = con.prepareStatement(
                "SELECT subject_name FROM Subjects WHERE user_id=? ORDER BY exam_date NULLS LAST");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            List<String> subjects = new ArrayList<>();
            while(rs.next()) subjects.add(rs.getString("subject_name"));

            if (subjects.isEmpty()) {
                msg = "Please add subjects first before generating a plan!";
                msgType = "warning";
            } else {
                // Delete old pending plan
                PreparedStatement del = con.prepareStatement(
                    "DELETE FROM StudyPlan WHERE user_id=? AND status='Pending'");
                del.setInt(1, userId); del.executeUpdate();

                // Generate plan: rotate subjects day by day
                PreparedStatement ins = con.prepareStatement(
                    "INSERT INTO StudyPlan (user_id, subject_name, plan_date, duration_hrs, task_desc, status) VALUES(?,?,?,?,?,'Pending')");

                Calendar cal = Calendar.getInstance();
                for (int day = 0; day < daysAhead; day++) {
                    cal.setTime(new Date());
                    cal.add(Calendar.DAY_OF_YEAR, day);
                    java.sql.Date planDate = new java.sql.Date(cal.getTimeInMillis());
                    String subject  = subjects.get(day % subjects.size());
                    String taskType = taskTypes[day % taskTypes.length];
                    int hours       = (day % 3 == 0) ? 3 : 2;
                    String taskDesc = taskType + " - " + subject + " (" + hours + " hrs)";

                    ins.setInt(1, userId);
                    ins.setString(2, subject);
                    ins.setDate(3, planDate);
                    ins.setInt(4, hours);
                    ins.setString(5, taskDesc);
                    ins.addBatch();
                }
                ins.executeBatch();
                msg = "14-day study plan generated successfully!";
                msgType = "success";
            }
        } catch(Exception e) {
            msg = "Error: " + e.getMessage(); msgType = "danger";
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }

    // Mark as completed
    if (request.getParameter("complete") != null) {
        int planId = Integer.parseInt(request.getParameter("complete"));
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement(
                "UPDATE StudyPlan SET status='Completed' WHERE plan_id=? AND user_id=?");
            ps.setInt(1, planId); ps.setInt(2, userId); ps.executeUpdate();
        } catch(Exception e) {} finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }
%>

<h1 class="page-title">🗓️ My Study Plan</h1>

<% if(!msg.isEmpty()){ %><div class="alert alert-<%= msgType %>"><%= msg %></div><% } %>

<div class="card">
    <div class="card-title"><span class="icon">⚡</span>Generate New Plan</div>
    <p style="color:#4a5568;margin-bottom:12px;">
        This will generate a 14-day rotating study plan based on your subjects.
        Subjects with earlier exam dates get priority.
    </p>
    <form method="post" action="studyplan.jsp">
        <input type="hidden" name="action" value="generate">
        <button type="submit" class="btn btn-primary"
                onclick="return confirm('This will replace your current pending plan. Continue?')">
            🤖 Generate AI Study Plan
        </button>
        <a href="subjects.jsp" class="btn btn-secondary" style="margin-left:8px;">
            ➕ Manage Subjects
        </a>
    </form>
</div>

<!-- Plan Table -->
<div class="card">
    <div class="card-title"><span class="icon">📋</span>Your Study Schedule</div>
    <%
        Connection con2 = null;
        try {
            con2 = getConnection();
            PreparedStatement ps2 = con2.prepareStatement(
                "SELECT * FROM StudyPlan WHERE user_id=? ORDER BY plan_date ASC, plan_id ASC");
            ps2.setInt(1, userId);
            ResultSet rs2 = ps2.executeQuery();
            boolean found = false;
            while(rs2.next()) {
                found = true;
                String status = rs2.getString("status");
                String dateStr = rs2.getDate("plan_date") != null
                    ? rs2.getDate("plan_date").toString() : "-";
                String badgeClass = "Completed".equals(status) ? "badge-success" : "badge-warning";
    %>
    <div class="plan-day" style="<%= "Completed".equals(status) ? "opacity:0.65;" : "" %>">
        <div>
            <div class="day-label">📅 <%= dateStr %></div>
            <div class="day-task"><%= rs2.getString("task_desc") %></div>
        </div>
        <div style="display:flex;align-items:center;gap:8px;">
            <span class="badge <%= badgeClass %>"><%= status %></span>
            <% if (!"Completed".equals(status)) { %>
            <a href="studyplan.jsp?complete=<%= rs2.getInt("plan_id") %>"
               class="btn btn-success btn-sm">✓ Done</a>
            <% } %>
        </div>
    </div>
    <%  }
        if (!found) { %>
            <div class="alert alert-info">
                No study plan yet. Click <strong>"Generate AI Study Plan"</strong> above!
            </div>
    <%  }
        } catch(Exception e) {
            out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
        } finally { if(con2!=null) try{con2.close();}catch(Exception ignored){} }
    %>
</div>

<%@ include file="includes/footer.jsp" %>
