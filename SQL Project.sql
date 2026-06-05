--DATA CLEANING--

USE [SQL Project];
WITH duplicate_CTE AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions ORDER BY (SELECT NULL)) row_num
FROM layoffs_staging
)

SELECT *
FROM duplicate_CTE 
WHERE row_num >1 ;

SELECT * FROM layoffs_staging
WHERE company IN ('Casper','Cazoo','Hibob','Oda','Terminus','Wildlife Studios','Yahoo')
ORDER BY company;

USE [SQL Project]
GO

/****** Object:  Table [dbo].[layoffs_staging]    Script Date: 04-05-2026 15:37:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[layoffs_staging2](
	[company] [nvarchar](50) NOT NULL,
	[location] [nvarchar](50) NOT NULL,
	[industry] [nvarchar](50) NULL,
	[total_laid_off] [nvarchar] (50) NULL,
	[percentage_laid_off] [nvarchar] (50) NULL,
	[date] [nvarchar](50) NOT NULL,
	[stage] [nvarchar](50) NOT NULL,
	[country] [nvarchar](50) NOT NULL,
	[funds_raised_millions] [nvarchar](50) NULL,
	[row_num] [int]
) ON [PRIMARY]
GO



INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions ORDER BY (SELECT NULL)) row_num
FROM layoffs_staging

SELECT * FROM
layoffs_staging2
WHERE row_num > 1

--Standardising Data--

SELECT DISTINCT(company)
FROM layoffs_staging2

SELECT company,TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company= TRIM(company);

SELECT DISTINCT(industry)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry= 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT(country),TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT DISTINCT(country)
FROM layoffs_staging2;

SELECT [date], TRY_CONVERT(DATE,[date],101)
FROM layoffs_staging2

-- Step 1
ALTER TABLE layoffs_staging2
ALTER COLUMN [date] VARCHAR(50) NULL

-- Step 2
UPDATE layoffs_staging2
SET [date] = TRY_CONVERT(DATE, [date])

-- Step 3
ALTER TABLE layoffs_staging2
ALTER COLUMN [date] DATE NULL

SELECT *FROM
layoffs_staging2
WHERE company LIKE 'Bally%%'

SELECT * FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company=t2.company
WHERE t1.industry IS NULL                                      --OR t1.industry =''
AND
t2.industry IS NOT NULL;

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL

SELECT * FROM 
layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL'

DELETE FROM layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL';

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL';

ALTER TABLE layoffs_staging2 
ALTER COLUMN percentage_laid_off float NULL;

-- Step 1: Clean the correct column
UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = 'NULL';

-- Step 2: Verify no bad data remains in total_laid_off
SELECT DISTINCT total_laid_off
FROM layoffs_staging2
WHERE ISNUMERIC(total_laid_off) = 0
  AND total_laid_off IS NOT NULL;

-- Step 3: Once Step 2 returns no rows, convert
ALTER TABLE layoffs_staging2 
ALTER COLUMN total_laid_off INT NULL;

UPDATE layoffs_staging2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL';

ALTER TABLE layoffs_staging2 
ALTER COLUMN funds_raised_millions DECIMAL(10,2) NULL;


--Exploratory Data Analysis--

SELECT MAX(total_laid_off),MAX(percentage_laid_off),MAX(funds_raised_millions) FROM
layoffs_staging2

SELECT * FROM 
layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC

SELECT country,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC

SELECT YEAR([date]), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR([date])
ORDER BY 2 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT SUBSTRING(CONVERT(nvarchar,date,120),6,2) as Month,SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(CONVERT(nvarchar,date,120),6,2) IS NOT NULL
GROUP BY SUBSTRING(CONVERT(nvarchar,date,120),6,2)
ORDER BY 2 DESC;


WITH Rolling_Total AS
(
    SELECT 
        SUBSTRING(CONVERT(nvarchar, date, 120), 1, 7) AS Month,
        SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(CONVERT(nvarchar, date, 120), 1, 7) IS NOT NULL
    GROUP BY SUBSTRING(CONVERT(nvarchar, date, 120), 1, 7)
    -- ❌ Removed ORDER BY from here
)
SELECT 
    Month,
    SUM(total_off) OVER(ORDER BY Month) AS rolling_total
FROM Rolling_Total
ORDER BY Month  -- ✅ ORDER BY belongs here, in the final SELECT

SELECT company,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 1 

SELECT company,YEAR(date),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(date)
ORDER BY 3 DESC

WITH Company_Year(company,years,total_laid_off) AS
(
SELECT company,YEAR(date),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(date)
),
Company_Year_Rank AS
(
SELECT * ,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * FROM Company_Year_Rank
WHERE Ranking <= 5

SELECT * FROM
layoffs_staging2
WHERE company ='Google'

WITH country_count (Country,Year,Total_Laid_Off) AS
(
SELECT country,YEAR(date),SUM(total_laid_off) FROM
layoffs_staging2
GROUP BY country,YEAR(date)
),
Country_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY YEAR ORDER BY Total_Laid_Off DESC) AS Rank
FROM country_count
WHERE YEAR IS NOT NULL
)
SELECT * FROM
Country_Year_Rank 
WHERE Rank <= 5

SELECT industry,SUM(total_laid_off),SUM(funds_raised_millions)
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC

WITH industry_layoffs (Industry,Year,Total_Layoffs) AS
(
SELECT industry,YEAR(date),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry,YEAR(date)
),
ind_rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY Year ORDER BY Total_Layoffs DESC) AS Ind_Rank
FROM industry_layoffs
WHERE Industry IS NOT NULL AND
Year IS NOT NULL
)
SELECT * FROM ind_rank
WHERE Ind_Rank <= 5