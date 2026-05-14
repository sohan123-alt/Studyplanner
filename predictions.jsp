<%-- predictions.jsp - Exam Question Predictions --%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="includes/db.jsp" %>
<%@ include file="includes/header.jsp" %>
<%
    int userId = (Integer) session.getAttribute("user_id");
    String filterSubject = request.getParameter("subject");
    if (filterSubject == null) filterSubject = "";
%>

<h1 class="page-title">❓ Exam Question Predictions</h1>
<div class="alert alert-warning">
    <strong>Note:</strong> These questions are predicted based on historical board exam patterns.
    Use them as a revision guide — not a guarantee of actual exam content.
</div>

<!-- Filter Form -->
<div class="card">
    <form method="get" action="predictions.jsp" style="display:flex;gap:12px;flex-wrap:wrap;align-items:flex-end;">
        <div class="form-group" style="margin:0;flex:1;min-width:200px;">
            <label>Filter by Subject</label>
            <input type="text" name="subject" class="form-control"
                   value="<%= filterSubject %>" placeholder="e.g. Physics, Mathematics">
        </div>
        <button type="submit" class="btn btn-primary">🔍 Search</button>
        <a href="predictions.jsp" class="btn btn-secondary">Show All</a>
    </form>
</div>

<!-- Predictions List -->
<div class="card">
    <div class="card-title"><span class="icon">📋</span>
        Predicted Questions
        <% if(!filterSubject.isEmpty()){ %>
            &nbsp;<span class="badge badge-primary">Subject: <%= filterSubject %></span>
        <% } %>
    </div>
    <%
        Connection con = null;
        int qnum = 1;
        try {
            con = getConnection();
            String sql = "SELECT * FROM Predictions";
            if (!filterSubject.isEmpty()) sql += " WHERE LOWER(subject_name) LIKE LOWER(?)";
            sql += " ORDER BY subject_name, chapter";
            PreparedStatement ps = con.prepareStatement(sql);
            if (!filterSubject.isEmpty()) ps.setString(1, "%" + filterSubject + "%");
            ResultSet rs = ps.executeQuery();
            boolean found = false;
            String lastSubject = "";
            while(rs.next()) {
                found = true;
                String subj = rs.getString("subject_name");
                if (!subj.equals(lastSubject)) {
                    if (!lastSubject.isEmpty()) out.println("<br>");
                    out.println("<h3 style='color:#1a56a0;margin:16px 0 8px;font-size:1rem;'>📚 " + subj + "</h3>");
                    lastSubject = subj;
                }
                String diff = rs.getString("difficulty");
                String diffBadge = "Hard".equals(diff)?"badge-danger":"Medium".equals(diff)?"badge-warning":"badge-success";
                String type = rs.getString("question_type");
    %>
    <div class="q-card">
        <div>
            <span class="q-num">Q<%= qnum++ %>.</span>
            <%= rs.getString("question_text") %>
        </div>
        <div class="q-meta">
            📂 <strong>Chapter:</strong> <%= rs.getString("chapter") %>
            &nbsp;|&nbsp;
            📌 <span class="badge badge-info"><%= type %></span>
            &nbsp;
            <span class="badge <%= diffBadge %>"><%= diff %></span>
        </div>
    </div>
    <%  }
        if (!found) { %>
        <div class="alert alert-info">
            No predictions found
            <% if(!filterSubject.isEmpty()){ %> for "<%= filterSubject %>"<% } %>.
            <% if(!filterSubject.isEmpty()){ %><a href="predictions.jsp">Show all predictions</a><% } %>
        </div>
    <%  }
    } catch(Exception e) {
        out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
    } finally { if(con!=null) try{con.close();}catch(Exception ignored){} }
    %>
</div>

<!-- Quick Tip -->
<div class="card">
    <div class="card-title"><span class="icon">💡</span>How to Use Predictions</div>
    <div class="subject-item">
        ✅ <strong>Practice</strong> each predicted question by writing full answers.
    </div>
    <div class="subject-item strong">
        ✅ <strong>Focus on "Hard"</strong> difficulty questions 2–3 weeks before the exam.
    </div>
    <div class="subject-item average">
        ✅ <strong>Revise "Medium"</strong> questions during the last week.
    </div>
    <div class="subject-item">
        ✅ <strong>Quick-check "Easy"</strong> questions the day before.
    </div>
</div>

<%@ include file="includes/footer.jsp" %>
