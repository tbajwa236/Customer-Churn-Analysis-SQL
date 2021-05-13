USE Telco_Churn;
GO


/* Question 1 - Are the active and non-active customers randomly distributed by the type of payment method that they use? */
WITH
Observed AS (
 SELECT
  [PaymentMethod],
  COUNT(*) AS [Total],
  SUM(1-[stopped]) AS [Active],
  SUM([stopped]) AS [NonActive]
 FROM (SELECT *, IIF([Churn] = 'Yes', 1, 0) as [stopped] 
	   FROM [dbo].[Telco Churn]) pm
       GROUP BY [PaymentMethod]
),
Rate AS (
 SELECT
   Observed.[PaymentMethod],
   Observed.[Active] * 1.0 / Observed.[Total] * 100 AS [Active Rate],
   Observed.[NonActive] * 1.0 / Observed.[Total] * 100 AS [Non Active Rate]
 FROM Observed
),
Total AS (
 SELECT
  'Total' AS [PaymentMethod],
   SUM(Observed.[Total]) AS [Total],
   SUM(Observed.[Active]) AS [Active],
   SUM(Observed.[NonActive]) AS [NonActive],
   SUM(Observed.[Active]) * 1.0 / SUM(Observed.[Total]) * 100 AS [Active Rate],
   SUM(Observed.[NonActive]) * 1.0 / SUM(Observed.[Total]) * 100 AS [Non Active Rate],
   NULL AS [Active Expected],
   NULL AS [Non Active Expected],
   NULL AS [Active Chi],
   NULL AS [Non Active Chi]
 FROM Observed
),
Expected AS (
 SELECT
   Observed.[PaymentMethod],
   Total.[Active Rate] * Observed.[Total] / 100 AS [Active Expected],
   Total.[Non Active Rate] * Observed.[NonActive] / 100 AS [Non Active Expected],
   POWER((Observed.[Active] - (Total.[Active Rate] * Observed.[Total] / 100)), 2) / (Total.[Active Rate] * Observed.[Total] / 100) AS [Active Chi],
   POWER((Observed.[NonActive] - (Total.[Non Active Rate] * Observed.[Total] / 100)), 2) / (Total.[Non Active Rate] * Observed.[Total] / 100) AS [Non Active Chi]
 FROM Observed, Total
)
SELECT
  Observed.*,
  Rate.[Active Rate], Rate.[Non Active Rate],
  Expected.[Active Expected], Expected.[Non Active Expected], Expected.[Active Chi], Expected.[Non Active Chi]
FROM Observed
JOIN Rate ON Observed.[PaymentMethod] = Rate.[PaymentMethod]
JOIN Expected ON Observed.[PaymentMethod] = Expected.[PaymentMethod]
UNION
SELECT * FROM Total
ORDER BY Observed.[PaymentMethod];
GO


/* Question 2 - Does customer churn depend upon the gender of the client? */
WITH
Observed AS (
 SELECT
  [gender],
  COUNT(*) AS [Total],
  SUM(1-[stopped]) AS [Active],
  SUM([stopped]) AS [NonActive]
 FROM (SELECT *, IIF([Churn] = 'Yes', 1, 0) as [stopped] 
	   FROM [dbo].[Telco Churn]) g
       GROUP BY [gender]
),
Rate AS (
 SELECT
   Observed.[gender],
   Observed.[Active] * 1.0 / Observed.[Total] * 100 AS [Active Rate],
   Observed.[NonActive] * 1.0 / Observed.[Total] * 100 AS [Non Active Rate]
 FROM Observed
),
Total AS (
 SELECT
  'Total' AS [gender],
   SUM(Observed.[Total]) AS [Total],
   SUM(Observed.[Active]) AS [Active],
   SUM(Observed.[NonActive]) AS [NonActive],
   SUM(Observed.[Active]) * 1.0 / SUM(Observed.[Total]) * 100 AS [Active Rate],
   SUM(Observed.[NonActive]) * 1.0 / SUM(Observed.[Total]) * 100 AS [Non Active Rate],
   NULL AS [Active Expected],
   NULL AS [Non Active Expected],
   NULL AS [Active Chi],
   NULL AS [Non Active Chi]
 FROM Observed
),
Expected AS (
 SELECT
   Observed.[gender],
   Total.[Active Rate] * Observed.[Total] / 100 AS [Active Expected],
   Total.[Non Active Rate] * Observed.[NonActive] / 100 AS [Non Active Expected],
   POWER((Observed.[Active] - (Total.[Active Rate] * Observed.[Total] / 100)), 2) / (Total.[Active Rate] * Observed.[Total] / 100) AS [Active Chi],
   POWER((Observed.[NonActive] - (Total.[Non Active Rate] * Observed.[Total] / 100)), 2) / (Total.[Non Active Rate] * Observed.[Total] / 100) AS [Non Active Chi]
 FROM Observed, Total
)
SELECT
  Observed.*,
  Rate.[Active Rate], Rate.[Non Active Rate],
  Expected.[Active Expected], Expected.[Non Active Expected], Expected.[Active Chi], Expected.[Non Active Chi]
FROM Observed
JOIN Rate ON Observed.[gender] = Rate.[gender]
JOIN Expected ON Observed.[gender] = Expected.[gender]
UNION
SELECT * FROM Total
ORDER BY Observed.[gender];
GO


/* Question 3 - Is there a relationship between customer churn and type of contract? */
WITH
Observed AS (
 SELECT
  [Contract],
  COUNT(*) AS [Total],
  SUM(1-[stopped]) AS [Active],
  SUM([stopped]) AS [NonActive]
 FROM (SELECT *, IIF([Churn] = 'Yes', 1, 0) as [stopped] 
	   FROM [dbo].[Telco Churn]) c
       GROUP BY [Contract]
),
Rate AS (
 SELECT
   Observed.[Contract],
   Observed.[Active] * 1.0 / Observed.[Total] * 100 AS [Active Rate],
   Observed.[NonActive] * 1.0 / Observed.[Total] * 100 AS [Non Active Rate]
 FROM Observed
),
Total AS (
 SELECT
  'Total' AS [Contract],
   SUM(Observed.[Total]) AS [Total],
   SUM(Observed.[Active]) AS [Active],
   SUM(Observed.[NonActive]) AS [NonActive],
   SUM(Observed.[Active]) * 1.0 / SUM(Observed.[Total]) * 100 AS [Active Rate],
   SUM(Observed.[NonActive]) * 1.0 / SUM(Observed.[Total]) * 100 AS [Non Active Rate],
   NULL AS [Active Expected],
   NULL AS [Non Active Expected],
   NULL AS [Active Chi],
   NULL AS [Non Active Chi]
 FROM Observed
),
Expected AS (
 SELECT
   Observed.[Contract],
   Total.[Active Rate] * Observed.[Total] / 100 AS [Active Expected],
   Total.[Non Active Rate] * Observed.[NonActive] / 100 AS [Non Active Expected],
   POWER((Observed.[Active] - (Total.[Active Rate] * Observed.[Total] / 100)), 2) / (Total.[Active Rate] * Observed.[Total] / 100) AS [Active Chi],
   POWER((Observed.[NonActive] - (Total.[Non Active Rate] * Observed.[Total] / 100)), 2) / (Total.[Non Active Rate] * Observed.[Total] / 100) AS [Non Active Chi]
 FROM Observed, Total
)
SELECT
  Observed.*,
  Rate.[Active Rate], Rate.[Non Active Rate],
  Expected.[Active Expected], Expected.[Non Active Expected], Expected.[Active Chi], Expected.[Non Active Chi]
FROM Observed
JOIN Rate ON Observed.[Contract] = Rate.[Contract]
JOIN Expected ON Observed.[Contract] = Expected.[Contract]
UNION
SELECT * FROM Total
ORDER BY Observed.[Total];
GO


/* Question 4 - What is the conditional probability of customer churn given a particular contract type and payment method? */
WITH 
ContractDim AS (
  SELECT 
   [Contract],
   AVG(IIF([Churn] = 'Yes', 1.0, 0)) AS prob
  FROM [dbo].[Telco Churn]
  GROUP BY [Contract]
),
PaymentMethodDim AS (
  SELECT 
   [PaymentMethod],
   AVG(IIF([Churn] = 'Yes', 1.0, 0)) AS prob
  FROM [dbo].[Telco Churn]
  GROUP BY [PaymentMethod]
),
Overall AS (
  SELECT
   AVG(IIF([Churn] = 'Yes', 1.0, 0)) AS prob
  FROM [dbo].[Telco Churn]
),
Actual AS (
  SELECT 
   [Contract],
   [PaymentMethod],
   AVG(IIF([Churn] = 'Yes', 1.0, 0)) AS prob
  FROM [dbo].[Telco Churn]
  GROUP BY [Contract], [PaymentMethod]
)
SELECT
 [Contract],
 [Contract Probability],
 [PaymentMethod],
 [PaymentMethod Probability],
 [Predicted Probability],
 [Actual Probability]
FROM (
 SELECT
   ContractDim.[Contract],
   ContractDim.[prob] AS [Contract Probability],
   PaymentMethodDim.[PaymentMethod],
   PaymentMethodDim.[prob] AS [PaymentMethod Probability],
   POWER(Overall.[prob], -1) * ContractDim.[prob] * PaymentMethodDim.[prob] AS [Predicted Probability],
   Actual.prob AS [Actual Probability]
 FROM ContractDim
 CROSS JOIN PaymentMethodDim
 CROSS JOIN Overall
 JOIN Actual
 ON ContractDim.[Contract] = Actual.[Contract]
 AND PaymentMethodDim.[PaymentMethod] = Actual.[PaymentMethod]
) dim
ORDER BY [Contract], [PaymentMethod];

GO

