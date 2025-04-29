<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>

<%
request.setCharacterEncoding("UTF-8");

String itemId = request.getParameter("itemId");
String specId = request.getParameter("specId");
String quantity = request.getParameter("quantity");

Connection con = null;
PreparedStatement stmt = null;
try {
    Class.forName("com.mysql.jdbc.Driver");
    String url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
    con = DriverManager.getConnection(url, "root", "1234");
    String sql = "UPDATE Cart SET quantity = ? WHERE memberId = ? AND itemId = ? AND specId = ?";
    stmt = con.prepareStatement(sql);
    stmt.setString(1, quantity);
    stmt.setInt(2, (int) session.getAttribute("userID"));
    stmt.setString(3, itemId);
    stmt.setString(4, specId);
    stmt.executeUpdate();
} catch (ClassNotFoundException | SQLException e) {
    e.printStackTrace();
} finally {
    try {
        if (stmt != null) stmt.close();
        if (con != null) con.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>
