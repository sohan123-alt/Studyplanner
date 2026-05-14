<%-- progress.jsp - Progress Tracking --%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="includes/db.jsp" %>
<%@ include file="includes/header.jsp" %>
<%
    int userId = (Integer) session.getAttribute("user_id");
    String msg = ""; String msgType = "";

    if ("POST".equals(request.getMethod())) {
        String subjectName = request.getParameter("subject_name").trim();
        int score    = Integer.parseInt(request.getParameter("score"));
        int maxScore = Integer.parseInt(request.getParameter("max_score"));
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO Progress (user_id, subject_name, score, max_score) VALUES(?,?,?,?)");
            ps.setInt(1, userId); ps.setString(2, subjectName);
            ps.setInt(3, score); ps.setInt(4, maxScore);
            ps.executeUpdate();
            msg = "Progress saved!"; msgType = "success";
        } catch(Exception e) {
            msg = "Error: "+e.getMessage(); msgType = "danger";
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }
%>

<h1 class="page-title">📊 Progress Tracking</h1>
<% if(!msg.isEmpty()){ %><div class="alert alert-<%= msgType %>"><%= msg %></div><% } %>

<div class="grid-2">
    <!-- Log Progress -->
    <div class="card">
        <div class="card-title"><span class="icon">📝</span>Log Score / Result</div>
        <form method="post" action="progress.jsp">
            <div class="form-group">
                <label>Subject Name *</label>
                <select name="subject_name" class="form-control">
                    <%
                        Connection con3 = null;
                        try {
                            con3 = getConnection();
                            PreparedStatement ps3 = con3.prepareStatement(
                                "SELECT subject_name FROM Subjects WHERE user_id=? ORDER BY subject_name");
                            ps3.setInt(1, userId); ResultSet rs3 = ps3.executeQuery();
                            while(rs3.next()) {
                    %>
                    <option value="<%= rs3.getString(1) %>"><%= rs3.getString(1) %></option>
                    <%      }
                        } catch(Exception e){ out.println("<option>Error</option>"); }
                        finally { if(con3!=null) try{con3.close();}catch(Exception ignored){} }
                    %>
                </select>
            </div>
            <div class="form-group">
                <label>Your Score</label>
                <input type="number" name="score" class="form-control" value="0" min="0" max="500">
            </div>
            <div class="form-group">
                <label>Out of (Max Score)</label>
                <input type="number" name="max_score" class="form-control" value="100" min="1" max="500">
            </div>
            <button type="submit" class="btn btn-primary btn-block">Save Score</button>
        </form>
    </div>

    <!-- Progress Summary -->
    <div class="card">
        <div class="card-title"><span class="icon">📈</span>Progress Per Subject</div>
        <%
            Connection con4 = null;
            try {
                con4 = getConnection();
                PreparedStatement ps4 = con4.prepareStatement(
                    "SELECT subject_name, ROUND(AVG(score/max_score*100),1) AS avg_pct, COUNT(*) AS cnt " +
                    "FROM Progress WHERE user_id=? GROUP BY subject_name ORDER BY avg_pct DESC");
                ps4.setInt(1, userId); ResultSet rs4 = ps4.executeQuery();
                boolean found = false;
                while(rs4.next()) {
                    found = true;
                    double pct = rs4.getDouble("avg_pct");
                    String cls = pct >= 70 ? "green" : pct >= 40 ? "orange" : "red";
                    String label = pct >= 70 ? "Strong 💪" : pct >= 40 ? "Average 📖" : "Weak ⚠️";
        %>
        <div style="margin-bottom:14px;">
            <div style="display:flex;justify-content:space-between;margin-bottom:4px;">
                <strong><%= rs4.getString("subject_name") %></strong>
                <span style="font-size:0.85rem;color:#718096;"><%= pct %>% &nbsp;
                    <span class="badge badge-<%= pct>=70?"success":pct>=40?"warning":"danger" %>">
                        <%= label %>
                    </span>
                </span>
            </div>
            <div class="progress-bar-wrap">
                <div class="progress-bar <%= cls %>" style="width:<%= pct %>%"></div>
            </div>
            <div style="font-size:0.78rem;color:#a0aec0;margin-top:3px;">
                Based on <%= rs4.getInt("cnt") %> score entries
            </div>
        </div>
        <%  }
            if (!found) { %>
                <div class="alert alert-info">No scores logged yet. Add your first test result!</div>
        <%  }
            } catch(Exception e) {
                out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
            } finally { if(con4!=null) try{con4.close();}catch(Exception ignored){} }
        %>
    </div>
</div>

<!-- Recent Scores Table -->
<div class="card">
    <div class="card-title"><span class="icon">🗂️</span>Recent Score History</div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr><th>#</th><th>Subject</th><th>Score</th><th>Percentage</th><th>Date</th><th>Status</th></tr>
            </thead>
            <tbody>
            <%
                Connection con5 = null;
                int counter = 1;
                try {
                    con5 = getConnection();
                    PreparedStatement ps5 = con5.prepareStatement(
                        "SELECT * FROM Progress WHERE user_id=? ORDER BY recorded_at DESC");
                    ps5.setInt(1, userId); ResultSet rs5 = ps5.executeQuery();
                    boolean anyRow = false;
                    while(rs5.next()) {
                        anyRow = true;
                        double pct = (double)rs5.getInt("score") / rs5.getInt("max_score") * 100;
                        String badge = pct>=70?"badge-success":pct>=40?"badge-warning":"badge-danger";
                        String label = pct>=70?"Pass":"pct>=40?Average":"Fail";
                        // Simpler:
                        String lbl = pct>=70?"Pass":pct>=40?"Average":"Fail";
            %>
                    <tr>
                        <td><%= counter++ %></td>
                        <td><%= rs5.getString("subject_name") %></td>
                        <td><%= rs5.getInt("score") %> / <%= rs5.getInt("max_score") %></td>
                        <td><%= String.format("%.1f", pct) %>%</td>
                        <td><%= rs5.getDate("recorded_at") %></td>
                        <td><span class="badge <%= badge %>"><%= lbl %></span></td>
                    </tr>
            <%      }
                    if (!anyRow) {
            %><tr><td colspan="6" style="text-align:center;color:#718096;">No records yet.</td></tr><%
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='6'>Error: "+e.getMessage()+"</td></tr>");
                } finally { if(con5!=null) try{con5.close();}catch(Exception ignored){} }
            %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>
