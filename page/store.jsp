<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>

<%
request.setCharacterEncoding("UTF-8");
HttpSession session1 = request.getSession();

String sql = null;
String selectedTypeId = request.getParameter("typeId");
if (selectedTypeId != null) {
    session1.setAttribute("typeId", selectedTypeId);
}

String currentTypeId = (String) session1.getAttribute("typeId");
String searchQuery = request.getParameter("searchQuery");

List<Map<String, String>> typeList = new ArrayList<>();
List<Map<String, String>> itemList = new ArrayList<>();
List<Map<String, String>> topItemsList = new ArrayList<>();
Connection con = null;
PreparedStatement stmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    String url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
    con = DriverManager.getConnection(url, "root", "1234");

    if (!con.isClosed()) {
        // 獲取類型
        sql = "SELECT typeId, typeName FROM Type";
        stmt = con.prepareStatement(sql);
        rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, String> type = new HashMap<>();
            type.put("typeId", rs.getString("typeId"));
            type.put("typeName", rs.getString("typeName"));
            typeList.add(type);
        }
        rs.close();
        stmt.close();

        // 獲取商品列表
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql = "SELECT i.itemId, i.itemName, i.typeId, i.price FROM Item i WHERE i.itemName LIKE ?";
            stmt = con.prepareStatement(sql);
            stmt.setString(1, "%" + searchQuery + "%");
        } else if (currentTypeId == null || currentTypeId.equals("all")) {
            sql = "SELECT i.itemId, i.itemName, i.typeId, i.price FROM Item i";
            stmt = con.prepareStatement(sql);
        } else {
            sql = "SELECT i.itemId, i.itemName, i.typeId, i.price FROM Item i WHERE i.typeId = ?";
            stmt = con.prepareStatement(sql);
            stmt.setString(1, currentTypeId);
        }

        rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, String> item = new HashMap<>();
            item.put("itemId", rs.getString("itemId"));
            item.put("itemName", rs.getString("itemName"));
            item.put("typeId", rs.getString("typeId"));
            item.put("price", rs.getString("price"));
            itemList.add(item);
        }
        rs.close();
        stmt.close();

        // 獲取新品
        if (currentTypeId == null || currentTypeId.equals("all")) {
            sql = "SELECT i.itemId, i.itemName, i.typeId, i.price FROM Item i ORDER BY i.itemId DESC LIMIT 6";
            stmt = con.prepareStatement(sql);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, String> topItem = new HashMap<>();
                topItem.put("itemId", rs.getString("itemId"));
                topItem.put("itemName", rs.getString("itemName"));
                topItem.put("typeId", rs.getString("typeId"));
                topItem.put("price", rs.getString("price"));
                topItemsList.add(topItem);
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
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商店</title>
    <link rel="stylesheet" href="../assets/css/ps.css">
    <link rel="stylesheet" href="../assets/css/hf.css">
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

        function submitFormWithItemId(itemId) {
            var form = document.createElement('form');
            form.method = 'post';
            form.action = 'product.jsp';

            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'itemId';
            input.value = itemId;

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
        <div class="flex_col">
            <% if (searchQuery != null && !searchQuery.trim().isEmpty()) { %>
                <h1 class="title">搜尋結果</h1>
                <div class="grid">
                    <% if (itemList.isEmpty()) { %>
                        <h3>沒有找到符合的商品。</h3>
                    <% } else { %>
                        <% for (Map<String, String> item : itemList) { %>
                            <div class="item">
                                <img src="../assets/img/<%= item.get("typeId") %>/<%= item.get("itemId") %>_1.PNG" alt="商品圖片">
                                <h3 class="subtitle"><a href="javascript:void(0);" onclick="submitFormWithItemId('<%= item.get("itemId") %>')"><%= item.get("itemName") %></a></h3>
                                <h3 class="subtitle1">NT$<%= item.get("price") %></h3>
                            </div>
                        <% } %>
                    <% } %>
                </div>
            <% } else { %>
                <% if (currentTypeId == null || currentTypeId.equals("all")) { %>
                    <h1 class="title">New! 本月新品</h1>
                    <div class="grid">
                        <% for (Map<String, String> topItem : topItemsList) { %>
                            <div class="item">
								<a href="javascript:void(0);" onclick="submitFormWithItemId('<%= topItem.get("itemId") %>')">
									<img src="../assets/img/<%= topItem.get("typeId") %>/<%= topItem.get("itemId") %>_1.PNG" alt="商品圖片">
									<h3 class="subtitle"><%= topItem.get("itemName") %></h3>
									<h3 class="subtitle1">NT$<%= topItem.get("price") %></h3>
								</a>
                            </div>
                        <% } %>
                    </div>
                    <% for (Map<String, String> type : typeList) { %>
                        <h1 class="title"><%= type.get("typeName") %></h1>
                        <div class="grid">
                            <% for (Map<String, String> item : itemList) { 
                                if (item.get("typeId").equals(type.get("typeId"))) { %>
                                    <div class="item">
										<a href="javascript:void(0);" onclick="submitFormWithItemId('<%= item.get("itemId") %>')">
											<img src="../assets/img/<%= item.get("typeId") %>/<%= item.get("itemId") %>_1.PNG" alt="商品圖片">
											<h3 class="subtitle"><%= item.get("itemName") %></h3>
											<h3 class="subtitle1">NT$<%= item.get("price") %></h3>
										</a>
                                    </div>
                                <% } 
                            } %>
                        </div>
                    <% } %>
                <% } else { %>
                    <h1 class="title"><%
                        for (Map<String, String> type : typeList) {
                            if (type.get("typeId").equals(currentTypeId)) {
                                out.print(type.get("typeName"));
                            }
                        }
                    %></h1>
                    <div class="grid">
                        <% for (Map<String, String> item : itemList) { 
                            if (item.get("typeId").equals(currentTypeId)) { %>
                                <div class="item">
									<a href="javascript:void(0);" onclick="submitFormWithItemId('<%= item.get("itemId") %>')">
										<img src="../assets/img/<%= item.get("typeId") %>/<%= item.get("itemId") %>_1.PNG" alt="商品圖片">
										<h3 class="subtitle"><%= item.get("itemName") %></h3>
										<h3 class="subtitle1">NT$<%= item.get("price") %></h3>
									</a>
                                </div>
                            <% } 
                        } %>
                    </div>
                <% } %>
            <% } %>
        </div>
    </section>

    <footer>
        <div class="flex">
            <div class="flex1">
                <h1 class="title">Maisie</h1>
            </div>
            <div class="flex2">
                <h2 class="title02">CONTACT US</h2>
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
</body>
</html>
