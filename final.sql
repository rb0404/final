DROP DATABASE IF EXISTS final;
CREATE DATABASE final CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE final;
DROP TABLE IF EXISTS `Member`;
CREATE TABLE `Member` (
    `memberId` INT(8) AUTO_INCREMENT,
    `email` VARCHAR(30),
    `password` VARCHAR(16),
    `memberName` VARCHAR(16),
    `birthDay` date,
    `sex` CHAR(1),
    `phoneNumber` VARCHAR(10),
    `address` TEXT,
    `lastLoginTime` DATETIME,
    PRIMARY KEY (memberId)
)AUTO_INCREMENT=10000000;
DROP TABLE IF EXISTS `Spec`;
DROP TABLE IF EXISTS `Item`;
CREATE TABLE `Item` (  
	itemId INT(8) AUTO_INCREMENT,
	itemName VARCHAR(16),
	itemDescription TEXT,
	price DECIMAL(10, 2),
    typeId INT(1),
    PRIMARY KEY (itemId)
)AUTO_INCREMENT=10000000;
INSERT INTO `Item` (itemName, itemDescription, price, typeId)
VALUES 
('藍色冰心碎鑽毛衣練', '', 880, 1),
('珍珠碎鑽雙鍊條練', '', 980, 1),
('個性水滴鎖骨練', '金色/銀色', 980, 1),
('項鍊', '', 780, 1),
('珍珠魚尾波浪手鍊', '', 580, 2),
('高級感碎銀珍珠手鍊', '純珍珠+雙練/純珠鍊/雙鍊', 580, 2),
('海藍寶石手鍊', '', 580, 2),
('手鍊', '', 450, 2),
('法式水滴珍珠耳飾', '', 520, 3),
('蝴蝶長墜耳飾', '', 520, 3),
('簡約韓系蝴蝶結耳飾', '金色/銀色', 450, 3),
('耳飾', '', 350, 3),
('編織線條戒指', '', 390, 4),
('交叉珍珠戒指', '', 580, 4),
('白貝母素圈戒指', '金色/銀色', 750, 4),
('戒指', '', 250, 4),
('簡約氣質項鍊&戒指', '', 550, 5),
('法式珍珠碎銀雙鍊手鍊', '', 880, 5),
('甜酷戒指組合', '', 680, 5),
('鬱金香珍珠手鍊', '', 880, 5),
('夏日珍珠雙層愛心鎖骨練', '', 880, 5),
('極簡素圈&珍珠戒指組合', '', 550, 5);
CREATE TABLE `Spec` (
    itemId INT(8),
    specId INT(1),
    specName VARCHAR(30),
    inventoryQuantity INT,
    FOREIGN KEY (itemId) REFERENCES Item(itemId)
);
INSERT INTO `Spec` (itemId,specId, specName, inventoryQuantity)
VALUES 
('10000000',"1", '標準', 5),
('10000001',"1", '標準', 5),
('10000002',"1", '金色', 5),
('10000002',"2", '銀色', 5),
('10000003',"1", '標準', 5),
('10000004',"1", '標準', 5),
('10000005',"1", '純珍珠+雙練', 5),
('10000005',"2", '純珠鍊', 5),
('10000005',"3", '雙鍊', 5),
('10000006',"1", '標準', 5),
('10000007',"1", '標準', 5),
('10000008',"1", '標準', 5),
('10000009',"1", '標準', 5),
('10000010',"1", '金色', 5),
('10000010',"2", '銀色', 5),
('10000011',"1", '標準', 5),
('10000012',"1", '標準', 5),
('10000013',"1", '標準', 5),
('10000014',"1", '金色', 5),
('10000014',"2", '銀色', 5),
('10000015',"1", '標準', 5),
('10000016',"1", '標準', 5),
('10000017',"1", '標準', 5),
('10000018',"1", '標準', 5),
('10000019',"1", '標準', 5),
('10000020',"1", '標準', 5),
('10000021',"1", '標準', 5);
DROP TABLE IF EXISTS `Type`;
CREATE TABLE `Type` (
    typeId INT(1),
	typeName VARCHAR(16),
    PRIMARY KEY (typeId)
);
INSERT INTO Type (typeId,typeName) VALUES (1,"Necklace 項鍊");
INSERT INTO Type (typeId,typeName) VALUES (2,"Bracelet 手鍊");
INSERT INTO Type (typeId,typeName) VALUES (3,"Earring 耳飾");
INSERT INTO Type (typeId,typeName) VALUES (4,"Ring 戒指");
INSERT INTO Type (typeId,typeName) VALUES (5,"Hottest 熱門商品");
DROP TABLE IF EXISTS `Order`;
CREATE TABLE `Order` (
    orderId INT(8) AUTO_INCREMENT,
	memberId INT(8),
	orderDate DATE,
	paymentMethod VARCHAR(20),
    `creditCard` VARCHAR(16),
	paymentStatus CHAR(1),
	address TEXT,
	totalPrice DECIMAL(10, 2),
	orderStatus CHAR(1),
	notes TEXT,
    PRIMARY KEY (orderId)
)AUTO_INCREMENT=10000000;
DROP TABLE IF EXISTS `OrderDetails`;
CREATE TABLE `OrderDetails` (
    orderId INT(8),
	itemId INT(8),
    specId INT(1),
	quantity INT,
    PRIMARY KEY (orderId,itemId,specId)
);
DROP TABLE IF EXISTS `Cart`;
CREATE TABLE `Cart` (  
    memberId INT(8),
	itemId INT(8),
    specId INT(1),
	quantity INT,
    PRIMARY KEY (memberId,itemId,specId)
);
DROP TABLE IF EXISTS `Comment`;
CREATE TABLE `Comment` (  
    commentId INT(8) AUTO_INCREMENT,
	itemId INT(8),
	memberId INT(8),
    specId INT(1),
	score INT(1),
	contents TEXT,
	commentDate DATE,
    PRIMARY KEY (commentId)
)AUTO_INCREMENT=10000000;