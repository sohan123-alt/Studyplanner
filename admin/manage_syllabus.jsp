<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<meta charset="UTF-8"><%@ page import="java.sql.*" %>
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
            PreparedStatement ps = con.prepareStatement("DELETE FROM Syllabus WHERE syllabus_id=?");
            ps.setInt(1, delId); ps.executeUpdate();
            msg = "Syllabus deleted."; msgType = "warning";
        } catch(Exception e) {
            msg = "Error: "+e.getMessage(); msgType = "danger";
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }

    // View full content
    String viewId = request.getParameter("view");
    String viewContent = null; String viewSubject = null;
    if (viewId != null) {
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT subject_name, content FROM Syllabus WHERE syllabus_id=?");
            ps.setInt(1, Integer.parseInt(viewId));
            ResultSet rs = ps.executeQuery();
            if(rs.next()) {
                viewSubject = rs.getString("subject_name");
                viewContent = rs.getString("content");
            }
        } catch(Exception e) {} finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }
%>

<h1 class="page-title">📄 Manage Syllabus</h1>
<% if(!msg.isEmpty()){ %><div class="alert alert-<%= msgType %>"><%= msg %></div><% } %>

<% if (viewContent != null) { %>
<!-- Content Viewer -->
<div class="card">
    <div class="card-title"><span class="icon">👁️</span>Syllabus Content: <%= viewSubject %></div>
    <pre style="background:#f7fafc;border:1px solid #e2e8f0;border-radius:8px;padding:16px;
                font-size:0.88rem;overflow-x:auto;white-space:pre-wrap;color:#2d3748;">
<%= viewContent.replace("<","&lt;").replace(">","&gt;") %></pre>
    <div style="margin-top:12px;">
        <a href="manage_syllabus.jsp" class="btn btn-secondary">← Back to List</a>
    </div>
</div>
<% } %>

<!-- Syllabuses Table -->
<div class="card">
    <div class="card-title"><span class="icon">📋</span>All Uploaded Syllabuses</div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr><th>#</th><th>Student</th><th>Subject</th><th>Preview</th><th>Uploaded</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <%
                Connection con2 = null; int counter = 1;
                try {
                    con2 = getConnection();
                    PreparedStatement ps2 = con2.prepareStatement(
                        "SELECT sy.syllabus_id, sy.subject_name, " +
                        "SUBSTR(sy.content,1,80) AS preview, sy.uploaded_at, u.full_name " +
                        "FROM Syllabus sy JOIN Users4 u ON sy.user_id=u.user_id " +
                        "ORDER BY sy.uploaded_at DESC");
                    ResultSet rs2 = ps2.executeQuery();
                    boolean found = false;
                    while(rs2.next()) {
                        found = true;
            %>
                <tr>
                    <td><%= counter++ %></td>
                    <td><%= rs2.getString("full_name") %></td>
                    <td><strong><%= rs2.getString("subject_name") %></strong></td>
                    <td style="font-size:0.82rem;color:#718096;">
                        <%= rs2.getString("preview") != null ? rs2.getString("preview")+"..." : "-" %>
                    </td>
                    <td><%= rs2.getDate("uploaded_at") %></td>
                    <td style="white-space:nowrap;">
                        <a href="manage_syllabus.jsp?view=<%= rs2.getInt("syllabus_id") %>"
                           class="btn btn-primary btn-sm">👁️ View</a>
                        <a href="manage_syllabus.jsp?delete=<%= rs2.getInt("syllabus_id") %>"
                           class="btn btn-danger btn-sm"
                           onclick="return confirm('Delete this syllabus?')">🗑️</a>
                    </td>
                </tr>
            <%      }
                    if (!found) {
            %><tr><td colspan="6" style="text-align:center;color:#718096;padding:16px;">No syllabus uploaded yet.</td></tr><%
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
