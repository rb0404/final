<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.Context" %>
<%
request.setCharacterEncoding("UTF-8");
HttpSession session1 = request.getSession();
if (session1.getAttribute("userID") == null) {
    response.sendRedirect("logIn.jsp");
    return;
}

int userID = (int) session1.getAttribute("userID");
String userName = "";
String email = "";
String birth = "";
String phoneNumber = "";
String address = "";
String sql="";
String url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
List<Map<String, String>> typeList = new ArrayList<>();
List<Map<String, String>> itemList = new ArrayList<>();

Connection con = null;
PreparedStatement stmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    con = DriverManager.getConnection(url, "root", "1234");
    if (!con.isClosed()) {
        sql = "SELECT * FROM Member WHERE memberID = ?";
        stmt = con.prepareStatement(sql);
        stmt.setInt(1, userID);
        rs = stmt.executeQuery();
        if (rs.next()) {
            userName = rs.getString("memberName");
            email = rs.getString("email");
			birth = rs.getString("birthDay");
			phoneNumber = rs.getString("phoneNumber");
            address = rs.getString("address");
        }
		//類型列表
		sql = "SELECT typeId, typeName FROM Type";
		stmt = con.prepareStatement(sql);
		rs = stmt.executeQuery();
		while (rs.next()) {
			Map<String, String> type = new HashMap<>();
			type.put("typeId", rs.getString("typeId"));
			type.put("typeName", rs.getString("typeName"));
			typeList.add(type);
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



int counter = 0;
String strNo = "";
if (application.getAttribute("counter") == null) {
    application.setAttribute("counter", "100");
} else {
    strNo = (String) application.getAttribute("counter");
    counter = Integer.parseInt(strNo);
    if (session.isNew()) counter++;
    strNo = String.valueOf(counter);
    application.setAttribute("counter", strNo);
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用戶首頁</title>
    <link rel="stylesheet" href="../assets/css/hf.css">
    <link rel="stylesheet" href="../assets/css/member.css">
	<script>
		function performSearch() {
            var searchQuery = document.getElementById('searchQuery').value;
            var form = document.createElement('form');
            form.method = 'get';
            form.action = 'store.jsp';

            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'searchQuery';
            input.value = searchQuery;

            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }
	</script>
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

  <section>
    <h1 class="title">會員中心</h1>
    <div class="flex_row">
        <button class="btn" onclick="showSection('personal-info')">個人資訊</button>
        <button class="btn" onclick="showSection('order-info')">訂單資訊</button>
        <button class="btn" onclick="showSection('history-review')">歷史評論</button>
    </div>

    <div id="personal-info" class="content_box1">
        <div class="flex_col1">
            <div class="flex_row">
                <img class="image" src="../assets/img/person.png" alt="person" />
                <h1 class="title">Personal Information</h1>
            </div>
            <div class="flex_col2">
                <div class="flex_col3">
                    <h1 class="t01">用戶名 <%= userName %></h1>
                    <div class="rect"></div>
                </div>
                <div class="flex_col3">
                    <h1 class="t01">生日 <%= birth %></h1>
                    <div class="rect"></div>
                </div>
                <div class="flex_col3">
                    <h1 class="t01">地址 <%= address %></h1>
                    <div class="rect"></div>
                </div>
                <div class="flex_col3">
                    <h1 class="t01">行動電話 <%= phoneNumber %></h1>
                    <div class="rect"></div>
                </div>
                <div class="flex_col3">
                    <h1 class="t01">電子郵件 <%= email %></h1>
                    <div class="rect"></div>
                </div>
            </div>
        </div>
    </div>
<%
PreparedStatement psOrder = null;
PreparedStatement psDetails = null;
ResultSet rsOrder = null;
ResultSet rsDetails = null;
try {
	Class.forName("com.mysql.jdbc.Driver");
    con = DriverManager.getConnection(url, "root", "1234");
    String queryOrder = "SELECT orderId, orderDate, paymentStatus, totalPrice FROM final.order WHERE memberId = ? ORDER BY orderId DESC";
    psOrder = con.prepareStatement(queryOrder);
    psOrder.setInt(1, userID);
    rsOrder = psOrder.executeQuery();
%>
    <div id="order-info" class="content_box2" style="display:none;">
        <div class="flex_col">
            <div class="row">
				<img src="../assets/img/list.png" alt="list">
				<h1 class="top">Order Information</h1>
            </div>
			<%
			while (rsOrder.next()) {
				int orderId = rsOrder.getInt("orderId");
			%>
            <div class="flex_col1">
				<div class="flex_row">
					<h1 class="title"><%= rsOrder.getDate("orderDate") %></h1>
					<h1 class="title">訂單狀態：訂單配送中</h1>
				</div>
				<div class="box">
                    <div class="flex_col2">
					<%
                    // Query to retrieve the details of the current order
                    String queryDetails = "SELECT s.specName, s.specId, od.itemId, i.itemName, i.price, od.quantity, o.paymentMethod " +
                                          "FROM OrderDetails od " +
                                          "JOIN Spec s ON od.itemId = s.itemId AND od.specId = s.specId " +
                                          "JOIN Item i ON od.itemId = i.itemId " +
                                          "JOIN final.order o ON od.orderId = o.orderId " +
                                          "WHERE od.orderId = ?";
                    psDetails = con.prepareStatement(queryDetails);
                    psDetails.setInt(1, orderId);
                    rsDetails = psDetails.executeQuery();
                    while (rsDetails.next()) {
                    %>
                        <div class="flex_row1">
                            <img src="../assets/img/ring/r1-1.JPG" alt="" />
                            <div class="flex_row2">
                                <h1 class="title1"><%= rsDetails.getString("itemName") %></h1>
                                <h1 class="title1">規格: <%= rsDetails.getString("specName") %></h1>
								<h1 class="title1">付款方式: <%= rsDetails.getString("paymentMethod") %></h1>
                                <h1 class="title1">數量: <%= rsDetails.getInt("quantity") %></h1>
                                <h1 class="title1">NT$<%= rsDetails.getBigDecimal("price") %></h1>
                            </div>
                        </div>
                    <%
                    }
                    rsDetails.close();
                    psDetails.close();
                    %>
						<hr class="line" size="1" />
						<div class="flex_row3">
                            <h3 class="subtitle">訂單編號：<%= orderId %></h3>
                            <div class="flex_row4">
                                <h1 class="title2">TOTAL:</h1>
                                <h1 class="title2">NT$<%= rsOrder.getBigDecimal("totalPrice") %></h1>
                            </div>
                        </div>
					</div>
                </div>
            </div>
			<%
			}
			%>
        </div>
    </div>
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
<%
try {
	Class.forName("com.mysql.jdbc.Driver");
	con = DriverManager.getConnection(url, "root", "1234");

    // 準備查詢
    sql = "SELECT C.commentId, C.itemId, C.specId, C.score, C.contents, C.commentDate, I.typeId " +
                 "FROM Comment C JOIN Item I ON C.itemId = I.itemId WHERE C.memberId = ?";
    stmt = con.prepareStatement(sql);
    stmt.setInt(1, userID); // 設置會員ID參數

    // 執行查詢
    rs = stmt.executeQuery();
%>
	<div id="history-review" class="content_box3" style="display:none;">
	<div class="row">
		<img src="../assets/img/comment.png" alt="comment">
		<h1 class="top">History Review</h1>
	</div>
<%
    while (rs.next()) {
        // 獲取數據
        String itemId = rs.getString("itemId");
		String specId = rs.getString("specId");
		String score = rs.getString("score");
		String contents = rs.getString("contents");
        String commentDate = rs.getString("commentDate");

        // 輸出HTML
%>
		<div class="box">
			<div class="flex_row">
				<img id="productImage" src="../assets/img/<%= rs.getString("typeId") %>/<%= itemId %>_<%= specId %>.PNG">
				<h1 class="title"><%= contents %></h1>
				<h1 class="title"><%= commentDate %></h1>
			</div>
		</div>
<%
    }
    
    // 關閉資源
    rs.close();
    stmt.close();
    con.close();
} catch (Exception e) {
    e.printStackTrace();
}
%>

    
	</section>
	<button><a href="backStage.jsp">後臺入口</a></button>
	<button id="logoutButton">登出</button>

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
		<p>您是第<%= counter %>位訪客</p>
    </footer>
    <script>
		function showSection(sectionId) {
			document.getElementById('personal-info').style.display = 'none';
			document.getElementById('order-info').style.display = 'none';
			document.getElementById('history-review').style.display = 'none';
			document.getElementById(sectionId).style.display = 'block';
		}
		document.getElementById("logoutButton").addEventListener("click", function() {
			window.location.href = "logOut.jsp";
		});
  </script>
</body>
</html>
