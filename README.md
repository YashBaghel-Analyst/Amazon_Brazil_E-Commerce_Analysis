# Amazon Brazil E-Commerce Analysis — SQL Case Study (Milestone 2)

## Project Overview

Amazon connects small and medium businesses with millions of customers in Brazil. Because Brazil and India share large, diverse consumer bases and rapidly growing digital commerce, analyzing Amazon Brazil's transaction data provides practical insights that can inform Amazon India's payment, pricing, retention, and merchandising decisions.

This project uses **PostgreSQL** and **Excel** to answer **19 business questions** across three analytical phases—covering payment behavior, product pricing, catalog data quality, customer retention, category revenue, seasonality, and 2018 monthly growth trends.

---

## Business Problem

To guide Amazon India's growth strategy using Amazon Brazil's benchmark data, this analysis focuses on four core operational questions:

1. **Payment Strategy:** Which payment methods drive the highest order volume, average transaction value, and stability across low, medium, and high-value orders?
2. **Pricing & Catalog Quality:** Which product categories show the widest price spreads or highest revenue, and where do missing or malformed category names hurt reporting?
3. **Customer Retention & Loyalty:** How many customers place repeat orders, and how should a loyalty or VIP rewards program be structured?
4. **Seasonality & Growth Trends:** Which months and seasons generate peak revenue, and how do different payment methods grow month-over-month?

---

## Dataset Summary

| Attribute | Details |
| :--- | :--- |
| **Database Tables Analyzed** | `payments`, `orders`, `order_items`, `product`, `customers` |
| **Total Queries Executed** | 19 SQL queries across 3 phases (Analysis I: 7, Analysis II: 5, Analysis III: 7) |
| **Order Volume (Loyalty CTE)** | 99,441 total orders analyzed across customer frequency tiers |
| **Currency** | Brazilian Real (BRL) |
| **Time Window Highlighted** | Multi-year seasonal rollup + 2018 monthly revenue & MoM trend analysis (Jan–Oct 2018; sharp cutoff after August) |

---

## Tools & Tech Stack

- **Database / Querying:** PostgreSQL (aggregations, joins, subqueries, CTEs, window functions such as `DENSE_RANK()`, `SUM() OVER`, and `LAG()`)
- **Spreadsheet & Charting:** Microsoft Excel (Pivot Tables, MoM comparison tables, bar and line charts)
- **Documentation:** Formal PDF Findings & Suggestions Report

---

## SQL Analysis Workflow (Steps Taken)

1. **Analysis I — Fundamental Patterns (Queries 1.1–1.7):** Standardized average payment values by method, calculated order-share percentages using window sums, filtered mid-range "smart" products (100–500 BRL), identified top 3 sales months, flagged categories with >500 BRL price spreads, measured payment standard deviation, and audited missing (`NULL`) or single-character category names.
2. **Analysis II — Segmentation & Revenue (Queries 2.1–2.5):** Segmented orders into Low (<200 BRL), Medium (200–1,000 BRL), and High (>1,000 BRL) tiers by payment type, computed min/max/average prices per category, isolated repeat buyers (`>1` order), classified customers into `New`, `Returning`, and `Loyal` cohorts, and ranked the top 5 revenue-generating categories.
3. **Analysis III — Deeper Trends & Growth (Queries 3.1–3.7):** Aggregated sales by season via subqueries, filtered above-average volume SKUs for inventory planning, built 2018 monthly revenue trends and Excel charts, segmented loyalty tiers using CTEs, ranked top 20 customers by AOV with `DENSE_RANK()`, tracked product cumulative sales, and computed 2018 month-over-month (MoM) growth by payment method using `LAG()`.

---

## Key Findings

### Payment Behavior & Order Value Segments

| Payment Type | Order Share | Avg Payment Value | Std Deviation | Low (<200) | Medium (200–1000) | High (>1000) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **credit_card** | 75.2% | 163 BRL | 222.12 BRL | 60,548 | 15,303 | 944 |
| **boleto** | 19.5% | 145 BRL | 213.58 BRL | 16,444 | 3,162 | 178 |
| **voucher** | 3.8% | 65 BRL | 115.52 BRL | 5,476 | 286 | 13 |
| **debit_card** | 1.5% | 142 BRL | 245.79 BRL | 1,287 | 227 | 15 |

### Top 5 Revenue-Generating Categories

| Rank | Product Category | Total Revenue (BRL) |
| :--- | :--- | :--- |
| **1** | `cama_mesa_banho` (Bed, Bath & Table) | 1,706,393.64 |
| **2** | `beleza_saude` (Health & Beauty) | 1,656,408.68 |
| **3** | `informatica_acessorios` (IT Accessories) | 1,583,703.92 |
| **4** | `moveis_decoracao` (Furniture & Decor) | 1,429,063.39 |
| **5** | `relogios_presentes` (Watches & Gifts) | 1,427,210.78 |

### Seasonality, Loyalty & High-Value Highlights

| Area | Key Metric / Finding |
| :--- | :--- |
| **Top 3 Sales Months** | May (1,746,901 BRL), August (1,696,822 BRL), July (1,658,924 BRL) |
| **Seasonal Sales** | Spring (4.93M BRL) and Summer (4.89M BRL) lead Winter (3.42M) and Autumn (2.77M) |
| **2018 Monthly Trend** | Stable 992K–1.16M BRL/month (Jan–Aug), peaking in Mar–May; sharp >99% drop in Sep–Oct due to dataset cutoff |
| **Loyalty Segments** | Occasional (1–2 orders): 97.88% (97,333 orders); Regular (3–5): 1.13% (1,128); Loyal (>5): 0.99% (980) |
| **Top 20 AOV Customers** | Range from 3,782.19 BRL (Rank 20) up to 13,664.08 BRL (Rank 1) |
| **Catalog Data Quality** | Uncategorized (`[null]`) products rank 9th in price spread (3,977.00 BRL); single-character category names (e.g., `w`) also exist |

---

## Business Recommendations

1. **Adopt a Two-Track Payment Strategy for India:** Prioritize credit-card and EMI installment options on Medium and High-value carts (where credit cards dominate), while optimizing fast, low-friction alternatives (like UPI) for high-volume Low-value orders.
2. **Focus Loyalty Rewards on 2nd & 3rd Purchases:** Because 97.88% of orders come from Occasional buyers (1–2 orders), structure loyalty milestones around converting first-time buyers into repeat customers rather than rewarding only >5-order VIPs.
3. **Prioritize High-Volume Everyday Categories:** Invest in seller depth, fast delivery, and cross-selling in everyday categories (`cama_mesa_banho`, `beleza_saude`, `informatica_acessorios`), which outperform high-unit-price categories (`pcs`) in total revenue.
4. **Fix Catalog Data Hygiene:** Backfill `[null]` and single-character category names and enforce mandatory category validation during seller onboarding to improve search and reporting accuracy.
5. **Pair AOV with Frequency Before Launching VIP Programs:** Review order count, cancellation status, and category mix for the top 20 AOV customers before granting exclusive rewards to separate one-time bulk buyers from recurring high-value shoppers.

---

## Data Limitations & SQL Caveats

- **2018 Cutoff Bias:** September (4,439.54 BRL) and October (589.67 BRL) 2018 show a >99% drop caused by partial/cutoff data after August 2018; exclude incomplete months when forecasting.
- **Query Refinement Opportunities:**
  - *Category Revenue Attribution (Query 2.5):* Joining `payments` directly to `order_items` can overcount payment value on multi-item orders; validating with item-level `price + freight_value` is recommended.
  - *Cumulative Product Sales (Query 3.6):* Ordering the window function chronologically by year and month (rather than `monthly_sales`) is needed for true time-series lifecycle tracking.
  - *Loyalty Segmentation (Query 3.4):* The Excel pivot summarizes total orders (`99,441`) per segment; pairing this with distinct customer counts gives a fuller retention picture.
