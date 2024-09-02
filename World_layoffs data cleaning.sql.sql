-- Data Cleaning

-- 1. Remove Duplicate
-- 2. standardize the data
-- 3. Remove any columns

USE world_layoffs;
SELECT * 
FROM layoffs_staging;

SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging;

WITH Duplicate_cte AS 
(SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging
)
SELECT *
FROM Duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` double DEFAULT NULL,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` int DEFAULT NULL,
   `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2 
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- Standardize the data

SELECT DISTINCT location
FROM layoffs_staging2 
WHERE location LIKE 'Non-U.S%'
order by 1;

SELECT DISTINCT location
FROM layoffs_staging2 
ORDER BY 1;

SELECT DISTINCT location, TRIM(TRAILING '.' FROM location)
FROM layoffs_staging2
Order by 1;

UPDATE layoffs_staging2
SET location = TRIM(TRAILING '.' FROM location)
WHERE location LIKE 'Washington D.C%';

SELECT `date`,
STR_TO_DATE(`Date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`Date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY `date` DATE;


SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
