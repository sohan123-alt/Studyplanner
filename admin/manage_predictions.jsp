<%-- admin/manage_predictions.jsp - Full CRUD for Predictions --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<meta charset="UTF-8">
<%@ page import="java.sql.*" %>
<%@ include file="../includes/db.jsp" %>
<%@ include file="admin_header.jsp" %>
<%
    String msg = ""; String msgType = "";

    // ── DELETE ─────────────────────────────────────────────────
    if (request.getParameter("delete") != null) {
        int delId = Integer.parseInt(request.getParameter("delete"));
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement("DELETE FROM Predictions WHERE pred_id=?");
            ps.setInt(1, delId); ps.executeUpdate();
            msg = "Prediction deleted."; msgType = "warning";
        } catch(Exception e) { msg="Error: "+e.getMessage(); msgType="danger"; }
        finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }

    // ── LOAD for EDIT ──────────────────────────────────────────
    int editId = 0;
    String editSubject="", editChapter="", editQuestion="", editType="Short", editDiff="Medium";
    if (request.getParameter("edit") != null) {
        editId = Integer.parseInt(request.getParameter("edit"));
        Connection con = null;
        try {
            con = getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM Predictions WHERE pred_id=?");
            ps.setInt(1, editId); ResultSet rs = ps.executeQuery();
            if(rs.next()) {
                editSubject  = rs.getString("subject_name");
                editChapter  = rs.getString("chapter");
                editQuestion = rs.getString("question_text");
                editType     = rs.getString("question_type");
                editDiff     = rs.getString("difficulty");
            }
        } catch(Exception e) {} finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    }

    // ── ADD / UPDATE (POST) ────────────────────────────────────
    if ("POST".equals(request.getMethod())) {
        String action    = request.getParameter("form_action");
        String subjName  = request.getParameter("subject_name").trim();
        String chapter   = request.getParameter("chapter").trim();
        String question  = request.getParameter("question_text").trim();
        String qType     = request.getParameter("question_type");
        String diff      = request.getParameter("difficulty");
        int    pid       = 0;
        try { pid = Integer.parseInt(request.getParameter("pred_id")); } catch(Exception ignored){}

        if (subjName.isEmpty() || question.isEmpty()) {
            msg = "Subject and question are required."; msgType = "danger";
        } else {
            Connection con = null;
            try {
                con = getConnection();
                if ("update".equals(action) && pid > 0) {
                    PreparedStatement ps = con.prepareStatement(
                        "UPDATE Predictions SET subject_name=?,chapter=?,question_text=?,question_type=?,difficulty=? WHERE pred_id=?");
                    ps.setString(1, subjName); ps.setString(2, chapter);
                    ps.setString(3, question); ps.setString(4, qType);
                    ps.setString(5, diff);     ps.setInt(6, pid);
                    ps.executeUpdate();
                    msg = "Prediction updated!"; msgType = "success";
                    editId = 0; // close edit form
                } else {
                    PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO Predictions (subject_name, chapter, question_text, question_type, difficulty) VALUES(?,?,?,?,?)");
                    ps.setString(1, subjName); ps.setString(2, chapter);
                    ps.setString(3, question); ps.setString(4, qType);
                    ps.setString(5, diff); ps.executeUpdate();
                    msg = "Prediction added successfully!"; msgType = "success";
                }
            } catch(Exception e) { msg="Error: "+e.getMessage(); msgType="danger"; }
            finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
        }
    }

    // Filter
    String filterSubj = request.getParameter("filterSubj");
    if (filterSubj == null) filterSubj = "";
%>

<h1 class="page-title">❓ Manage Predictions</h1>
<% if(!msg.isEmpty()){ %><div class="alert alert-<%= msgType %>"><%= msg %></div><% } %>

<div class="grid-2">
    <!-- Add / Edit Form -->
    <div class="card">
        <div class="card-title">
            <span class="icon"><%= editId>0?"✏️":"➕" %></span>
            <%= editId>0 ? "Edit Prediction" : "Add New Prediction" %>
        </div>
        <form method="post" action="manage_predictions.jsp">
            <input type="hidden" name="form_action" value="<%= editId>0?"update":"add" %>">
            <input type="hidden" name="pred_id"    value="<%= editId %>">

            <div class="form-group">
                <label>Subject Name *</label>
                <input type="text" name="subject_name" class="form-control"
                       value="<%= editSubject %>" placeholder="e.g. Physics" required>
            </div>
            <div class="form-group">
                <label>Chapter</label>
                <input type="text" name="chapter" class="form-control"
                       value="<%= editChapter %>" placeholder="e.g. Chapter 1 - Motion">
            </div>
            <div class="form-group">
                <label>Question Text *</label>
                <textarea name="question_text" class="form-control" rows="4"
                          placeholder="Type the predicted question here..." required><%= editQuestion %></textarea>
            </div>
            <div class="grid-2" style="gap:10px;">
                <div class="form-group">
                    <label>Question Type</label>
                    <select name="question_type" class="form-control">
                        <option value="Short"    <%= "Short".equals(editType)    ?"selected":"" %>>Short</option>
                        <option value="Creative" <%= "Creative".equals(editType) ?"selected":"" %>>Creative</option>
                        <option value="MCQ"      <%= "MCQ".equals(editType)      ?"selected":"" %>>MCQ</option>
                        <option value="Problem"  <%= "Problem".equals(editType)  ?"selected":"" %>>Problem</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Difficulty</label>
                    <select name="difficulty" class="form-control">
                        <option value="Easy"   <%= "Easy".equals(editDiff)   ?"selected":"" %>>Easy</option>
                        <option value="Medium" <%= "Medium".equals(editDiff) ?"selected":"" %>>Medium</option>
                        <option value="Hard"   <%= "Hard".equals(editDiff)   ?"selected":"" %>>Hard</option>
                    </select>
                </div>
            </div>
            <div style="display:flex;gap:8px;">
                <button type="submit" class="btn btn-primary" style="flex:1;">
                    <%= editId>0?"💾 Update":"➕ Add Prediction" %>
                </button>
                <% if(editId>0){ %>
                <a href="manage_predictions.jsp" class="btn btn-secondary">Cancel</a>
                <% } %>
            </div>
        </form>
    </div>

    <!-- Filter + Stats -->
    <div class="card">
        <div class="card-title"><span class="icon">🔍</span>Filter & Stats</div>
        <form method="get" action="manage_predictions.jsp" style="margin-bottom:16px;">
            <div class="form-group">
                <label>Filter by Subject</label>
                <input type="text" name="filterSubj" class="form-control"
                       value="<%= filterSubj %>" placeholder="Subject name...">
            </div>
            <div style="display:flex;gap:8px;">
                <button type="submit" class="btn btn-primary" style="flex:1;">Filter</button>
                <a href="manage_predictions.jsp" class="btn btn-secondary">Reset</a>
            </div>
        </form>
        <hr style="border:none;border-top:1px solid #e2e8f0;margin:12px 0;">
        <!-- Stats by subject -->
        <div style="font-weight:600;color:#4a5568;margin-bottom:8px;font-size:0.88rem;">Questions Per Subject:</div>
        <%
            Connection conSt = null;
            try {
                conSt = getConnection();
                PreparedStatement psSt = conSt.prepareStatement(
                    "SELECT subject_name, COUNT(*) AS cnt FROM Predictions GROUP BY subject_name ORDER BY cnt DESC");
                ResultSet rsSt = psSt.executeQuery();
                boolean any = false;
                while(rsSt.next()) {
                    any = true;
        %>
        <div style="display:flex;justify-content:space-between;padding:5px 0;border-bottom:1px solid #f0f0f0;font-size:0.88rem;">
            <span><%= rsSt.getString("subject_name") %></span>
            <span class="badge badge-primary"><%= rsSt.getInt("cnt") %> Q</span>
        </div>
        <%  }
            if (!any) { %><div style="color:#718096;font-size:0.85rem;">No predictions yet.</div><% }
            } catch(Exception e) { out.println("<div style='color:red;font-size:0.82rem;'>Error: "+e.getMessage()+"</div>"); }
            finally { if(conSt!=null) try{conSt.close();}catch(Exception ignored){} }
        %>
    </div>
</div>

<!-- Predictions Table -->
<div class="card">
    <div class="card-title"><span class="icon">📋</span>
        All Predictions
        <% if(!filterSubj.isEmpty()){ %>
            <span class="badge badge-primary" style="margin-left:8px;">Filter: <%= filterSubj %></span>
        <% } %>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr><th>#</th><th>Subject</th><th>Chapter</th><th>Question</th><th>Type</th><th>Difficulty</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <%
                Connection con3 = null; int counter = 1;
                try {
                    con3 = getConnection();
                    String sql3 = "SELECT * FROM Predictions";
                    if (!filterSubj.isEmpty()) sql3 += " WHERE LOWER(subject_name) LIKE LOWER(?)";
                    sql3 += " ORDER BY subject_name, chapter, pred_id";
                    PreparedStatement ps3 = con3.prepareStatement(sql3);
                    if (!filterSubj.isEmpty()) ps3.setString(1, "%"+filterSubj+"%");
                    ResultSet rs3 = ps3.executeQuery();
                    boolean found = false;
                    while(rs3.next()) {
                        found = true;
                        String diff  = rs3.getString("difficulty");
                        String type  = rs3.getString("question_type");
                        String dBadge = "Hard".equals(diff)?"badge-danger":"Medium".equals(diff)?"badge-warning":"badge-success";
                        String tBadge = "Creative".equals(type)?"badge-primary":"MCQ".equals(type)?"badge-info":"badge-primary";
                        String qText = rs3.getString("question_text");
                        String qPreview = qText != null && qText.length()>80 ? qText.substring(0,80)+"..." : qText;
            %>
                <tr>
                    <td><%= counter++ %></td>
                    <td><strong><%= rs3.getString("subject_name") %></strong></td>
                    <td style="font-size:0.82rem;color:#718096;"><%= rs3.getString("chapter") %></td>
                    <td style="font-size:0.85rem;" title="<%= qText != null ? qText.replace("\"","'") : "" %>">
                        <%= qPreview %>
                    </td>
                    <td><span class="badge badge-info"><%= type %></span></td>
                    <td><span class="badge <%= dBadge %>"><%= diff %></span></td>
                    <td style="white-space:nowrap;">
                        <a href="manage_predictions.jsp?edit=<%= rs3.getInt("pred_id") %>"
                           class="btn btn-warning btn-sm">✏️ Edit</a>
                        <a href="manage_predictions.jsp?delete=<%= rs3.getInt("pred_id") %>"
                           class="btn btn-danger btn-sm"
                           onclick="return confirm('Delete this prediction?')">🗑️</a>
                    </td>
                </tr>
            <%      }
                    if (!found) {
            %><tr><td colspan="7" style="text-align:center;color:#718096;padding:20px;">
                No predictions found<% if(!filterSubj.isEmpty()){ %> for "<%= filterSubj %>"<% } %>.
            </td></tr><%
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='7'>Error: "+e.getMessage()+"</td></tr>");
                } finally { if(con3!=null) try{con3.close();}catch(Exception ignored){} }
            %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>
