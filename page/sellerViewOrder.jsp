<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>

<%
request.setCharacterEncoding("UTF-8");
HttpSession session1 = request.getSession();
if (session1.getAttribute("userID") == null) {
    response.sendRedirect("logIn.jsp"); 
    return;
}

Connection con = null;
PreparedStatement psOrder = null;
PreparedStatement psDetails = null;
PreparedStatement psUser = null;
ResultSet rsOrder = null;
ResultSet rsDetails = null;
ResultSet rsUser = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    String url = "jdbc:mysql://localhost:3306/final?serverTimezone=UTC&characterEncoding=UTF-8";
    con = DriverManager.getConnection(url, "root", "1234");
    
    // 查詢所有訂單
    String queryOrder = "SELECT * FROM `Order`";
    psOrder = con.prepareStatement(queryOrder);
    rsOrder = psOrder.executeQuery();
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>訂單查詢</title>
    
</head>
<body>
    <h2>所有用戶的訂單</h2>
    <%
        while (rsOrder.next()) {
            int orderId = rsOrder.getInt("orderId");
            int memberId = rsOrder.getInt("memberId");

            // 查詢訂單對應的用戶信息
            String queryUser = "SELECT memberName, email, phoneNumber, address FROM Member WHERE memberId = ?";
            psUser = con.prepareStatement(queryUser);
            psUser.setInt(1, memberId);
            rsUser = psUser.executeQuery();

            String memberName = "";
            String email = "";
            String phoneNumber = "";
            String address = "";

            if (rsUser.next()) {
                memberName = rsUser.getString("memberName");
                email = rsUser.getString("email");
                phoneNumber = rsUser.getString("phoneNumber");
                address = rsUser.getString("address");
            }
    %>
    <div>
        <p>訂單ID: <%= orderId %><br>
        用戶名: <%= memberName %><br>
        Email: <%= email %><br>
        電話號碼: <%= phoneNumber %><br>
        地址: <%= address %><br>
        訂單日期:<%= rsOrder.getDate("orderDate") %><br>
        付款方式:<%= rsOrder.getString("paymentMethod") %><br>
        付款狀態:<%= rsOrder.getString("paymentStatus") %><br>
        總價格:<%= rsOrder.getBigDecimal("totalPrice") %><br>
        訂單狀態:<%= rsOrder.getString("orderStatus") %><br>
        備註:<%= rsOrder.getString("notes") %></p>
        <table border=1>
            <tr>
                <th>商品ID</th>
                <th>商品名稱</th>
				<th>規格</th>
                <th>價格</th>
                <th>數量</th>
            </tr>
            <%
            // 查詢當前訂單的詳細信息
            String queryDetails = "SELECT s.specName,s.specId,od.itemId, i.itemName, i.price, od.quantity FROM OrderDetails od JOIN Spec s ON od.itemId = s.itemId AND od.specId = s.specId JOIN Item i ON od.itemId = i.itemId WHERE od.orderId = ?";
            psDetails = con.prepareStatement(queryDetails);
            psDetails.setInt(1, orderId);
            rsDetails = psDetails.executeQuery();

            while (rsDetails.next()) {
            %>
            <tr>
                <td><%= rsDetails.getInt("itemId") %></td>
                <td><%= rsDetails.getString("itemName") %></td>
				<td><%= rsDetails.getString("specName") %></td>
                <td><%= rsDetails.getBigDecimal("price") %></td>
                <td><%= rsDetails.getInt("quantity") %></td>
            </tr>
            <%
            }
            rsDetails.close();
            psDetails.close();
            rsUser.close();
            psUser.close();
            %>
        </table>
    </div>
    <%
    }
    %>

    <p><a href="backStage.jsp">返回商家後台</a></p>
</body>
</html>

<%
} catch (Exception e) {
    e.printStackTrace();
    out.println("<p>錯誤: " + e.getMessage() + "</p>");
} finally {
    try {
        if (rsOrder != null) rsOrder.close();
        if (psOrder != null) psOrder.close();
        if (con != null) con.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>
