<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<meta charset="UTF-8">
<%@ page import="java.sql.*" %>
<%@ include file="../includes/db.jsp" %>
<%@ include file="admin_header.jsp" %>
<%
    String msg = ""; String msgType = "";

    // Handle delete
    if (request.getParameter("delete") != null) {
        int delId = Integer.parseInt(request.getParameter("delete"));
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement("DELETE FROM Subjects WHERE subject_id=?");
            ps.setInt(1, delId); ps.executeUpdate();
            msg = "Subject deleted."; msgType = "warning";
        } catch(Exception e) {
            msg = "Error: "+e.getMessage(); msgType = "danger";
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }

    // Handle admin add subject (global subject for any user demo)
    if ("POST".equals(request.getMethod())) {
        int targetUserId = Integer.parseInt(request.getParameter("target_user_id"));
        String subName   = request.getParameter("subject_name").trim();
        String examDate  = request.getParameter("exam_date");
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO Subjects (user_id, subject_name, exam_date, total_marks) VALUES(?,?,TO_DATE(?,'YYYY-MM-DD'),100)");
            ps.setInt(1, targetUserId); ps.setString(2, subName);
            ps.setString(3, examDate.isEmpty() ? null : examDate);
            ps.executeUpdate();
            msg = "Subject added."; msgType = "success";
        } catch(Exception e) {
            msg = "Error: "+e.getMessage(); msgType = "danger";
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }
%>

<h1 class="page-title">📚 Manage Subjects</h1>
<% if(!msg.isEmpty()){ %><div class="alert alert-<%= msgType %>"><%= msg %></div><% } %>

<div class="grid-2">
    <!-- Add Subject for a User -->
    <div class="card">
        <div class="card-title"><span class="icon">➕</span>Add Subject for a Student</div>
        <form method="post" action="manage_subjects.jsp">
            <div class="form-group">
                <label>Select Student</label>
                <select name="target_user_id" class="form-control" required>
                    <option value="">-- Choose Student --</option>
                    <%
                        Connection conU = null;
                        try {
                            conU = getConnection();
                            PreparedStatement psU = conU.prepareStatement(
                                "SELECT user_id, full_name, academic_level FROM Users4 ORDER BY full_name");
                            ResultSet rsU = psU.executeQuery();
                            while(rsU.next()) {
                    %>
                    <option value="<%= rsU.getInt("user_id") %>">
                        <%= rsU.getString("full_name") %> (<%= rsU.getString("academic_level") %>)
                    </option>
                    <%      }
                        } catch(Exception e){ out.println("<option>Error</option>"); }
                        finally { if(conU!=null) try{conU.close();}catch(Exception ignored){} }
                    %>
                </select>
            </div>
            <div class="form-group">
                <label>Subject Name</label>
                <input type="text" name="subject_name" class="form-control"
                       placeholder="e.g. Physics, Mathematics" required>
            </div>
            <div class="form-group">
                <label>Exam Date (optional)</label>
                <input type="date" name="exam_date" class="form-control">
            </div>
            <button type="submit" class="btn btn-primary btn-block">Add Subject</button>
        </form>
    </div>

    <!-- Summary by user -->
    <div class="card">
        <div class="card-title"><span class="icon">📊</span>Subjects Per Student</div>
        <%
            Connection conS = null;
            try {
                conS = getConnection();
                PreparedStatement psS = conS.prepareStatement(
                    "SELECT u.full_name, u.academic_level, COUNT(s.subject_id) AS cnt " +
                    "FROM Users4 u LEFT JOIN Subjects s ON u.user_id=s.user_id " +
                    "GROUP BY u.full_name, u.academic_level ORDER BY cnt DESC");
                ResultSet rsS = psS.executeQuery();
                boolean found = false;
                while(rsS.next()) {
                    found = true;
                    int cnt = rsS.getInt("cnt");
                    String lvl = rsS.getString("academic_level");
                    String badge = "University".equals(lvl)?"badge-primary":"HSC".equals(lvl)?"badge-warning":"badge-success";
        %>
        <div class="subject-item" style="padding:10px 14px;display:flex;justify-content:space-between;align-items:center;">
            <div>
                <strong><%= rsS.getString("full_name") %></strong>
                <span class="badge <%= badge %>" style="margin-left:6px;"><%= lvl %></span>
            </div>
            <span class="badge badge-info"><%= cnt %> subject<%= cnt!=1?"s":"" %></span>
        </div>
        <%  }
            if (!found) { %><div class="alert alert-info">No users found.</div><% }
            } catch(Exception e) {
                out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
            } finally { if(conS!=null) try{conS.close();}catch(Exception ignored){} }
        %>
    </div>
</div>

<!-- All Subjects Table -->
<div class="card">
    <div class="card-title"><span class="icon">📋</span>All Subjects in System</div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr><th>#</th><th>Student</th><th>Subject</th><th>Exam Date</th><th>Total Marks</th><th>Action</th></tr>
            </thead>
            <tbody>
            <%
                Connection con2 = null; int counter = 1;
                try {
                    con2 = getConnection();
                    PreparedStatement ps2 = con2.prepareStatement(
                        "SELECT s.subject_id, s.subject_name, s.exam_date, s.total_marks, u.full_name " +
                        "FROM Subjects s JOIN Users4 u ON s.user_id=u.user_id " +
                        "ORDER BY u.full_name, s.subject_name");
                    ResultSet rs2 = ps2.executeQuery();
                    boolean found = false;
                    while(rs2.next()) {
                        found = true;
                        String ed = rs2.getDate("exam_date") != null ? rs2.getDate("exam_date").toString() : "-";
            %>
                <tr>
                    <td><%= counter++ %></td>
                    <td><%= rs2.getString("full_name") %></td>
                    <td><strong><%= rs2.getString("subject_name") %></strong></td>
                    <td><%= ed %></td>
                    <td><%= rs2.getInt("total_marks") %></td>
                    <td>
                        <a href="manage_subjects.jsp?delete=<%= rs2.getInt("subject_id") %>"
                           class="btn btn-danger btn-sm"
                           onclick="return confirm('Delete this subject?')">🗑️ Delete</a>
                    </td>
                </tr>
            <%      }
                    if (!found) {
            %><tr><td colspan="6" style="text-align:center;color:#718096;padding:16px;">No subjects found.</td></tr><%
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='6'>Error: "+e.getMessage()+"</td></tr>");
                } finally { if(con2!=null) try{con2.close();}catch(Exception ignored){} }
            %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>
