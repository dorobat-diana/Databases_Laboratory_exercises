CREATE DATABASE Test3
GO
USE Test3
GO
------------------------------------1----------------------------------------
CREATE TABLE Presentation(
	presentation_id INT,
	CONSTRAINT PK_presentation PRIMARY KEY(presentation_id),
	presentation_name VARCHAR(200),
	city VARCHAR(200)
);
CREATE TABLE Women(
	women_id INT,
	CONSTRAINT PK_women PRIMARY KEY(women_id),
	women_name VARCHAR(200),
	amount DECIMAL(15,2)
);
CREATE TABLE Shoe_model(
	shoe_model_id INT,
	CONSTRAINT PK_model PRIMARY KEY (shoe_model_id),
	model_name VARCHAR(200),
	season VARCHAR(200)
);
CREATE TABLE Shoes(
	shoe_id INT,
	CONSTRAINT PK_shoe PRIMARY KEY(shoe_id),
	price DECIMAL(15,2),
	shoe_model_id INT,
	CONSTRAINT FK_model FOREIGN KEY(shoe_model_id) REFERENCES Shoe_model(shoe_model_id),
);
CREATE TABLE Shoe_Presentation(
	shoe_id INT,
	presentation_id INT,
	CONSTRAINT FK_shoe FOREIGN KEY(shoe_id) REFERENCES Shoes(shoe_id),
	CONSTRAINT FK_presentation FOREIGN KEY(presentation_id) REFERENCES Presentation(presentation_id),
	CONSTRAINT PK_shoe_presentation PRIMARY KEY(shoe_id,presentation_id),
	available INT
);
CREATE TABLE Women_Shoe(
	shoe_id INT,
	women_id INT,
	amount DECIMAL(15,2),
	number_shoes INT
	CONSTRAINT FK_shoe2 FOREIGN KEY(shoe_id) REFERENCES Shoes(shoe_id),
	CONSTRAINT FK_women FOREIGN KEY(women_id) REFERENCES Women(women_id),
	CONSTRAINT PK_women_shoe PRIMARY KEY(shoe_id,women_id),
);
INSERT INTO Presentation VALUES (1,'pres1','city1'),(2,'pres2','city2'),(3,'pres3','city3');
INSERT INTO Women VALUES(11,'name1',300.00),(12,'name2',500.00),(13,'name3',2000.00);
INSERT INTO Shoe_model VALUES (111,'model1','season1'),(112,'model2','season2'),(113,'model3','season2'),(114,'model4','season3');
INSERT INTO Shoes VALUES (101,250.99,111),(102,500.50,112),(103,170.00,113),(104,200.00,111);
INSERT INTO Shoe_Presentation VALUES (101,1,200),(102,1,10),(103,2,150),(101,2,200),(101,3,200);
INSERT INTO Women_Shoe VALUES(101,11,250.99,1),(102,13,1001.00,2),(103,13,170.00,1);
------------------------------------------2--------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE procedure_3(@shoe_id INT,@presentation_id INT,@nhumber INT)
AS
BEGIN
	UPDATE Shoe_Presentation
	SET available= available+@nhumber
	WHERE shoe_id=@shoe_id and presentation_id=@presentation_id
END
GO
select* from Shoe_Presentation
exec procedure_3 @shoe_id=101,@presentation_id=1,@nhumber=500
---------------------------------------3---------------------------------------------------
GO
CREATE VIEW view_3
AS
SELECT w.women_name
FROM Women w INNER JOIN Women_Shoe ws on w.women_id=ws.women_id
INNER JOIN Shoes s on ws.shoe_id=s.shoe_id
GROUP BY s.shoe_model_id,w.women_name
HAVING SUM(ws.number_shoes)>=2
GO
SELECT* FROM Women
SELECT* FROM Shoes
SELECT * FROM Women_Shoe
SELECT* FROM view_3
---------------------------------------4----------------------------------------------------
GO
CREATE FUNCTION function_3(@t INT)
RETURNS @listshoe table(shoe_id INT)
AS
BEGIN
	IF @t >=1
	begin
	INSERT INTO @listshoe
	SELECT s.shoe_id
	FROM Presentation p INNER JOIN Shoe_Presentation sp on p.presentation_id=sp.presentation_id
	INNER JOIN Shoes s on s.shoe_id=sp.shoe_id
	group by s.shoe_id
	HAVING COUNT(*)>=@t
	end
	else 
	begin
	return
	end
RETURN
END
GO
SELECT* FROM Shoe_Presentation
SELECT* FROM function_3(2)
