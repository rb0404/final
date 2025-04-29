<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%
request.setCharacterEncoding("UTF-8");

// 獲取類型
Connection con = null;
PreparedStatement stmt = null;
ResultSet rs = null;
String url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
Class.forName("com.mysql.jdbc.Driver");
con = DriverManager.getConnection(url, "root", "1234");
String sql = "SELECT typeId, typeName FROM Type";
stmt = con.prepareStatement(sql);
rs = stmt.executeQuery();
List<Map<String, String>> typeList = new ArrayList<>();
while (rs.next()) {
    Map<String, String> type = new HashMap<>();
    type.put("typeId", rs.getString("typeId"));
    type.put("typeName", rs.getString("typeName"));
    typeList.add(type);
}
%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>top</title>
    <link rel="stylesheet" href="../assets/css/hf.css">
    <link rel="stylesheet" href="../assets/css/top.css">
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
        <div class="content_box">
            <div class="flex_col">
                <div class="flex_col1">
                    <h1 class="title">MAISIE</h1>
                    <h3 class="sub">Adorn with Maisie: Where Pearls Become Poetry</h3>
                </div>
            <a href="store.jsp"><button class="btn">PICK</button></a>
            </div>
        </div>
        <div class="root">
            <h1><a href="store.jsp" class="item">New!</a></h1>
            <div class="flex_row">
              <div class="flex_col1">
                <img src="../assets/img/top/n1.PNG" alt="1">
                <div class="item">
                    <h3 class="title">夏日珍珠雙層愛心鎖骨鍊</h3s>
                    <h3 class="sub">$880</h3>
                </div>
            </div>
            <div class="flex_col2">
                <div class="col">
                    <img src="../assets/img/top/n2.PNG" alt="2">
                    <div class="item">
                        <h3 class="title">法式珍珠碎銀雙鍊手鍊</h3>
                        <h3 class="sub">$780</h3>
                    </div>
                </div>
                <div class="col">
                    <img src="../assets/img/top/n3.PNG" alt="3">
                    <div class="item">
                        <h3 class="title">極簡素圈&amp;珍珠戒指組合</h3>
                        <h3 class="sub">$550</h3>
                    </div>
                </div>
            </div>
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