	CREATE DATABASE TradeAnalysisDB;
	GO

	USE TradeAnalysisDB;
	GO


	CREATE TABLE Client (
		ClientID INT PRIMARY KEY IDENTITY(1,1),
		ClientName NVARCHAR(100) NOT NULL,
		Country NVARCHAR(50)
	);

	CREATE TABLE Currency (
		CurrencyCode CHAR(3) PRIMARY KEY,
		CurrencyName NVARCHAR(50)
	);

	CREATE TABLE Trade (
		TradeID INT PRIMARY KEY IDENTITY(1,1),
		ClientID INT FOREIGN KEY REFERENCES Client(ClientID),
		CurrencyCode CHAR(3) FOREIGN KEY REFERENCES Currency(CurrencyCode),
		TradeDate DATE NOT NULL,
		Amount DECIMAL(18,2) NOT NULL,
		TradeType VARCHAR(10) CHECK (TradeType IN ('BUY','SELL'))
	);


	INSERT INTO Client (ClientName, Country) VALUES
	('Alpha Capital', 'USA'),
	('Beta Partners', 'France'),
	('Gamma Investments', 'UK'),
	('Delta Holdings', 'Germany'),
	('Omega Fund', 'Switzerland');

	INSERT INTO Currency (CurrencyCode, CurrencyName) VALUES
	('USD', 'US Dollar'),
	('EUR', 'Euro'),
	('GBP', 'British Pound'),
	('JPY', 'Japanese Yen'),
	('CHF', 'Swiss Franc'),
	('CAD', 'Canadian Dollar');

	INSERT INTO Trade (ClientID, CurrencyCode, TradeDate, Amount, TradeType) VALUES
	(1, 'USD', '2025-08-01', 500000, 'BUY'),
	(1, 'EUR', '2025-08-03', 300000, 'SELL'),
	(1, 'JPY', '2025-08-05', 250000, 'BUY'),
	(1, 'CHF', '2025-08-07', 400000, 'SELL'),
	(2, 'USD', '2025-08-02', 700000, 'SELL'),
	(2, 'GBP', '2025-08-04', 350000, 'BUY'),
	(2, 'CAD', '2025-08-06', 450000, 'BUY'),
	(2, 'EUR', '2025-08-08', 200000, 'SELL'),
	(3, 'JPY', '2025-08-01', 150000, 'BUY'),
	(3, 'CHF', '2025-08-03', 100000, 'SELL'),
	(3, 'USD', '2025-08-05', 600000, 'BUY'),
	(3, 'EUR', '2025-08-07', 250000, 'SELL'),
	(4, 'GBP', '2025-08-01', 300000, 'SELL'),
	(4, 'CAD', '2025-08-03', 200000, 'BUY'),
	(4, 'USD', '2025-08-05', 800000, 'BUY'),
	(4, 'JPY', '2025-08-07', 220000, 'SELL'),
	(5, 'CHF', '2025-08-02', 350000, 'BUY'),
	(5, 'EUR', '2025-08-04', 270000, 'SELL'),
	(5, 'USD', '2025-08-06', 900000, 'BUY'),
	(5, 'GBP', '2025-08-08', 400000, 'SELL'),
	(1, 'JPY', '2025-08-09', 320000, 'BUY'),
	(2, 'CHF', '2025-08-09', 280000, 'SELL'),
	(3, 'CAD', '2025-08-09', 370000, 'BUY'),
	(4, 'EUR', '2025-08-09', 410000, 'SELL'),
	(5, 'USD', '2025-08-09', 950000, 'BUY'),
	(1, 'GBP', '2025-08-10', 150000, 'SELL'),
	(2, 'USD', '2025-08-10', 550000, 'BUY'),
	(3, 'EUR', '2025-08-10', 290000, 'SELL'),
	(4, 'JPY', '2025-08-10', 180000, 'BUY'),
	(5, 'CHF', '2025-08-10', 200000, 'SELL'),
	(1, 'CAD', '2025-08-11', 260000, 'BUY'),
	(2, 'GBP', '2025-08-11', 330000, 'SELL'),
	(3, 'USD', '2025-08-11', 720000, 'BUY'),
	(4, 'EUR', '2025-08-11', 240000, 'SELL'),
	(5, 'JPY', '2025-08-11', 310000, 'BUY'),
	(1, 'CHF', '2025-08-12', 280000, 'SELL'),
	(2, 'USD', '2025-08-12', 660000, 'BUY'),
	(3, 'GBP', '2025-08-12', 400000, 'SELL'),
	(4, 'CAD', '2025-08-12', 270000, 'BUY'),
	(5, 'EUR', '2025-08-12', 500000, 'SELL'),
	(1, 'USD', '2025-08-13', 880000, 'BUY'),
	(2, 'JPY', '2025-08-13', 290000, 'SELL'),
	(3, 'CHF', '2025-08-13', 310000, 'BUY'),
	(4, 'GBP', '2025-08-13', 340000, 'SELL'),
	(5, 'CAD', '2025-08-13', 230000, 'BUY');



	-- 1. All trades for a given client between August 1 and August 10
	SELECT c.ClientName, t.CurrencyCode, t.Amount, t.TradeType, t.TradeDate
	FROM Trade t
	JOIN Client c ON t.ClientID = c.ClientID
	WHERE c.ClientName = 'Alpha Capital'
	  AND t.TradeDate between '2025-08-1' and '2025-08-10'

	-- 2. Top 5 currencies traded by total volume
	SELECT t.CurrencyCode, SUM(t.Amount) AS TotalVolume
	FROM Trade t
	GROUP BY t.CurrencyCode
	ORDER BY TotalVolume DESC

	-- 3. Biggest trade per client (using window functions)
	SELECT ClientName, CurrencyCode, Amount, TradeDate
	FROM (
		SELECT c.ClientName, t.CurrencyCode, t.Amount, t.TradeDate,
			   ROW_NUMBER() OVER (PARTITION BY c.ClientID ORDER BY t.Amount DESC) AS rn
		FROM Trade t
		JOIN Client c ON t.ClientID = c.ClientID
	) sub
	WHERE rn = 1;

	-- 4. Total BUY vs SELL per client
	SELECT c.ClientName,
		   SUM(CASE WHEN t.TradeType = 'BUY' THEN t.Amount ELSE 0 END) AS TotalBuys,
		   SUM(CASE WHEN t.TradeType = 'SELL' THEN t.Amount ELSE 0 END) AS TotalSells
	FROM Trade t
	JOIN Client c ON t.ClientID = c.ClientID
	GROUP BY c.ClientName;
