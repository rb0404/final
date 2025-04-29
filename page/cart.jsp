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

// 获取请求参数
String itemId = request.getParameter("itemId");
String specId = request.getParameter("specId");
String quantity = request.getParameter("quantity");

// 更新购物车中的商品数量
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
String paymentMethod = request.getParameter("paymentMethod");
String url = null;
int memberId = (int) session1.getAttribute("userID");
String memberName = "";
String address = "";
String phoneNumber = "";
String email = "";
String creditCard = "";
String sql = "";
boolean insufficientStock = false;
ResultSet rs = null;
String maskedCreditCard = "";
if (creditCard != null && creditCard.length() > 4) {
    maskedCreditCard = "**** **** **** " + creditCard.substring(creditCard.length() - 4);
}
// 獲取類型
Class.forName("com.mysql.jdbc.Driver");
url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
con = DriverManager.getConnection(url, "root", "1234");
sql = "SELECT typeId, typeName FROM Type";
stmt = con.prepareStatement(sql);
rs = stmt.executeQuery();
List<Map<String, String>> typeList = new ArrayList<>();
while (rs.next()) {
	Map<String, String> type = new HashMap<>();
	type.put("typeId", rs.getString("typeId"));
	type.put("typeName", rs.getString("typeName"));
	typeList.add(type);
}
List<Map<String, String>> cartItems = new ArrayList<>();
double totalPrice = 0.0;
try {
    Class.forName("com.mysql.jdbc.Driver");
    
    con = DriverManager.getConnection(url, "root", "1234");
    if (!con.isClosed()) {
        sql = "SELECT s.specName, s.specId, c.itemId, i.itemName,i.typeId, i.price, c.quantity " +
			"FROM Cart c " +
			"JOIN Spec s ON c.itemId = s.itemId AND c.specId = s.specId " +
			"JOIN Item i ON c.itemId = i.itemId " +
			"WHERE c.memberId = ?";
        stmt = con.prepareStatement(sql);
        stmt.setInt(1, memberId);
        rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, String> item = new HashMap<>();
            item.put("itemId", rs.getString("itemId"));
            item.put("itemName", rs.getString("itemName"));
            item.put("price", rs.getString("price"));
            item.put("quantity", rs.getString("quantity"));
            item.put("specId", rs.getString("specId"));
            item.put("specName", rs.getString("specName"));
            item.put("typeId", rs.getString("typeId"));
            cartItems.add(item);
            double itemPrice = Double.parseDouble(rs.getString("price"));
            int itemQuantity = Integer.parseInt(rs.getString("quantity"));
            totalPrice += itemPrice * itemQuantity;
        }
    }
    Class.forName("com.mysql.jdbc.Driver");
    url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
    con = DriverManager.getConnection(url, "root", "1234");
    if (!con.isClosed()) {
        sql = "SELECT memberName, address, phoneNumber, email, creditCard FROM Member WHERE memberId = ?";
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
        sql = "SELECT Cart.itemId, Cart.quantity, Item.inventoryQuantity AS stock FROM Cart INNER JOIN Item ON Cart.itemId = Item.itemId WHERE Cart.memberId = ?";
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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>購物車</title>
    <link rel="stylesheet" href="../assets/css/hf.css">
    <link rel="stylesheet" href="../assets/css/cart.css">
</head>
<body>
    <header>
        <div class="flex">
            <h1 class="title"><a href="top.jsp">Maisie</a></h1>
            <div class="flex1">
                <div class="box">
					<div class="inner-box">
						<img class="search" src="../assets/img/search.png" alt="Search" onclick="performSearch()">
						<input type="text" id="searchQuery" name="searchQuery" placeholder="Search..." class="input">
					</div>
				</div>
                <div class="dropdown">
                    <h3 class="sub"><a href="store.jsp?typeId=all" class="item">商品分類</a></h3>
                    <div class="dropdown-content">
                        <a href="store.jsp?typeId=all">All Produces</a>
                        <% for (Map<String, String> type : typeList) { %>
                            <a href="store.jsp?typeId=<%= type.get("typeId") %>"><%= type.get("typeName") %></a>
                        <% } %>
                    </div>
                </div>
                <h3 class="sub"><a href="cart.jsp" class="item">購物車</a></h3>
                <a href="user.jsp"><button class="btn">會員中心</button></a>
            </div>
        </div>
    </header>
    <main>
	
        <div class="box">
			<!-- 將購物車中的商品列表作為表單字段傳遞 -->
			<% for (Map<String, String> item : cartItems) { %>
				<input type="hidden" name="itemId" value="<%= item.get("itemId") %>">
				<input type="hidden" name="itemName" value="<%= item.get("itemName") %>">
				<input type="hidden" name="price" value="<%= item.get("price") %>">
				<input type="hidden" name="quantity" value="<%= item.get("quantity") %>">
				<input type="hidden" name="specId" value="<%= item.get("specId") %>"> <!-- 添加specId -->
			<% } %>
			<input type="hidden" name="memberId" value="<%= memberId %>">
			<input type="hidden" name="memberName" value="<%= memberName %>">
			<input type="hidden" name="address" value="<%= address %>">
			<input type="hidden" name="phoneNumber" value="<%= phoneNumber %>">
			<input type="hidden" name="email" value="<%= email %>">
				<div class="row">
					<img src="../assets/img/cart.png" alt="cart">
					<h2>購物車</h2>
				</div>
				<div class="cart-container" id="cart-container">
					<% for (Map<String, String> item : cartItems) { %>
					<div class="cart-item">
						<img id="productImage" src="../assets/img/<%= item.get("typeId") %>/<%= item.get("itemId") %>_<%= item.get("specId") %>.PNG">
						<span class="item-name"><%= item.get("itemName") %></span>
						<span class="item-price">NT$<%= item.get("price") %></span>
						<input type="number" class="item-quantity" value="<%= item.get("quantity") %>" min="1" onchange="updateCart(this, '<%= item.get("itemId") %>', '<%= item.get("specId") %>')">
						<button class="remove-item" onclick="removeCart('<%= item.get("itemId") %>', '<%= item.get("specId") %>')">移除</button>
					</div>
					<% } %>
				</div>
				<form action="order.jsp" method="post">
					<div class="cart-summary">
					
						<div class="cart-total">
							<span>總金額:</span>
							<span class="total-price">NT$<%= totalPrice %></span>
						</div>
						<div class="payment-methods">
							<h3>選擇付款方式</h3>
							<label name="paymentMethod">
								<input type="radio" name="paymentMethod" value="credit-card" checked> 信用卡
								<input type="radio" name="paymentMethod" value="paypal"> PayPal
								<input type="radio" name="paymentMethod" value="cash"> 現金
							</label>
						</div>
						<div id="creditCardInput" style="display: none;">
							<input type="text" name="creditCard" placeholder="信用卡號" required>
						</div>
						<button class="checkout" type="submit">去下單</button>
					</div>
				</form>
        </div>
    </main>

    <footer>
        <div class="flex">
            <div class="flex1">
                <h1 class="title">Maisie</h1>
            </div>
            <div class="flex2">
                <a href="../pages/contant.html">
                    <h2 class="title02">CONTACT US</h2>
                </a>
                <div class="flex_col">
                    <div class="flex1_1">
                        <img src="../assets/img/ins.png" alt="1">
                        <h5 class="highlight">Maisie_Accessories</h5>
                    </div>
                    <div class="flex1_1">
                        <img src="../assets/img/phone.png" alt="2">
                        <h5 class="highlight">0800-000-000</h5>
                    </div>
                    <div class="flex1_1">
                        <img src="../assets/img/email.png" alt="3">
                        <h5 class="highlight"><a href="mailto:MaisieAccessories@gmail.com">MaisieAccessories@gmail.com</a></h5>
                    </div>
                    <div class="flex1_1">
                        <img src="../assets/img/map.png" alt="4">
                        <h5 class="highlight"><a href="https://maps.app.goo.gl/SV7Erzre8KS6aKP39" target="_blank">桃園市中壢區中北路200號</a></h5>
                    </div>
                </div>
            </div>
            <div class="flex3">
                <h2 class="title02">SERVICE</h2>
                <div class="flex_col">
                    <h5 class="highlight">飾品保養</h5>
                    <h5 class="highlight">付款與配送</h5>
                </div>
            </div>
        </div>
    </footer>
    <script>
		function updateCart(input, itemId, specId) {
			var newQuantity = input.value;
			var xhr = new XMLHttpRequest();
			xhr.open("POST", "updateCart.jsp", true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			xhr.onreadystatechange = function () {
				if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
				}
			};
			xhr.send("itemId=" + encodeURIComponent(itemId) + "&specId=" + encodeURIComponent(specId) + "&quantity=" + encodeURIComponent(newQuantity));
		}

		function removeCart(itemId,specId) {
			var xhr = new XMLHttpRequest();
			xhr.open("POST", "removeCart.jsp", true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			xhr.onreadystatechange = function () {
				if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
				}
			};
			xhr.send("itemId=" + encodeURIComponent(itemId)+"&specId=" + encodeURIComponent(specId));
		}
        // 監聽付款方式選擇框的變化
        document.querySelectorAll('input[name="paymentMethod"]').forEach((elem) => {
        elem.addEventListener("change", function(event) {
            var value = event.target.value;
            var creditCardInput = document.getElementById("creditCardInput");
            if (value === "credit-card") {
                creditCardInput.style.display = "block";
                creditCardInput.querySelector('input').required = true;
            } else {
                creditCardInput.style.display = "none";
                creditCardInput.querySelector('input').required = false;
            }
        });
    });

        // 初始化顯示或隱藏信用卡輸入框
        document.addEventListener("DOMContentLoaded", function() {
            var selectedPayment = document.querySelector('input[name="paymentMethod"]:checked').value;
            var creditCardInput = document.getElementById("creditCardInput");
            if (selectedPayment === "credit-card") {
                creditCardInput.style.display = "block";
            } else {
                creditCardInput.style.display = "none";
            }
        });
    </script>
    <script src="../assets/js/cart.js"></script>
</body>
</html>
