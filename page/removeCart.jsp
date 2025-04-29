<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>

<%
request.setCharacterEncoding("UTF-8");

// 获取请求参数
String itemId = request.getParameter("itemId");
String specId = request.getParameter("specId");

// 从购物车中移除指定的商品
Connection con = null;
PreparedStatement stmt = null;
try {
    Class.forName("com.mysql.jdbc.Driver");
    String url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
    con = DriverManager.getConnection(url, "root", "1234");
    String sql = "DELETE FROM Cart WHERE memberId = ? AND itemId = ? AND specId = ?";
    stmt = con.prepareStatement(sql);
    stmt.setInt(1, (int) session.getAttribute("userID"));
    stmt.setString(2, itemId);
    stmt.setString(3, specId);
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
