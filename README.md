# ABS Retail Turnover Analysis — SQL, Python & Tableau

Analysis of Australian Bureau of Statistics (ABS) Retail Trade data, exploring national turnover trends, industry and state-level growth, and seasonality patterns using SQL for querying, Python for trend/seasonality modelling, and Tableau for visualisation.

**[View the live dashboard on Tableau Public →](https://public.tableau.com/app/profile/vanessa.li4568/viz/ABSRetailTurnoverDashboard/RetailTurnoverDashboard)**

## Data Source

- **Table 1** — Retail turnover, by industry group (national, monthly, 1982–2025)
- **Table 11** — Retail turnover, state by industry subgroup (monthly, 1982–2025)

Sourced from the [ABS Retail Trade release](https://www.abs.gov.au/statistics/industry/retail-and-wholesale-trade/retail-trade-australia). Only the "Original" series type was retained (excluding Seasonally Adjusted and Trend series, which are separate parallel series in the raw files) to avoid double-counting.

## Project Structure

```
abs-retail-turnover-analysis/
├── data/
│   ├── raw/            # Original ABS xlsx downloads
│   └── clean/          # Cleaned, long-format CSVs
├── notebooks/
│   ├── abs_retail_data_cleaning.ipynb      # Reshapes ABS data into long format
│   └── abs_retail_trend_analysis.ipynb     # Trend decomposition & growth analysis
├── sql/
│   └── Code.sql         # Business-question queries
└── README.md
```

## Business Questions

**Overall Trend**
- What's the national retail turnover trend by year?
- What's the year-over-year growth rate?

**Industry Performance**
- Which industry has the highest total turnover?
- Which industry grew fastest over the full time series?
- What's the year-over-year growth trend for each industry?

**State Performance**
- Which state has the highest total turnover?
- Which state grew fastest?
- Which industry subgroup dominates in each state?

**Seasonality**
- What's the average turnover by month nationally?
- Which industries show the strongest seasonal swing (peak vs trough)?

## Key Findings

- **National turnover** grew from ~$66M (1982) to over $600M by 2024, with visible acceleration post-2020.
- **Cafes, restaurants and takeaway food services** was the fastest-growing industry (~1,360% growth over the full series), and also the most seasonal — turnover peaks roughly 13% above trend every December.
- **Queensland** was the fastest-growing state (~1,282%), narrowly ahead of Western Australia, with smaller states/territories generally showing higher percentage growth off a lower base than NSW/Victoria.
- **Food retailing** is the dominant industry subgroup in every state.
- December is the strongest month nationally across almost all industries, consistent with holiday-season retail spending.

## Tools & Approach

- **Python (pandas)** — reshaped ABS's wide-format spreadsheets into long-format data, handling the multi-series-type structure and cleaning inconsistent typing.
- **PostgreSQL** — loaded cleaned data into two fact tables (`retail_turnover_industry`, `retail_turnover_state_industry`) and queried using window functions (`LAG`, `RANK`, `FILTER`) for growth and ranking calculations.
- **Python (statsmodels)** — multiplicative seasonal decomposition to separate trend, seasonal, and residual components; growth-rate ranking across industries and states.
- **Tableau Public** — interactive dashboard combining the yearly trend, industry and state growth rankings, and seasonality curve.

## Notes

- 2025 figures are partial (data through June 2025 only) and excluded from year-over-year growth comparisons to avoid understating that year.
- The "Total (Industry)" and "Total (State)" aggregate rows in the raw ABS data are excluded from ranking queries to avoid them appearing as spurious "top" results.
