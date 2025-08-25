# Trade Analysis Database

## Project Overview
**Trade Analysis Database** is a sample project that demonstrates SQL skills relevant for a Technical Analyst role.  
The project simulates a small-scale trading system with clients, currencies, and trades. It includes analytical queries to extract insights such as top trades, total volumes, and recent client activity.

---

## Database Schema

**Database Name:** `TradeAnalysisDB`

### Tables

**Client**
| Column     | Type           | Key             | Description                  |
|------------|----------------|----------------|------------------------------|
| ClientID   | INT            | PK, Identity    | Unique client identifier     |
| ClientName | NVARCHAR(100)  | Not null        | Name of the client           |
| Country    | NVARCHAR(50)   | Nullable        | Client country               |

**Currency**
| Column       | Type           | Key  | Description               |
|--------------|----------------|------|---------------------------|
| CurrencyCode | CHAR(3)        | PK   | ISO currency code         |
| CurrencyName | NVARCHAR(50)   |      | Full name of the currency |

**Trade**
| Column       | Type           | Key/Constraint                   | Description                       |
|--------------|----------------|---------------------------------|-----------------------------------|
| TradeID      | INT            | PK, Identity                     | Unique trade ID                   |
| ClientID     | INT            | FK → Client(ClientID)            | Client performing the trade       |
| CurrencyCode | CHAR(3)        | FK → Currency(CurrencyCode)      | Currency of the trade             |
| TradeDate    | DATE           | Not null                         | Date of the trade                 |
| Amount       | DECIMAL(18,2)  | Not null                         | Trade amount                       |
| TradeType    | VARCHAR(10)    | CHECK (BUY/SELL)                 | Type of trade                      |

### Relationships
- Each `Trade` belongs to one `Client` and one `Currency`.
- Foreign keys enforce referential integrity.

---

## Sample Data
- **Clients:** 5 sample clients from different countries.  
- **Currencies:** 6 common currencies (USD, EUR, GBP, JPY, CHF, CAD).  
- **Trades:** ~50 trades covering multiple clients, currencies, dates, and trade types (`BUY`/`SELL`).

---

## Example Queries

### 1. All trades for a client in the last 7 days

```sql
SELECT c.ClientName, t.CurrencyCode, t.Amount, t.TradeType, t.TradeDate
FROM Trade t
JOIN Client c ON t.ClientID = c.ClientID
WHERE c.ClientName = 'Alpha Capital'
  AND t.TradeDate >= DATEADD(DAY, -7, GETDATE());
```
### 2. Top 5 currencies traded by total volume

```sql
SELECT t.CurrencyCode, SUM(t.Amount) AS TotalVolume
FROM Trade t
GROUP BY t.CurrencyCode
ORDER BY TotalVolume DESC
```
### 3. Biggest trade per client

```sql
SELECT ClientName, CurrencyCode, Amount, TradeDate
FROM (
    SELECT c.ClientName, t.CurrencyCode, t.Amount, t.TradeDate,
           ROW_NUMBER() OVER (PARTITION BY c.ClientID ORDER BY t.Amount DESC) AS rn
    FROM Trade t
    JOIN Client c ON t.ClientID = c.ClientID
) sub
WHERE rn = 1;
```
### 4. Total BUY vs SELL per client

```sql
SELECT c.ClientName,
       SUM(CASE WHEN t.TradeType = 'BUY' THEN t.Amount ELSE 0 END) AS TotalBuys,
       SUM(CASE WHEN t.TradeType = 'SELL' THEN t.Amount ELSE 0 END) AS TotalSells
FROM Trade t
JOIN Client c ON t.ClientID = c.ClientID
GROUP BY c.ClientName;
```
