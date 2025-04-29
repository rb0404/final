<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import="java.time.Instant" %>
<%@ page import="javax.servlet.http.*" %>
<%
request.setCharacterEncoding("UTF-8");
String message = "";
if ("POST".equalsIgnoreCase(request.getMethod())) {
    Connection con = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    try {
        request.setCharacterEncoding("UTF-8");

        //建立數據庫連接
        Class.forName("com.mysql.jdbc.Driver");
        String url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
        con = DriverManager.getConnection(url, "root", "1234");
        
        // 檢查Email是否存在
        String email = request.getParameter("email");
        String checkSql = "SELECT memberID FROM Member WHERE email = ?";
        stmt = con.prepareStatement(checkSql);
        stmt.setString(1, email);
        rs = stmt.executeQuery();
        if (rs.next()) {
            message = email + " 已經註冊！";
        } else {
            // 如果Email不存在則註冊
            String insertSql = "INSERT INTO Member (email, password, memberName, sex, phoneNumber, address, creditCard, lastLoginTime) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            stmt = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, email);
            stmt.setString(2, request.getParameter("password"));
            stmt.setString(3, request.getParameter("name"));
            stmt.setString(4, request.getParameter("sex"));
            stmt.setString(5, request.getParameter("phonenumber"));
            stmt.setString(6, request.getParameter("address"));
            stmt.setString(7, request.getParameter("creditCard"));
            stmt.setTimestamp(8, Timestamp.from(Instant.now()));
            stmt.executeUpdate();

            // 獲取新用戶的ID
            rs = stmt.getGeneratedKeys();
            int userID = 0;
            if (rs.next()) {
                userID = rs.getInt(1);
            }

            // 將用戶ID存儲到 session 中
            HttpSession session1 = request.getSession();
            session1.setAttribute("userID", userID);

            message = email + " 註冊成功！";
            // 註冊成功後跳轉到用戶介面
            response.sendRedirect("user.jsp");
        }
    } catch (ClassNotFoundException | SQLException e) {
        out.println("SQL錯誤: " + e.toString());
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            message = "關閉資源時出錯: " + e.toString();
        }
    }
}
%>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>註冊</title>
    <link rel="stylesheet" href="../assets/css/hf.css">
    <link rel="stylesheet" href="../assets/css/login.css">
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
                    <div class="flex2">
                        <input type="text" id="searchQuery" name="searchQuery" placeholder="Search...">
                        <img class="search" src="../assets/img/search.png" alt="Search" onclick="performSearch()">
                    </div>
                </div>
                <div class="dropdown">
                    <h3 class="sub"><a href="store.jsp" class="item">商品分類</a></h3>
                    <div class="dropdown-content">
                        <a href="store.jsp">All Produces</a>
                        <a href="store.jsp?typeId=1">Necklace項鍊</a>
                        <a href="store.jsp?typeId=2">Bracelet手鍊</a>
                        <a href="store.jsp?typeId=3">Earring耳飾</a>
                        <a href="store.jsp?typeId=4">Ring戒指</a>
                    </div>
                </div>
                <h3 class="sub"><a href="cart.jsp" class="item">購物車</a></h3>
                <a href="user.jsp"><button class="btn">會員中心</button></a>
            </div>
        </div>
    </header>
    <main>
        <h2>註冊</h2>
        <form method="POST" action="" accept-charset="UTF-8">
            <p>Email：<input type="email" name="email" required></p>
            <p>密碼：<input type="password" name="password" required></p>
            <p>姓名：<input type="text" name="name" required></p>
            <p>性別：男<input type="radio" value="B" name="sex"> 女<input type="radio" value="G" name="sex"></p>
            <p>手機號碼：<input type="text" name="phonenumber" required></p>
            <p>地址：<input type="text" name="address" required></p>
            <p>生日：<input type="date" name="birth"></p>
            <p>信用卡：<input type="text" name="creditCard" required></p>
            <p><input type="submit" value="提交"><input type="reset" value="重置"></p>
        </form>
        <p>已有帳號?<a id="storeLink" href="logIn.jsp">登入</a></p>
        <p><%= message %></p>
    </main>
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
