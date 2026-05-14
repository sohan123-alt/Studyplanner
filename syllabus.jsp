<%-- syllabus.jsp - Upload Syllabus Content --%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="includes/db.jsp" %>
<%@ include file="includes/header.jsp" %>
<%
    int userId = (Integer) session.getAttribute("user_id");
    String msg = ""; String msgType = "";

    if ("POST".equals(request.getMethod())) {
        String subjectName = request.getParameter("subject_name").trim();
        String content     = request.getParameter("content").trim();
        String subjectId   = request.getParameter("subject_id");
        Connection con = null;
        try {
            con = getConnection();
            // Check if syllabus exists for this subject
            PreparedStatement chk = con.prepareStatement(
                "SELECT syllabus_id FROM Syllabus WHERE user_id=? AND subject_name=?");
            chk.setInt(1, userId); chk.setString(2, subjectName);
            ResultSet rs = chk.executeQuery();
            if (rs.next()) {
                // Update
                PreparedStatement upd = con.prepareStatement(
                    "UPDATE Syllabus SET content=?, uploaded_at=SYSDATE WHERE syllabus_id=?");
                upd.setString(1, content);
                upd.setInt(2, rs.getInt("syllabus_id"));
                upd.executeUpdate();
                msg = "Syllabus updated!"; msgType = "success";
            } else {
                // Insert
                PreparedStatement ins = con.prepareStatement(
                    "INSERT INTO Syllabus (user_id, subject_name, content) VALUES(?,?,?)");
                ins.setInt(1, userId); ins.setString(2, subjectName); ins.setString(3, content);
                ins.executeUpdate();
                msg = "Syllabus saved successfully!"; msgType = "success";
            }
        } catch(Exception e) {
            msg = "Error: "+e.getMessage(); msgType = "danger";
        } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }
%>

<h1 class="page-title">📄 Upload Syllabus</h1>

<% if(!msg.isEmpty()){ %><div class="alert alert-<%= msgType %>"><%= msg %></div><% } %>

<div class="grid-2">
    <div class="card">
        <div class="card-title"><span class="icon">📝</span>Enter Syllabus Content</div>
        <form method="post" action="syllabus.jsp">
            <div class="form-group">
                <label>Select Subject</label>
                <select name="subject_name" class="form-control" required>
                    <option value="">-- Choose Subject --</option>
                    <%
                        Connection con3 = null;
                        try {
                            con3 = getConnection();
                            PreparedStatement ps3 = con3.prepareStatement(
                                "SELECT subject_id, subject_name FROM Subjects WHERE user_id=? ORDER BY subject_name");
                            ps3.setInt(1, userId);
                            ResultSet rs3 = ps3.executeQuery();
                            while (rs3.next()) {
                    %>
                    <option value="<%= rs3.getString("subject_name") %>">
                        <%= rs3.getString("subject_name") %>
                    </option>
                    <%      }
                        } catch(Exception e) { out.println("<option>Error loading</option>"); }
                        finally { if(con3!=null) try{con3.close();}catch(Exception ignored){} }
                    %>
                </select>
            </div>
            <div class="form-group">
                <label>Syllabus Content (paste chapters and topics)</label>
                <textarea name="content" class="form-control" rows="10"
                    placeholder="Example:&#10;Chapter 1: Motion&#10;- Distance, Displacement&#10;- Speed, Velocity&#10;- Acceleration&#10;&#10;Chapter 2: Force&#10;- Newton's Laws&#10;- Friction&#10;..."></textarea>
            </div>
            <button type="submit" class="btn btn-primary btn-block">💾 Save Syllabus</button>
        </form>
    </div>

    <!-- Saved Syllabuses -->
    <div class="card">
        <div class="card-title"><span class="icon">📚</span>Saved Syllabuses</div>
        <%
            Connection con4 = null;
            try {
                con4 = getConnection();
                PreparedStatement ps4 = con4.prepareStatement(
                    "SELECT subject_name, SUBSTR(content,1,150) AS preview, uploaded_at FROM Syllabus WHERE user_id=? ORDER BY uploaded_at DESC");
                ps4.setInt(1, userId);
                ResultSet rs4 = ps4.executeQuery();
                boolean found = false;
                while(rs4.next()) {
                    found = true;
        %>
        <div class="subject-item">
            <strong><%= rs4.getString("subject_name") %></strong>
            <div style="font-size:0.82rem;color:#718096;margin-top:4px;">
                <%= rs4.getString("preview") %>...
            </div>
            <div style="font-size:0.78rem;color:#a0aec0;margin-top:4px;">
                Uploaded: <%= rs4.getTimestamp("uploaded_at") %>
            </div>
        </div>
        <%  }
            if (!found) { %><div class="alert alert-info">No syllabus uploaded yet.</div><% }
            } catch(Exception e) {
                out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
            } finally { if(con4!=null) try{con4.close();}catch(Exception ignored){} }
        %>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>
