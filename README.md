# Post-Covid-Layoffs
SQL Project analyzing layoffs by region and companies


# 🌍 Post-COVID Global Layoffs Analysis (2020–2023)

## Project Overview
This project performs end-to-end data cleaning and exploratory data analysis (EDA) on a global layoffs dataset covering 2,500+ records across 2020–2023. The goal was to clean raw, inconsistent data and uncover meaningful trends across companies, industries, and countries during the COVID-19 pandemic and the subsequent tech sector correction.

## Tools & Technologies
- **Microsoft SQL Server**
- **CTEs (Common Table Expressions)**
- **Window Functions** (ROW_NUMBER, DENSE_RANK, SUM OVER)
- **Data Type Conversion & Standardisation**

## Dataset
- **Source:** Kaggle — Global Layoffs Dataset
- **Records:** 2,500+
- **Period:** March 2020 – March 2023
- **Fields:** Company, Location, Industry, Total Laid Off, Percentage Laid Off, Date, Stage, Country, Funds Raised (Millions)

## Part 1 — Data Cleaning
The raw dataset contained several quality issues that were systematically resolved:

- **Removed duplicate records** using ROW_NUMBER() partitioned across all key columns
- **Trimmed whitespace** from company names using TRIM()
- **Standardised industry names** (e.g. consolidated "Crypto Currency", "CryptoCurrency" → "Crypto")
- **Cleaned country names** (e.g. removed trailing periods from "United States.")
- **Converted date column** from string to DATE format using TRY_CONVERT()
- **Populated missing industry values** using self-JOIN on company name
- **Removed rows** where both total_laid_off and percentage_laid_off were NULL
- **Converted data types** for total_laid_off (INT), percentage_laid_off (FLOAT), and funds_raised_millions (DECIMAL)

## Part 2 — Exploratory Data Analysis

### 📈 Rolling Total of Global Layoffs
Tracked cumulative layoffs month-on-month using CTEs and SUM window functions:

| Period | Cumulative Layoffs |
|--------|-------------------|
| Mar 2020 | 9,698 |
| Dec 2021 | 96,891 |
| Dec 2022 | 258,602 |
| Mar 2023 | 385,879 |

> Total of 376,000+ job losses over 3 years — driven by COVID-19 and the post-pandemic tech correction.

### 🏢 Top 5 Companies by Layoffs Per Year

| Year | #1 | #2 | #3 |
|------|----|----|-----|
| 2020 | Uber (7,525) | Booking.com (4,375) | Groupon (2,800) |
| 2021 | Bytedance (3,600) | Katerra (2,434) | Zillow (2,000) |
| 2022 | Meta (11,000) | Amazon (10,150) | Cisco (4,100) |
| 2023 | Google (12,000) | Microsoft (10,000) | Ericsson (8,500) |

### 🌏 Top 5 Countries by Layoffs Per Year
- **United States** dominated all 4 years, peaking at 106,520 in 2022
- **India** consistently ranked 2nd across all years
- **Netherlands** appeared in the top 5 three out of four years

### 🏭 Top Industries by Layoffs Per Year
- **2020:** Transportation & Travel hardest hit (COVID-19 immediate impact)
- **2022–2023:** Consumer & Retail emerged as dominant sectors (post-pandemic correction)
- **Healthcare** appeared in top 5 across both 2022 and 2023

## Key Insights
1. Global layoffs escalated dramatically from 9,698 in March 2020 to 385,879 by March 2023
2. The most severe spike occurred between November 2022 and January 2023 — over 95,000 layoffs in two months
3. Big Tech (Meta, Google, Amazon, Microsoft) dominated the 2022–2023 correction period
4. The United States accounted for the majority of global layoffs across all four years
5. Industry impact shifted from Travel/Transportation in 2020 to Consumer/Retail by 2023

---

That's your full README! Copy this into a file called `README.md` in your GitHub repository alongside your SQL file and it'll look really professional.

Want me to write the Bellabeat README as well?
