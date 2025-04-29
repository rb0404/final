<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
request.setCharacterEncoding("UTF-8");

// 業者驗證
HttpSession session1 = request.getSession();
Integer userID = (Integer) session.getAttribute("userID");
if (userID == null || userID != 10000000) {
    response.sendRedirect("logIn.jsp");
    return;
}

Connection con = null;
PreparedStatement stmt = null;
PreparedStatement stmtType = null;
PreparedStatement stmtSpec = null;
ResultSet rs = null;
ResultSet rsType = null;
ResultSet rsSpec = null;
String sql = null;
String url = "jdbc:mysql://localhost/final?serverTimezone=UTC&characterEncoding=UTF-8";

// 讀取types
List<Map<String, String>> types = new ArrayList<>();
try {
    Class.forName("com.mysql.jdbc.Driver");
    con = DriverManager.getConnection(url, "root", "1234");
    String typeSql = "SELECT typeId, typeName FROM Type";
    stmtType = con.prepareStatement(typeSql);
    rsType = stmtType.executeQuery();
    while (rsType.next()) {
        Map<String, String> type = new HashMap<>();
        type.put("typeId", rsType.getString("typeId"));
        type.put("typeName", rsType.getString("typeName"));
        types.add(type);
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rsType != null) rsType.close();
    if (stmtType != null) stmtType.close();
    if (con != null) con.close();
}

//更新
if ("POST".equalsIgnoreCase(request.getMethod()) && "update".equals(request.getParameter("formId"))) {
    Enumeration<String> parameterNames = request.getParameterNames();
    while (parameterNames.hasMoreElements()) {
        String paramName = parameterNames.nextElement();
        if (paramName.startsWith("itemDescription_") || paramName.startsWith("price_") || paramName.startsWith("inventoryQuantity_")) {
            String[] paramParts = paramName.split("_");
            if (paramParts.length >= 3) {
                String itemId = paramParts[1];
                String specId = paramParts[2];
                String itemName = request.getParameter("itemName_" + itemId);
                String itemDescription = request.getParameter("itemDescription_" + itemId);
                double price = Double.parseDouble(request.getParameter("price_" + itemId));
                int typeId = Integer.parseInt(request.getParameter("type_" + itemId));
                String specName = request.getParameter("specName_" + itemId + "_" + specId);
                String inventoryQuantityValue = request.getParameter("inventoryQuantity_" + itemId + "_" + specId);
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    con = DriverManager.getConnection(url, "root", "1234");
					sql = "UPDATE Spec SET specName=?, inventoryQuantity=? WHERE itemId=? AND specId=?";
					stmt = con.prepareStatement(sql);
					stmt.setString(1, specName);
					stmt.setString(2, inventoryQuantityValue);
					stmt.setString(3, itemId);
					stmt.setString(4, specId);
					stmt.executeUpdate();
					sql = "UPDATE Item SET itemName=?, itemDescription=?, price=?, typeId=? WHERE itemId=?";
					stmt = con.prepareStatement(sql);
					stmt.setString(1, itemName);
					stmt.setString(2, itemDescription);
					stmt.setDouble(3, price);
					stmt.setInt(4, typeId);
					stmt.setString(5, itemId);
					stmt.executeUpdate();
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (stmt != null) stmt.close();
                    if (con != null) con.close();
                }
            }
        }
    }
    for (String paramName : request.getParameterMap().keySet()) {
        if (paramName.startsWith("newSpecName_")) {
            String[] paramParts = paramName.split("_");
            if (paramParts.length == 3) {
                String itemId = paramParts[1];
                String newSpecName = request.getParameter(paramName);
                String newInventoryQuantity = request.getParameter("newInventoryQuantity_" + itemId + "_" + paramParts[2]);
                
                // 獲取當前商品的最大 specId
                int newSpecId = 0;
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    con = DriverManager.getConnection(url, "root", "1234");
                    String maxSpecIdSql = "SELECT MAX(specId) AS maxSpecId FROM Spec WHERE itemId=?";
                    stmt = con.prepareStatement(maxSpecIdSql);
                    stmt.setString(1, itemId);
                    rs = stmt.executeQuery();
                    if (rs.next()) {
                        newSpecId = rs.getInt("maxSpecId") + 1;
                    } else {
                        newSpecId = 1;
                    }
                    rs.close();
                    stmt.close();
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (con != null) con.close();
                }

                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    con = DriverManager.getConnection(url, "root", "1234");
                    // Insert new spec
                    sql = "INSERT INTO Spec (itemId, specId, specName, inventoryQuantity) VALUES (?, ?, ?, ?)";
                    stmt = con.prepareStatement(sql);
                    stmt.setString(1, itemId);
                    stmt.setInt(2, newSpecId);
                    stmt.setString(3, newSpecName);
                    stmt.setString(4, newInventoryQuantity);
                    stmt.executeUpdate();
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (stmt != null) stmt.close();
                    if (con != null) con.close();
                }
            }
        }
    }
}

//上架
if ("POST".equalsIgnoreCase(request.getMethod()) && "launch".equals(request.getParameter("formId"))) {
    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection(url, "root", "1234");
        String insertSql = "INSERT INTO Item (itemName, itemDescription, price, typeId) VALUES (?, ?, ?, ?)";
        stmt = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
        stmt.setString(1, request.getParameter("name"));
        stmt.setString(2, request.getParameter("description"));
        stmt.setString(3, request.getParameter("price"));
        stmt.setString(4, request.getParameter("type"));
        stmt.executeUpdate();
        rs = stmt.getGeneratedKeys();
        String itemId = null;
        if (rs.next()) {
            itemId = rs.getString(1);
        }
        insertSql = "INSERT INTO Spec (itemId,specId, specName, inventoryQuantity) VALUES (?,1, '標準', ?)";
        stmt = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
        stmt.setString(1, itemId);
        stmt.setString(2, request.getParameter("quantity"));
        stmt.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (stmt != null) stmt.close();
        if (con != null) con.close();
    }
}

//下架
if ("POST".equalsIgnoreCase(request.getMethod()) && "remove".equals(request.getParameter("formId"))) {
    try {
        String itemId = request.getParameter("itemId");
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection(url, "root", "1234");
        sql = "DELETE FROM Spec WHERE itemId = ?";
        stmt = con.prepareStatement(sql);
        stmt.setString(1, itemId);
        stmt.executeUpdate();
		sql = "DELETE FROM Item WHERE itemId = ?";
		stmt = con.prepareStatement(sql);
        stmt.setString(1, itemId);
        stmt.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (stmt != null) stmt.close();
        if (con != null) con.close();
    }
}

%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>後台管理</title>
    <script>
        function confirmChange() {
            return confirm("確定要修改嗎？");
        }
        function confirmDelete() {
            return confirm("確定要下架此商品嗎？");
        }
		
        function addSpec(itemId) {
            var specContainer = document.getElementById('specContainer_' + itemId);
            var newSpecDiv = document.createElement('div');
            var specCount = specContainer.children.length;
            var newSpecId = specCount; // 用規格量決定specId
            newSpecDiv.innerHTML = '<input type="text" name="newSpecName_' + itemId + '_' + newSpecId + '" value="新規格' + (newSpecId + 1) + '" required>' +
                                   '<input type="text" name="newInventoryQuantity_' + itemId + '_' + newSpecId + '" value="0" required>';
            specContainer.appendChild(newSpecDiv);
        }

        function removeSpec(itemId) {
            var specContainer = document.getElementById('specContainer_' + itemId);
            var specCount = specContainer.children.length;
            if (specCount > 1) {
                specContainer.removeChild(specContainer.lastChild);
            } else {
                alert("至少保留一個規格");
            }
        }
    </script>
</head>
<body>
    <h1>修改商品庫存數量</h1>
    <form id="update" action="backStage.jsp" method="post" accept-charset="UTF-8" onsubmit="return confirmChange();">
        <table border="1">
            <tr>
                <th>商品ID</th>
                <th>商品名稱</th>
                <th>商品描述</th>
                <th>價格</th>
                <th>分類</th>
                <th>規格/庫存數量</th>
                <th>操作</th>
            </tr>
            <% 
            try {
                Class.forName("com.mysql.jdbc.Driver");
                con = DriverManager.getConnection(url, "root", "1234");
                sql = "SELECT itemId, itemName, itemDescription, price, typeId FROM Item";
                stmt = con.prepareStatement(sql);
                rs = stmt.executeQuery();
                while (rs.next()) {
            %>
            <tr>
                <td><%= rs.getInt("itemId") %></td>
                <td>
                    <input type="hidden" name="formId" value="update">
                    <input type="hidden" name="itemId" value="<%= rs.getInt("itemId") %>" required>
                    <input type="text" name="itemName_<%= rs.getString("itemId") %>" value="<%= rs.getString("itemName") %>" required>
                </td>
                <td>
                    <input type="text" name="itemDescription_<%= rs.getInt("itemId") %>" value="<%= rs.getString("itemDescription") %>">
                </td>
                <td>
                    <input type="text" name="price_<%= rs.getInt("itemId") %>" value="<%= rs.getDouble("price") %>" required>
                </td>
                <td>
                    <select name="type_<%= rs.getInt("itemId") %>">
                        <% for (Map<String, String> type : types) { %>
                        <option value="<%= type.get("typeId") %>" <%= rs.getInt("typeId") == Integer.parseInt(type.get("typeId")) ? "selected" : "" %>><%= type.get("typeName") %></option>
                        <% } %>
                    </select>
                </td>
                <td width="350px">
                    <div id="specContainer_<%= rs.getInt("itemId") %>">
                    <% 
                    try {
                        String specSql = "SELECT * FROM Spec WHERE itemId=?";
                        stmtSpec = con.prepareStatement(specSql);
                        stmtSpec.setInt(1, rs.getInt("itemId"));
                        rsSpec = stmtSpec.executeQuery();
                        while (rsSpec.next()) {
                    %>
                    <div>
                        <input type="text" name="specName_<%= rsSpec.getInt("itemId") %>_<%= rsSpec.getInt("specId") %>" value="<%= rsSpec.getString("specName") %>" required>
                        <input type="text" name="inventoryQuantity_<%= rsSpec.getInt("itemId") %>_<%= rsSpec.getInt("specId") %>" value="<%= rsSpec.getString("inventoryQuantity") %>" required>
                    </div>
                    <% 
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rsSpec != null) rsSpec.close();
                        if (stmtSpec != null) stmtSpec.close();
                    }
                    %>
                    </div>
                </td>
                <td>
                    <button type="button" onclick="addSpec(<%= rs.getInt("itemId") %>)">增加規格</button>
                    <button type="button" onclick="removeSpec(<%= rs.getInt("itemId") %>)">減少規格</button>
                </td>
            </tr>
            <% 
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            }
            %>
        </table>
        <input type="submit" value="確認更改">
        <input type="reset" value="取消">
    </form>

    <h1>上架新品</h1>
    <form id="launch" method="POST" action="backStage.jsp" accept-charset="UTF-8">
        <table border="1">
            <input type="hidden" name="formId" value="launch">
            <tr>
                <th>商品名稱</th>
                <th>商品敘述</th>
                <th>價格</th>
                <th>數量</th>
                <th>分類</th>
            </tr>
            <tr>
                <td><input type="text" name="name" required></td>
                <td><input type="text" name="description" required></td>
                <td><input type="text" name="price" required></td>
                <td><input type="text" name="quantity" required></td>
                <td>
                    <select name="type">
                        <% for (Map<String, String> type : types) { %>
                        <option value="<%= type.get("typeId") %>"><%= type.get("typeName") %></option>
                        <% } %>
                    </select>
                </td>
            </tr>
        </table>
        <input type="submit" value="上架">
        <input type="reset" value="取消">
    </form>

    <h1>下架商品</h1>
    <form id="remove" method="POST" action="backStage.jsp" accept-charset="UTF-8" onsubmit="return confirmDelete();">
        <table border="1">
            <input type="hidden" name="formId" value="remove">
            <tr>
                <th>商品ID</th>
            </tr>
            <tr>
                <td><input type="text" name="itemId" required></td>
            </tr>
        </table>
        <input type="submit" value="下架">
        <input type="reset" value="取消">
    </form>
    <p><a href="sellerViewOrder.jsp">查看訂單</a></p>
</body>
</html>
