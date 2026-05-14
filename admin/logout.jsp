<%-- admin/logout.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<meta charset="UTF-8"><%
    session.invalidate();
    response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
%>
