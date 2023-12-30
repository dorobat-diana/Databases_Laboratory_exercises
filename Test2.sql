CREATE DATABASE Test2
GO
USE Test2 
GO
---------------------------II-----------------------------
---------------------------1------------------------------
CREATE TABLE Customer(
	customer_id INT,
	name VARCHAR(200),
	date_of_birth DATE,
	CONSTRAINT PK_customer PRIMARY KEY(customer_id)
);
CREATE TABLE Bank_account(
	bank_acc_id INT,
	iban VARCHAR(100),
	balance DECIMAL(15,2),
	customer_id INT,
	CONSTRAINT PK_bank_acc PRIMARY KEY(bank_acc_id),
	CONSTRAINT FK_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
CREATE TABLE Cards(
	card_id INT,
	number INT,
	CVV TINYINT,
	bank_acc_id INT,
	CONSTRAINT PK_cards PRIMARY KEY(card_id),
	CONSTRAINT FK_banck_acc FOREIGN KEY(bank_acc_id) REFERENCES Bank_account(bank_acc_id)
);
ALTER TABLE Cards
ALTER COLUMN CVV INT
CREATE TABLE ATM(
	atm_id INT,
	atm_address VARCHAR(200),
	CONSTRAINT PK_atm PRIMARY KEY (atm_id)
);
CREATE TABLE Transactions(
	transaction_id INT,
	atm_id INT,
	CONSTRAINT PK_transation PRIMARY KEY(transaction_id),
	CONSTRAINT FK_atm FOREIGN KEY(atm_id) REFERENCES ATM(atm_id),
	sum_money DECIMAL(15,2),
	card_id INT,
	CONSTRAINT FK_card FOREIGN KEY(card_id) REFERENCES Cards(card_id),
	transation_time DATETIME
);
-----------------------------2------------------------------------------
GO
CREATE PROCEDURE procedure_2(@card_id INT)
AS
BEGIN
	DELETE FROM Transactions 
	WHERE card_id=@card_id
END
GO
-- Inserting sample data into Customer table
INSERT INTO Customer (customer_id, name, date_of_birth)
VALUES
(1, 'John Doe', '1990-05-15'),
(2, 'Jane Smith', '1985-09-20');

-- Inserting sample data into Bank_account table
INSERT INTO Bank_account (bank_acc_id, iban, balance, customer_id)
VALUES
(101, 'US123456789', 5000.00, 1),
(102, 'UK987654321', 7500.50, 2);

-- Inserting sample data into Cards table
INSERT INTO Cards (card_id, number, CVV, bank_acc_id)
VALUES
(1001, 123456789, 123, 101),
(1002, 987654321, 456, 102);

-- Inserting sample data into ATM table
INSERT INTO ATM (atm_id, atm_address)
VALUES
(201, '123 Main Street'),
(202, '456 Elm Street');

-- Inserting sample data into Transactions table
INSERT INTO Transactions (transaction_id, atm_id, sum_money, card_id, transation_time)
VALUES
(5000,202,400.00,1001,'2022-02-02 12:45:00'),
(5001, 201, 100.00, 1001, '2023-01-10 08:30:00'),
(5002, 202, 50.50, 1002, '2023-01-11 12:45:00'),
(5003, 201, 500.00, 1002, '2023-01-12 13:50:00');

SELECT* FROM Transactions
EXEC procedure_2 @card_id=1002
----------------------------3------------------------------------------
GO
CREATE VIEW view_card_numbers
AS
SELECT c.number
FROM Cards c
WHERE c.card_id=ANY(
SELECT c2.card_id
FROM Cards c2
INNER JOIN Transactions t ON t.card_id=c2.card_id
INNER JOIN ATM a ON t.atm_id=a.atm_id
GROUP BY c2.card_id
HAVING COUNT(*)=(SELECT COUNT(*)
				FROM ATM)
)
GO
SELECT* FROM ATM
SELECT * FROM Cards
SELECT* FROM view_card_numbers
-----------------------------4-------------------------------------------
GO
CREATE FUNCTION function_4()
RETURNS @listcards table(number INT,cvv INT )
AS
BEGIN 
	INSERT INTO @listcards
	SELECT c.number,c.CVV
	FROM Cards c
	where c.card_id= any(
	SELECT t.card_id
	FROM Transactions t
	GROUP BY t.card_id
	HAVING SUM(t.sum_money)>2000.00) 
	RETURN
END 
GO
SELECT *
FROM function_4()
SELECT* FROM Cards
SELECT* FROM Transactions
INSERT INTO Transactions VALUES(5004,202,2000.00,1001,'2023-02-20 17:00:00')
