<%-- admin/manage_users.jsp - View & Delete Users --%>
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
            PreparedStatement ps = con.prepareStatement("DELETE FROM Users4 WHERE user_id=?");
            ps.setInt(1, delId); ps.executeUpdate();
            msg = "User deleted successfully."; msgType = "warning";
        } catch(Exception e) {
            msg = "Error: "+e.getMessage(); msgType = "danger";
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }

    // Search filter
    String search = request.getParameter("search");
    if (search == null) search = "";
%>

<h1 class="page-title">👨‍🎓 Manage Users</h1>
<% if(!msg.isEmpty()){ %><div class="alert alert-<%= msgType %>"><%= msg %></div><% } %>

<!-- Search -->
<div class="card">
    <form method="get" action="manage_users.jsp" style="display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;">
        <div class="form-group" style="margin:0;flex:1;min-width:200px;">
            <label>Search by Name or Email</label>
            <input type="text" name="search" class="form-control"
                   value="<%= search %>" placeholder="Type name or email...">
        </div>
        <button type="submit" class="btn btn-primary">🔍 Search</button>
        <a href="manage_users.jsp" class="btn btn-secondary">Reset</a>
    </form>
</div>

<!-- Users Table -->
<div class="card">
    <div class="card-title"><span class="icon">📋</span>All Registered Students</div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Level</th>
                    <th>Institution</th>
                    <th>Registered</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <%
                Connection con2 = null;
                int counter = 1;
                try {
                    con2 = getConnection();
                    String sql = "SELECT * FROM Users4";
                    if (!search.isEmpty()) sql += " WHERE LOWER(full_name) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?)";
                    sql += " ORDER BY created_at DESC";
                    PreparedStatement ps2 = con2.prepareStatement(sql);
                    if (!search.isEmpty()) {
                        ps2.setString(1, "%"+search+"%");
                        ps2.setString(2, "%"+search+"%");
                    }
                    ResultSet rs2 = ps2.executeQuery();
                    boolean found = false;
                    while(rs2.next()) {
                        found = true;
                        String lvl = rs2.getString("academic_level");
                        String lvlBadge = "University".equals(lvl)?"badge-primary":"HSC".equals(lvl)?"badge-warning":"badge-success";
            %>
                <tr>
                    <td><%= counter++ %></td>
                    <td><strong><%= rs2.getString("full_name") %></strong></td>
                    <td><%= rs2.getString("email") %></td>
                    <td><%= rs2.getString("phone") != null ? rs2.getString("phone") : "-" %></td>
                    <td><span class="badge <%= lvlBadge %>"><%= lvl %></span></td>
                    <td><%= rs2.getString("institution") != null ? rs2.getString("institution") : "-" %></td>
                    <td><%= rs2.getDate("created_at") %></td>
                    <td>
                        <a href="manage_users.jsp?delete=<%= rs2.getInt("user_id") %>"
                           class="btn btn-danger btn-sm"
                           onclick="return confirm('Delete this user and all their data?')">
                            🗑️ Delete
                        </a>
                    </td>
                </tr>
            <%      }
                    if (!found) {
            %><tr><td colspan="8" style="text-align:center;color:#718096;padding:20px;">
                No users found<% if(!search.isEmpty()){ %> matching "<%= search %>"<% } %>.
            </td></tr><%
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='8'>Error: "+e.getMessage()+"</td></tr>");
                } finally { if(con2!=null) try{con2.close();}catch(Exception ignored){} }
            %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>
