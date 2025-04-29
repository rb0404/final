<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.time.Instant" %>
<%@ page import="java.util.*" %>
<%
request.setCharacterEncoding("UTF-8");
HttpSession session1 = request.getSession(true);
if (session1.getAttribute("userID") != null) {
    response.sendRedirect("user.jsp");
    return;
}
Connection con = null;
PreparedStatement stmt = null;
ResultSet rs = null;
String message = "";
String email = request.getParameter("email");
String password = request.getParameter("password");
String sql ="";
String url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";
// 獲取類型
Class.forName("com.mysql.jdbc.Driver");
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
rs.close();
stmt.close();
// 處理用戶提交的登錄請求
if ("POST".equalsIgnoreCase(request.getMethod()) && "signIn".equals(request.getParameter("formId"))) {
    try {
        //建立數據庫連接
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection(url, "root", "1234");
        
        // 檢查Email是否存在
        String checkSql = "SELECT memberID FROM Member WHERE email = ?";
        stmt = con.prepareStatement(checkSql);
        stmt.setString(1, email);
        rs = stmt.executeQuery();
        if (rs.next()) {
            message = email + " 已被註冊！";
        } else {
            // 如果Email不存在則註冊
            String insertSql = "INSERT INTO Member (email, password, memberName, birthDay, phoneNumber, address, lastLoginTime) VALUES (?,  ?, ?, ?, ?, ?, ?)";
            stmt = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, email);
            stmt.setString(2, request.getParameter("password"));
            stmt.setString(3, request.getParameter("name"));
            stmt.setString(4, request.getParameter("birth"));
            stmt.setString(5, request.getParameter("phonenumber"));
            stmt.setString(6, request.getParameter("address"));
            stmt.setTimestamp(7, Timestamp.from(Instant.now()));
            stmt.executeUpdate();

            // 獲取新用戶的ID
            rs = stmt.getGeneratedKeys();
            int userID = 0;
            if (rs.next()) {
                userID = rs.getInt(1);
            }

            message = email + " 註冊成功！";
            // 註冊成功後跳轉到用戶介面
			session1.setAttribute("userID", userID);
            response.sendRedirect("user.jsp");
        }
    } catch (ClassNotFoundException | SQLException e) {
        message = "錯誤: " + e.toString();
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


// 處理用戶提交的登錄請求
if ("POST".equalsIgnoreCase(request.getMethod()) && "logIn".equals(request.getParameter("formId"))) {
    try {
        // 建立資料庫連接
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection(url, "root", "1234");

        // 查詢用戶是否存在
        sql = "SELECT memberID FROM Member WHERE email = ? AND password = ?";
        stmt = con.prepareStatement(sql);
        stmt.setString(1, email);
        stmt.setString(2, password);
        rs = stmt.executeQuery();

        if (rs.next()) {
            // 如果用戶存在，將用戶ID存儲在會話中
            int memberID = rs.getInt("memberID");
            session1.setAttribute("userID", memberID);
            // 登錄成功後重定向到用戶首頁
            response.sendRedirect("user.jsp");
            return;
        } else {
            message = "用戶名或密碼錯誤!";
        }
    } catch (ClassNotFoundException | SQLException e) {
        message = "錯誤: " + e.toString();
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
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>log in</title>
    <link rel="stylesheet" href="../assets/css/hf.css">
    <link rel="stylesheet" href="../assets/css/logIn.css">
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
    <section id="login">
        <div class="logincontainer">
            <img src="../assets/img/log.jpg" alt="log" class="login-image">
            <div class="login-box">
                <h1 id="title">註冊</h1>
                <form action="logIn.jsp" method="post">
                    <input type="hidden" name="formId" id="formId" value="signIn">
                    <div class="input-group">
                        <div class="input-field" id="nameField">
                            <i class="fa-solid fa-user"></i>
                            <input type="text" name="name" placeholder="Name" required>
                        </div>

                        <div class="input-field" id="dateField">
                            <i class="fa-solid fa-calendar"></i>
                            <input type="date" name="birth" placeholder="Birth Date" required>
                        </div>

                        <div class="input-field" id="addressField">
                            <i class="fa-solid fa-map-marker-alt"></i>
                            <input type="text" name="address" placeholder="Address" required>
                        </div>

                        <div class="input-field" id="phoneField">
                            <i class="fa-solid fa-phone"></i>
                            <input type="tel" name="phonenumber" placeholder="Phone Number" required>
                        </div>

                        <div class="input-field">
                            <i class="fa-solid fa-envelope"></i>
                            <input type="email" name="email" placeholder="Email" required>
                        </div>

                        <div class="input-field">
                            <i class="fa-solid fa-lock"></i>
                            <input type="password" name="password" placeholder="Password" required>
                        </div>
                        <p><%= message %> Lost Password <a href="#">Click Here</a></p>
                    </div>
                    <div class="btn-field">
						<button type="submit" id="signinBtn" class="disable">登入</button>
                        <button type="submit" id="signupBtn">註冊</button>
                    </div>
                </form>
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
		let signupBtn = document.getElementById("signupBtn");
        let signinBtn = document.getElementById("signinBtn");
        let nameField = document.getElementById("nameField");
        let dateField = document.getElementById("dateField");
        let phoneField = document.getElementById("phoneField");
        let addressField = document.getElementById("addressField");
        let title = document.getElementById("title");
        let formId = document.getElementById("formId");

		// 用戶點擊註冊按鈕時的事件處理函數
		signupBtn.onclick = function(){
			// 如果當前 formId 已經是 "signIn"，則提交表單
			if (formId.value === "signIn") {
				// 提交表單
				form.submit();
			} else {
				// 否則變換formId
				let title = document.getElementById("title");

				// 重新顯示並設為必填
				nameField.style.maxHeight = "60px";
				nameField.querySelector("input").setAttribute("required", "");

				dateField.style.maxHeight = "60px";
				dateField.querySelector("input").setAttribute("required", "");

				phoneField.style.maxHeight = "60px";
				phoneField.querySelector("input").setAttribute("required", "");

				addressField.style.maxHeight = "60px";
				addressField.querySelector("input").setAttribute("required", "");

				title.innerHTML = "註冊";
				formId.value = "signIn";
				signupBtn.classList.remove("disable");
				signinBtn.classList.add("disable");
				return false; // 阻止表單提交
			}
		};


		// 用戶點擊登入按鈕時的事件處理函數
		signinBtn.onclick = function(){
			// 如果當前 formId 已經是 "logIn"，則提交表單
			if (formId.value === "logIn") {
				form.submit();
			} else {
				// 否則變換formId
				let title = document.getElementById("title");

				// 隱藏並變為非必填
				nameField.style.maxHeight = "0";
				nameField.querySelector("input").removeAttribute("required");

				dateField.style.maxHeight = "0";
				dateField.querySelector("input").removeAttribute("required");

				phoneField.style.maxHeight = "0";
				phoneField.querySelector("input").removeAttribute("required");

				addressField.style.maxHeight = "0";
				addressField.querySelector("input").removeAttribute("required");

				title.innerHTML = "登入";
				formId.value = "logIn";
				signupBtn.classList.add("disable");
				signinBtn.classList.remove("disable");
				return false; // 阻止表單提交
			}
		};
    </script>
</body>
</html>
