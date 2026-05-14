<%-- 
    db.jsp - Oracle Database Connection
    Include this file in every JSP that needs DB access
    Usage: <%@ include file="/includes/db.jsp" %>
--%>
<%@ page import="java.sql.*" %>
<%!
    // ─── Oracle DB Configuration ───────────────────────────────
    // Change these values to match your Oracle installation
    static final String DB_URL      = "jdbc:oracle:thin:@localhost:1521:XE";
    // For Oracle 19c+ with service name use:
    // static final String DB_URL   = "jdbc:oracle:thin:@localhost:1521/XEPDB1";
    static final String DB_USER     = "system";   // e.g. "system" or "studyplanner"
    static final String DB_PASS     = "sohan1";   // your Oracle password

    // ─── Get Connection ────────────────────────────────────────
    public static Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
%>
