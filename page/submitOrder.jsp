<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%
request.setCharacterEncoding("UTF-8");
HttpSession session1 = request.getSession();
if (session1.getAttribute("userID") == null) {
    response.sendRedirect("logIn.jsp"); 
    return;
}

String url = null;
int memberId = (int) session1.getAttribute("userID");
String memberName = "";
String address = "";
String phoneNumber = "";
String email = "";
String creditCard = "";
boolean insufficientStock = false;
Connection con = null;
PreparedStatement stmt = null;
ResultSet rs = null;

// 獲取會員資料
try {
    Class.forName("com.mysql.jdbc.Driver");
    url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
    con = DriverManager.getConnection(url, "root", "1234");
    if (!con.isClosed()) {
        String sql = "SELECT memberName, address, phoneNumber, email, creditCard FROM Member WHERE memberId = ?";
        stmt = con.prepareStatement(sql);
        stmt.setInt(1, memberId);
        rs = stmt.executeQuery();
        if (rs.next()) {
            memberName = rs.getString("memberName");
            address = rs.getString("address");
            phoneNumber = rs.getString("phoneNumber");
            email = rs.getString("email");
            creditCard = rs.getString("creditCard");
        }
    }

    if (!con.isClosed()) {
        String sql = "SELECT Cart.itemId, Cart.quantity, Item.inventoryQuantity AS stock FROM Cart INNER JOIN Item ON Cart.itemId = Item.itemId WHERE Cart.memberId = ?";
        stmt = con.prepareStatement(sql);
        stmt.setInt(1, memberId);
        rs = stmt.executeQuery();
        while (rs.next()) {
            int cartQuantity = rs.getInt("quantity");
            int stockQuantity = rs.getInt("stock");
            if (cartQuantity > stockQuantity) {
                insufficientStock = true;
                stmt = con.prepareStatement("UPDATE Cart SET quantity = ? WHERE memberId = ? AND itemId = ?");
                stmt.setInt(1, stockQuantity);
                stmt.setInt(2, memberId);
                stmt.setInt(3, rs.getInt("itemId"));
                stmt.executeUpdate();
            }
        }
    }
} catch (ClassNotFoundException | SQLException e) {
    e.printStackTrace();
} finally {
    try {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (con != null) con.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}

if (insufficientStock) {
    session1.setAttribute("insufficientStock", true);
    response.sendRedirect("cart.jsp");
    return;
}

String maskedCreditCard = "";
if (creditCard != null && creditCard.length() > 4) {
    maskedCreditCard = "**** **** **** " + creditCard.substring(creditCard.length() - 4);
}

// 獲取付款方式
String paymentMethod = request.getParameter("paymentMethod");

// 獲取購物車中的商品列表和總價
List<Map<String, String>> cartItems = new ArrayList<>();
double totalPrice = 0.0;
try {
    Class.forName("com.mysql.jdbc.Driver");
    con = DriverManager.getConnection(url, "root", "1234");
    if (!con.isClosed()) {
        String sql = "SELECT Item.itemId, Item.itemName, Item.price, Cart.quantity FROM Item INNER JOIN Cart ON Item.itemId = Cart.itemId WHERE Cart.memberId = ?";
        stmt = con.prepareStatement(sql);
        stmt.setInt(1, memberId);
        rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, String> item = new HashMap<>();
            item.put("itemId", rs.getString("itemId"));
            item.put("itemName", rs.getString("itemName"));
            item.put("price", rs.getString("price"));
            item.put("quantity", rs.getString("quantity"));
            cartItems.add(item);
            double itemPrice = Double.parseDouble(rs.getString("price"));
            int itemQuantity = Integer.parseInt(rs.getString("quantity"));
            totalPrice += itemPrice * itemQuantity;
        }
    }
} catch (ClassNotFoundException | SQLException e) {
    e.printStackTrace();
} finally {
    try {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (con != null) con.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}

// 如果購物車為空，顯示警告訊息並返回購物車頁面
if (cartItems.isEmpty()) {
%>
<script>
    alert("購物車為空，請先選購商品！");
    window.location.href = "cart.jsp";
</script>
<%
} else {
    // 如果購物車不為空，則執行提交訂單的動作
    // 這裡放置您的提交訂單的代碼
    // 如果提交訂單成功，則顯示訂單已送出的警告訊息
    int orderId = 0; // 初始化訂單編號
    try {
        // 插入訂單數據
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection(url, "root", "1234");
        if (!con.isClosed()) {
            String insertOrderQuery = "INSERT INTO `Order` (memberId, orderDate, paymentMethod, address, totalPrice) VALUES (?, NOW(), ?, ?, ?)";
            PreparedStatement insertOrderStmt = con.prepareStatement(insertOrderQuery, Statement.RETURN_GENERATED_KEYS);
            insertOrderStmt.setInt(1, memberId);
            insertOrderStmt.setString(2, paymentMethod);
            insertOrderStmt.setString(3, address);
            insertOrderStmt.setDouble(4, totalPrice);
            insertOrderStmt.executeUpdate();

            ResultSet generatedKeys = insertOrderStmt.getGeneratedKeys();
            if (generatedKeys.next()) {
                orderId = generatedKeys.getInt(1); // 獲取插入的訂單編號
            }

            for (Map<String, String> item : cartItems) {
                int itemId = Integer.parseInt(item.get("itemId"));
                int quantity = Integer.parseInt(item.get("quantity"));
                String insertOrderDetailsQuery = "INSERT INTO OrderDetails (orderId, itemId, quantity) VALUES (?, ?, ?)";
                PreparedStatement insertOrderDetailsStmt = con.prepareStatement(insertOrderDetailsQuery);
                insertOrderDetailsStmt.setInt(1, orderId); // 使用訂單編號
                insertOrderDetailsStmt.setInt(2, itemId);
                insertOrderDetailsStmt.setInt(3, quantity);
                insertOrderDetailsStmt.executeUpdate();
            }

            // 清空購物車
            stmt = con.prepareStatement("DELETE FROM Cart WHERE memberId = ?");
            stmt.setInt(1, memberId);
            stmt.executeUpdate();
        }
%>
<script>
    alert("訂單已送出！訂單編號：<%= orderId %>");
    window.location.href = "user.jsp"; // 重定向到用戶頁面或其他目標頁面
</script>
<%
    } catch (ClassNotFoundException | SQLException e) {
        e.printStackTrace();
%>
<script>
    alert("提交訂單時發生錯誤，請稍後再試！");
    window.location.href = "cart.jsp"; // 返回購物車頁面
</script>
<%
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
%>
