# Mysql-code
World_layoffs data
# World Layoffs Data Cleaning and Exploratory Analysis

This project involves cleaning and performing exploratory data analysis (EDA) on a dataset containing information about global layoffs. The dataset is stored in MySQL, and the analysis is conducted using SQL queries.

## Table of Contents
- [Introduction](#introduction)
- [Dataset](#dataset)
- [Installation](#installation)
- [Data Cleaning](#data-cleaning)
- [Exploratory Data Analysis (EDA)](#exploratory-data-analysis-eda)

## INTRODUCTION

This project aims to provide insights into global layoffs by cleaning and analyzing the `World_layoffs` dataset. The data cleaning process involves handling missing values, correcting data types, and removing duplicates. Following the cleaning, exploratory data analysis is performed to uncover trends and patterns in the data.

## Dataset

The `World_layoffs` dataset contains information on layoffs across various industries and countries. The dataset includes the following columns:
- `Company`: Name of the company
- `Location`: Location of the company
- `Industry`: Industry to which the company belongs
- `Total_Laid_Off`: Number of employees laid off
- `Percentage_Laid_Off`: Percentage of the company’s workforce laid off
- `Date`: Date of the layoff event
- `Stage`: The company's stage
- `Country`: Country where the layoffs occurred
- `Funds_Raised`: Amount of funds raised by the company

## INSTALLATION

To replicate this project, you'll need to have MySQL installed on your machine.

1. Clone the repository:
   ```bash
   git clone https://github.com/Ajaniseun/Mysql-code.git
   
2.Import the World_layoffs dataset into MySQL:
LOAD DATA INFILE 'path_to_csv_file' INTO TABLE World_layoffs
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

## DATA CLEANING

The data cleaning process for this project was conducted using SQL queries to ensure the dataset is accurate, consistent, and ready for analysis. The steps involved are as follows:

1. REMOVING DUPLICATES:

To eliminate duplicate records, I used the ROW_NUMBER() function to identify duplicate rows based on the key attributes of each record. Duplicate rows were then removed to ensure that each entry in the dataset is unique.

WITH Duplicate_cte AS 
(SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging
)
SELECT *
FROM Duplicate_cte
WHERE row_num > 1;

After identifying duplicates, the data was inserted into a new table layoffs_staging2, and duplicates were removed using the following query:

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;



2. STANDARDIZING DATA:

Location Data: To ensure consistency in the `location` field, trailing periods were removed, and locations were standardized across the dataset.

UPDATE layoffs_staging2
SET location = TRIM(TRAILING '.' FROM location)
WHERE location LIKE 'Washington D.C%';


Date Format: The `date` column, initially stored as text, was converted to a `DATE` format for accurate date-based analysis.

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`Date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY `date` DATE;


3. REMOVING UNNECESSARY COLUMNS:

Once the data was cleaned and duplicates were removed, the `row_num` column used for duplicate detection was no longer necessary and was dropped from the table:

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


These steps ensured that the dataset was clean, standardized, and ready for further exploratory analysis.


## EXPLORATORY DATA ANALYSIS (EDA)

The EDA was conducted using a series of SQL queries to explore various aspects of the `World_layoff` dataset. The key queries include:

1. SUMMARY STATISTICS:

Max Values: Identifying the maximum number of employees laid off and the maximum percentage laid off in a single event.
Date Range: Determining the earliest and latest layoff dates in the dataset.

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

2. DETAILED EXPLORATION:

Full Data Overview: Displaying all records to inspect the data structure.
Largest Layoff Events: Identifying companies with layoffs where 100% of their workforce was laid off, ordered by total layoffs.

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

3. Aggregations and Grouping:

Company-Level Analysis: Summing total layoffs by company.
Industry-Level Analysis: Summing total layoffs by industry.
Country-Level Analysis: Summing total layoffs by country.
Yearly Trends: Summing total layoffs by year.
Stage Analysis: Summing total layoffs by company stage.

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry 
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country 
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off) AS total_laid_off_num
FROM layoffs_staging2
GROUP BY stage 
ORDER BY 2 DESC;

4. TREND ANALYSIS:

Monthly Layoffs: Summing layoffs by month to observe trends.
Rolling Totals: Calculating a rolling total of layoffs over time.

SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY SUBSTRING(`date`, 1,7)
ORDER BY 1 ASC;

WITH Rolling_total AS 
(SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY SUBSTRING(`date`, 1,7)
ORDER BY 1 ASC
)
SELECT MONTH, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total 
FROM Rolling_total;

5. TOP COMPANIES OF THE YEAR:

Company-Year Analysis: Ranking companies by total layoffs within each year.

WITH Company_Year (Company, Years, total_laid_off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY Years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
)
SELECT *
FROM company_Year_Rank
WHERE Ranking <= 5;


RESULTS:

The key findings from the analysis include:

Max Layoffs: Identification of the largest single layoff events by total number and percentage.
Industry and Country Insights: Which industries and countries experienced the highest layoffs.
Temporal Trends: How layoffs have trended over time, including rolling totals.
Top Companies: Ranking of companies with the highest layoffs per year.


CONTRIBUTING
If you'd like to contribute to this project, please fork the repository and submit a pull request. Contributions are welcome!

