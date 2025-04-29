<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%
request.setCharacterEncoding("UTF-8");
HttpSession session1 = request.getSession();

String memberId = String.valueOf(session1.getAttribute("userID"));

String url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";

// 獲取商品ID
String itemId = request.getParameter("itemId");
session1.setAttribute("itemId", itemId);

// 初始化商品信息變量
String itemName = "";
String typeId ="";
String itemDescription = "";
double itemPrice = 0.0;
int itemQuantity = 0;

// 初始化規格變量
String specId = request.getParameter("specId");
if (specId == null || specId.isEmpty()) {
    specId = "1"; // 默認規格
}

// 獲取資料庫連接
Connection con = null;
PreparedStatement stmt = null;
ResultSet rs = null;
List<String> specList = new ArrayList<>();
Map<String, String> specMap = new HashMap<>();
// 獲取類型
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
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    
    con = DriverManager.getConnection(url, "root", "1234");

    // 查詢商品信息
    sql = "SELECT i.itemName,i.typeId, i.itemDescription, i.price, s.inventoryQuantity FROM Item i INNER JOIN Spec s ON i.itemId = s.itemId WHERE i.itemId = ? AND s.specId = ?";
    stmt = con.prepareStatement(sql);
    stmt.setString(1, itemId);
    stmt.setString(2, specId);
    rs = stmt.executeQuery();
    if (rs.next()) {
        itemName = rs.getString("itemName");
        itemDescription = rs.getString("itemDescription");
        itemPrice = rs.getDouble("price");
        itemQuantity = rs.getInt("inventoryQuantity");
        typeId = rs.getString("typeId");
    }

    // 查詢所有規格及名稱
    String specSql = "SELECT specId, specName FROM Spec WHERE itemId = ?";
    stmt = con.prepareStatement(specSql);
    stmt.setString(1, itemId);
    rs = stmt.executeQuery();
    while (rs.next()) {
        String id = rs.getString("specId");
        String name = rs.getString("specName");
        specList.add(id);
        specMap.put(id, name);
    }
    rs.close();
    stmt.close();

    // 根據 formId 處理不同的表單提交
    if ("POST".equalsIgnoreCase(request.getMethod()) && "addToCart".equals(request.getParameter("formId"))) {
        if (session1.getAttribute("userID") == null) {
            response.sendRedirect("logIn.jsp");
            return;
        } else {
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String checkSql = "SELECT * FROM Cart WHERE memberId = ? AND itemId = ? AND specId = ?";
            stmt = con.prepareStatement(checkSql);
            stmt.setString(1, memberId);
            stmt.setString(2, itemId);
            stmt.setString(3, request.getParameter("specId"));
            rs = stmt.executeQuery();
            if (rs.next()) {
                int existingQuantity = rs.getInt("quantity");
                int newQuantity = existingQuantity + quantity;
                sql = "UPDATE Cart SET quantity = ? WHERE memberId = ? AND itemId = ? AND specId = ?";
                stmt = con.prepareStatement(sql);
                stmt.setInt(1, newQuantity);
                stmt.setString(2, memberId);
                stmt.setString(3, itemId);
                stmt.setString(4, request.getParameter("specId"));
                stmt.executeUpdate();
            } else {
                sql = "INSERT INTO Cart (memberId, itemId, quantity, specId) VALUES (?, ?, ?, ?)";
                stmt = con.prepareStatement(sql);
                stmt.setString(1, memberId);
                stmt.setString(2, itemId);
                stmt.setInt(3, quantity);
                stmt.setString(4, request.getParameter("specId"));
                stmt.executeUpdate();
            }
            rs.close();
            stmt.close();
            response.sendRedirect("cart.jsp");
        }
    } else if ("POST".equalsIgnoreCase(request.getMethod()) && "comment".equals(request.getParameter("formId"))) {
        if (session1.getAttribute("userID") == null) {
            response.sendRedirect("logIn.jsp");
            return;
        } else {
            // 檢查用戶是否購買過該商品
            sql = "SELECT * FROM OrderDetails od " +
                  "JOIN `Order` o ON od.orderId = o.orderId " +
                  "WHERE o.memberId = ? AND od.itemId = ? AND od.specId = ?";
            stmt = con.prepareStatement(sql);
            stmt.setString(1, memberId);
            stmt.setString(2, itemId);
            stmt.setString(3, request.getParameter("specId"));
            rs = stmt.executeQuery();

            if (rs.next()) {
                // 用戶已購買過該商品，允許評論
                rs.close();
                stmt.close();

                // 插入評論
                sql = "INSERT INTO final.comment (itemId, memberId, score, contents, commentDate, specId) VALUES (?, ?, ?, ?, ?, ?)";
                stmt = con.prepareStatement(sql);
                stmt.setString(1, itemId);
                stmt.setString(2, memberId);
                stmt.setString(3, request.getParameter("score"));
                stmt.setString(4, request.getParameter("comment"));
                stmt.setDate(5, java.sql.Date.valueOf(LocalDate.now()));
                stmt.setString(6, request.getParameter("specId"));
                stmt.executeUpdate();
                stmt.close();

                // 彈出成功信息
                out.println("<script>alert('您已成功評論此商品！');</script>");
            } else {
                // 用戶未購買過該商品，不能評論
                rs.close();
                stmt.close();
                out.println("<script>alert('您尚未購買此商品，無法評論！');</script>");
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
<html>
<script src="https://code.iconify.design/iconify-icon/1.0.7/iconify-icon.min.js"></script>
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>商品詳情</title>
	<link rel="stylesheet" href="../assets/css/hf.css">
    <link rel="stylesheet" href="../assets/css/product.css">
</head>
<script src="https://code.iconify.design/iconify-icon/1.0.7/iconify-icon.min.js"></script>
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
        <div class="container">
			<section class="section product-section">
				<div class="image-container">
					<button class="nav-button left" onclick="changeSpec(-1)">&#8249;</button>
					<img id="productImage" src="../assets/img/<%=typeId%>/<%=itemId%>_<%=specId%>.PNG" class="image active">
					<input type="text" name="spec" min="1" max="<%= specList.size() %>" value="1" onchange="updateImage(this.value)" readonly style="display:none;">
					<button class="nav-button right" onclick="changeSpec(1)">&#8250;</button>
				</div>
				<div class="product-info">
					<h2><%= itemName %></h2>
					<p class="price">NT$ <%= itemPrice %></h5>
					<p class="description"><%= itemDescription %></p>
					<p class="stock">庫存: <%= itemQuantity %></p>
					<form method="post" action="product.jsp">
						<input type="hidden" name="formId" value="addToCart">
						<input type="hidden" name="itemId" value="<%= itemId %>">
						<input type="hidden" name="specId" value="<%= specId %>">
						<div class="quantity-control-container">
							<div class="quantity-selector">
								<button onclick="changeQuantity(-1)">-</button>
								<input type="text" name="quantity" min="1" max="<%= itemQuantity %>" value="1" readonly>
								<button onclick="changeQuantity(1)">+</button>
							</div>
							<input type="submit" class="add-to-cart" value="加入購物車">
						</div>
					</form>
				</div>
			</section>
				
			<section class="review">
                <div class="review-board">
                    <h2>商品評論</h2>
                    <div class="review-item">
						<form id="ratingForm" action="product.jsp" method="post" style="display:flex;">
						<div class="user">
                            <img src="../assets/img/person.png" alt="user">
                            <span>YOU</span>
                        </div>
                        <h4>評論:</h4>
							<input type="text" class="comment" name="comment"  required>
							<input type="hidden" name="formId" value="comment">
							<input type="hidden" name="itemId" value="<%= itemId %>">
							<input type="hidden" name="specId" value="<%= specId %>">
							<input type="hidden" id="ratingInput" name="score" value="">
							<div class="stars">
								<div class="stars" id="star-rating" required>
									<span class="star-icon" data-index="1">☆</span>
									<span class="star-icon" data-index="2">☆</span>
									<span class="star-icon" data-index="3">☆</span>
									<span class="star-icon" data-index="4">☆</span>
									<span class="star-icon" data-index="5">☆</span>
								</div>
								<button type="submit" class="comment">提交評論</button>
							</div>
						</form>
                    </div>
					
					<%
					// 重新獲取評論
					try {
						Class.forName("com.mysql.cj.jdbc.Driver");
						con = DriverManager.getConnection(url, "root", "1234");
						String commentSql = "SELECT c.*, m.memberName FROM Comment c " +
											"INNER JOIN Member m ON c.memberId = m.memberId " +
											"WHERE c.itemId = ? AND specId=?";
						PreparedStatement commentStmt = con.prepareStatement(commentSql);
						commentStmt.setInt(1, Integer.parseInt(itemId));
						commentStmt.setInt(2, Integer.parseInt(specId));
						ResultSet commentRs = commentStmt.executeQuery();
						
						// 顯示評論
						while (commentRs.next()) {
					%>
					<div class="review-item">
                        <div class="user">
                            <img src="../assets/img/person.png" alt="user">
                            <span><%= commentRs.getString("memberName") %></span>
                        </div>
                        <div class="comment"><%= commentRs.getString("contents") %></div>
                        <div class="stars">
                            <span>
								<%
								int score = commentRs.getInt("score");
								for (int i = 0; i < score; i++) {
									out.print("★");
								}
								for (int i = 0; i < 5-score; i++) {
									out.print("☆");
								}
								%>
							</span>
                        </div>
						<div style="font-size: 50%; color: grey;">
							<%= commentRs.getDate("commentDate") %>
						</div>
                    </div>
					<%
						}
						commentRs.close();
						commentStmt.close();
					} catch (SQLException e) {
						e.printStackTrace();
					}
					%>
                </div>
            </section>
		</div>
	</div>

    <script>
		function updateImage(specId) {
            var itemId = '<%= itemId %>';
			var typeId = '<%= typeId %>';
            var image = document.getElementById('productImage');
            image.src = '../assets/img/' +typeId+'/'+ itemId + '_' + specId + '.PNG';
			event.preventDefault();
        }

		function changeSpec(change) {
			var specInput = document.getElementsByName("spec")[0];
			var currentValue = parseInt(specInput.value);
			var newValue = currentValue + change;
			if (newValue < parseInt(specInput.min)) {
				newValue = parseInt(specInput.min);
			}
			if (newValue > parseInt(specInput.max)) {
				newValue = parseInt(specInput.max);
			}
			document.getElementsByName("specId")[0].value = newValue;
			updateImage(newValue); 
			event.preventDefault();
		}
		
		function changeQuantity(change) {
			var quantityInput = document.getElementsByName("quantity")[0];
			var currentValue = parseInt(quantityInput.value);
			var newValue = currentValue + change;
			if (newValue < parseInt(quantityInput.min)) {
				newValue = parseInt(quantityInput.min);
			}
			if (newValue > parseInt(quantityInput.max)) {
				newValue = parseInt(quantityInput.max);
			}
			quantityInput.value = newValue;
			event.preventDefault();
		}

		document.addEventListener("DOMContentLoaded", function() {
			const ratingForm = document.getElementById("ratingForm");
			const starRating = document.getElementById("star-rating");
			const starIcons = starRating.querySelectorAll(".star-icon");
			const ratingInput = document.getElementById("ratingInput");

			ratingForm.addEventListener("submit", function(event) {
				let ratingSelected = false;
				starIcons.forEach((starIcon) => {
					if (starIcon.textContent === "★") {
						ratingSelected = true;
					}
				});

				if (!ratingSelected) {
					event.preventDefault(); // 阻止表單提交
					alert("請選擇評分！");
				}
			});

			starIcons.forEach((starIcon) => {
				starIcon.addEventListener("click", function() {
					const clickedIndex = parseInt(this.getAttribute("data-index"));
					starIcons.forEach((icon, index) => {
						if (index < clickedIndex) {
							icon.textContent = "★";
						} else {
							icon.textContent = "☆";
						}
					});

					ratingInput.value = clickedIndex;
					console.log("Selected Rating: " + clickedIndex);
				});
			});
		});

	</script>

</body>
</html>
