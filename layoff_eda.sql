-- Short view of dataset
SELECT * FROM layoffs
LIMIT 10;

-- Row count
SELECT COUNT(*) AS total_rows FROM layoffs;

-- Duplicates
SELECT company, location, date, COUNT(*)
FROM layoffs
GROUP BY company, location, date
HAVING COUNT(*) >1;

-- Nulls
-- null=1, no_null=0. In case of null appearing total count/sum = 1, indicating null val
SELECT
	SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS company_nulls,
	SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS location_nulls,
	SUM(CASE WHEN industry IS NULL THEN 1 ELSE 0 END) AS industry_nulls,
	SUM(CASE WHEN total_laid_off IS NULL THEN 1 ELSE 0 END) AS total_laid_off_nulls,
	SUM(CASE WHEN percentage_laid_off IS NULL THEN 1 ELSE 0 END) AS percentage_laid_off_nulls,
	SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS date_nulls,
	SUM(CASE WHEN stage IS NULL THEN 1 ELSE 0 END) AS stage_nulls,
	SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
	SUM(CASE WHEN funds_raised_millions IS NULL THEN 1 ELSE 0 END) AS funds_raised_millions_nulls
FROM layoffs;

-- totals of overall layoffs
SELECT
	SUM(total_laid_off) AS total_laid_off_sum,
	AVG(total_laid_off) AS avg_laid_off,
	MAX(total_laid_off) AS max_laid_off,
	MIN(total_laid_off) AS min_laid_off
FROM layoffs;

-- average and max as percentages
-- note:PostgreSQL requires arguments to be compatible types for ROUND().
SELECT
  ROUND(AVG(percentage_laid_off::numeric * 100), 2) AS avg_percent_laid_off,
  ROUND(MAX(percentage_laid_off::numeric * 100), 2) AS max_percent_laid_off
FROM layoffs
WHERE percentage_laid_off IS NOT NULL;

-- Grouped layoff insight

-- by country

SELECT
  country,
  SUM(total_laid_off) AS total_laid_offs,
  COUNT(*) AS num_companies
FROM layoffs
GROUP BY country
ORDER BY total_laid_offs DESC;

-- by industry
SELECT
  industry,
  SUM(total_laid_off) AS total_laid_offs,
  AVG(percentage_laid_off) AS avg_pct_laid_off
FROM layoffs
GROUP BY industry
ORDER BY total_laid_offs DESC;

-- by 'time data'
-- first convert date column to a data type
ALTER TABLE layoffs
ALTER COLUMN date TYPE DATE USING TO_DATE(date, 'MM/DD/YYYY');

-- check layoffs over time
SELECT
 date,
 SUM(total_laid_off) AS total_laid_offs
 FROM layoffs
 GROUP BY date
 ORDER BY date;

-- monthly layoffs
SELECT 
 DATE_TRUNC('month', date) AS month,
 SUM(total_laid_off) AS total_laid_offs
 FROM layoffs
 GROUP BY month
 ORDER BY month;

-- month with peak layoff
SELECT
  DATE_TRUNC('month', date) AS month,
  SUM(total_laid_off) AS total_laid_offs
FROM layoffs
GROUP BY month
ORDER BY total_laid_offs DESC
LIMIT 1;

-- companies with most layoffs, only top 10
SELECT company
FROM layoffs
ORDER BY total_laid_off DESC
LIMIT 10;

-- industries with most layoffs
SELECT industry
FROM layoffs
ORDER BY total_laid_off DESC
LIMIT 10
;

-- funds
-- funds raised by industry
SELECT
  industry,
  ROUND(AVG(funds_raised_millions::numeric), 2) AS avg_funds
FROM layoffs
GROUP BY industry
ORDER BY avg_funds DESC;

-- funds raised by company
SELECT
  company,
  ROUND(AVG(funds_raised_millions::numeric), 2) AS avg_funds
FROM layoffs
GROUP BY company
ORDER BY avg_funds DESC;

-- layoffs / funds raised
SELECT
  company,
  funds_raised_millions,
  total_laid_off,
 ROUND(
    CASE 
      WHEN funds_raised_millions = 0 THEN NULL
      ELSE (total_laid_off / funds_raised_millions)::numeric
    END,
    2
  ) AS layoffs_per_million
FROM layoffs
WHERE funds_raised_millions IS NOT NULL
ORDER BY layoffs_per_million DESC;





 