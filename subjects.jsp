<%-- subjects.jsp - Add & View Subjects --%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%@ include file="includes/db.jsp" %>
<%@ include file="includes/header.jsp" %>
<%
    int userId = (Integer) session.getAttribute("user_id");
    String msg = ""; String msgType = "";

    // Handle Add
    if ("POST".equals(request.getMethod()) && "add".equals(request.getParameter("action"))) {
        String subName   = request.getParameter("subject_name").trim();
        String examDate  = request.getParameter("exam_date");
        String totalMark = request.getParameter("total_marks");
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO Subjects (user_id, subject_name, exam_date, total_marks) VALUES(?,?,TO_DATE(?,'YYYY-MM-DD'),?)");
            ps.setInt(1, userId);
            ps.setString(2, subName);
            ps.setString(3, examDate.isEmpty() ? null : examDate);
            ps.setInt(4, totalMark.isEmpty() ? 100 : Integer.parseInt(totalMark));
            ps.executeUpdate();
            msg = "Subject added successfully!"; msgType = "success";
        } catch(Exception e) {
            msg = "Error: " + e.getMessage(); msgType = "danger";
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }

    // Handle Delete
    if (request.getParameter("delete") != null) {
        int delId = Integer.parseInt(request.getParameter("delete"));
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement(
                "DELETE FROM Subjects WHERE subject_id=? AND user_id=?");
            ps.setInt(1, delId); ps.setInt(2, userId);
            ps.executeUpdate();
            msg = "Subject deleted."; msgType = "warning";
        } catch(Exception e) {
            msg = "Error: " + e.getMessage(); msgType = "danger";
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }
%>

<h1 class="page-title">📚 My Subjects</h1>

<% if(!msg.isEmpty()){ %><div class="alert alert-<%= msgType %>"><%= msg %></div><% } %>

<div class="grid-2">
    <!-- Add Form -->
    <div class="card">
        <div class="card-title"><span class="icon">➕</span>Add New Subject</div>
        <form method="post" action="subjects.jsp">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label>Subject Name *</label>
                <input type="text" name="subject_name" class="form-control" placeholder="e.g. Physics, Mathematics" required>
            </div>
            <div class="form-group">
                <label>Exam Date</label>
                <input type="date" name="exam_date" class="form-control">
            </div>
            <div class="form-group">
                <label>Total Marks</label>
                <input type="number" name="total_marks" class="form-control" value="100" min="1" max="500">
            </div>
            <button type="submit" class="btn btn-primary btn-block">Add Subject</button>
        </form>
    </div>

    <!-- Subject List -->
    <div class="card">
        <div class="card-title"><span class="icon">📋</span>My Subject List</div>
        <%
            Connection con2 = null;
            try {
                con2 = getConnection();
                PreparedStatement ps2 = con2.prepareStatement(
                    "SELECT * FROM Subjects WHERE user_id=? ORDER BY subject_id DESC");
                ps2.setInt(1, userId);
                ResultSet rs2 = ps2.executeQuery();
                boolean found = false;
                while (rs2.next()) {
                    found = true;
                    String examDt = rs2.getDate("exam_date") != null
                        ? rs2.getDate("exam_date").toString() : "Not set";
        %>
        <div class="subject-item">
            <div style="display:flex;justify-content:space-between;align-items:center;">
                <div>
                    <strong><%= rs2.getString("subject_name") %></strong>
                    <div style="font-size:0.82rem;color:#718096;margin-top:3px;">
                        Exam: <%= examDt %> &nbsp;|&nbsp; Marks: <%= rs2.getInt("total_marks") %>
                    </div>
                </div>
                <a href="subjects.jsp?delete=<%= rs2.getInt("subject_id") %>"
                   class="btn btn-danger btn-sm"
                   onclick="return confirm('Delete this subject?')">Delete</a>
            </div>
        </div>
        <%  }
            if (!found) { %>
                <div class="alert alert-info">No subjects added yet. Add your first subject!</div>
        <%  }
            } catch(Exception e) {
                out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
            } finally { if(con2!=null) try{con2.close();}catch(Exception ignored){} }
        %>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>
