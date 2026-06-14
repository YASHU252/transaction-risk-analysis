# Transaction Anomaly & Fraud Risk Detection

A fraud risk scoring system built to help fraud operations teams reduce manual investigation workload while maximising the proportion of genuine fraud caught. Built using Python, SQL, and Power BI across a dataset of 1.3 million real-world-style credit card transactions.

---

## The Problem

Fraud operations teams face a fundamental triage problem: every suspicious transaction needs to be reviewed, but manual review capacity is finite. Without a risk scoring system, investigators either miss fraud (by reviewing too little) or burn out on false alarms (by reviewing too much).

This project builds a transparent, explainable risk scoring pipeline that surfaces the most suspicious transactions first — reducing investigator workload while maximising fraud catch rates. All signals are fully interpretable, satisfying the auditability requirements typical of banking risk governance frameworks.

---

## Key Findings

- Transactions above **$196 (95th percentile)** have a fraud rate of **~8.8%** vs. **0.15%** for normal transactions — a **60× lift**
- Late-night transactions (10 PM – 3 AM) show **10–20× higher fraud rates** than daytime hours
- Transactions triggering **both** risk signals (high amount + odd hour) have a fraud rate of **25.6%** — capturing a disproportionate share of fraud in just 1.5% of total volume
- The Isolation Forest model assigns an average risk score of **73.4** to fraudulent transactions vs. **20.4** for legitimate ones — clear separation with no fraud labels used in training
- At a risk threshold of 90+, the model achieves **59% precision** using only unsupervised signals

---

## Product Impact

### What this analysis enables

Three operational product decisions this risk scoring pipeline directly supports:

**1. Tiered investigation queue**
Score-2 transactions represent 1.5% of volume but carry a 25.6% fraud rate vs. 0.03% for score-0. Investigators work the high-risk bucket first — a ~853× improvement in review efficiency over random sampling.

**2. Automated hold trigger**
Transactions scoring 90+ on the Isolation Forest scale (59% precision, zero label leakage) could trigger a real-time card hold + customer SMS alert, reducing fraud loss before manual review begins. The threshold is tunable against the organisation's acceptable false-positive rate.

**3. Investigator workload planning**
The 1.5% high-risk volume figure gives operations managers a predictable daily queue size, enabling FTE forecasting for the fraud ops team.

### How success would be measured

| Metric | Definition | Target Direction |
|---|---|---|
| Fraud catch rate | % of all fraud cases that fall in the reviewed queue | Maximise |
| False positive rate | % of flagged transactions that are legitimate | Minimise |
| Investigator throughput | Cases reviewed per analyst per day | Increase vs baseline |
| Time-to-hold | For automated triggers: time from transaction to card hold | Target < 30 seconds |
| Precision at threshold | Fraud / (fraud + legitimate) at chosen risk score cutoff | Track monthly |

> **Business trade-off:** Lowering the risk threshold captures more fraud but increases false positives, which creates customer friction when legitimate transactions are blocked. The right threshold is a business decision — not just a model decision — requiring input from fraud ops, customer experience, and risk governance teams.

---

## Project Architecture

```
Raw Transactions (1.3M rows)
        │
        ▼
  SQL Analysis          ← Baseline behavior, spend patterns, high-frequency flags
        │
        ▼
  Python Pipeline       ← Feature engineering, rule-based flags, Isolation Forest
        │
        ▼
  Risk Scored Output    ← rule_risk_score (0–2), iso_score_scaled (0–100), anomaly_flag
        │
        ▼
  Power BI Dashboard    ← KPIs, risk distribution, fraud vs. legitimate comparison
```

---

## Methodology

### Step 1 — SQL: Baseline Behavior Analysis
Queried raw transactions to establish normal customer behavior:
- Average transaction amount per customer
- Monthly spend and transaction frequency
- Category-level spend distribution
- High-frequency anomaly detection (>5 transactions/day)

### Step 2 — Rule-Based Risk Flags (Python)
Two independent behavioral signals were engineered and validated:

| Signal | Definition | Fraud Rate |
|--------|-----------|------------|
| High amount flag | Transaction > 95th percentile ($196) | ~8.8% |
| Odd hour flag | Transaction between 10 PM and 3 AM | Elevated 10–20× vs. daytime |
| Both flags (score = 2) | High amount AND odd hour | **25.6%** |
| Neither flag (score = 0) | Normal amount AND normal hour | 0.03% |

This composite score is fully transparent and explainable — a requirement in banking risk governance and regulatory environments where every flag must be justifiable to compliance teams.

### Step 3 — Isolation Forest (Unsupervised ML)
An Isolation Forest model was trained on 5 behavioral features with no fraud labels:

- `amt` — transaction amount
- `txn_hour` — hour of transaction
- `txn_day` — day of week
- `high_amount_flag` — rule-based signal
- `odd_hour_flag` — rule-based signal

Model configuration: 200 estimators, contamination = 0.006 (aligned to observed fraud rate of 0.58% — preventing the model from over-flagging).

Outputs:
- `anomaly_flag` — binary flag (1 = anomalous)
- `iso_score_scaled` — continuous risk score normalized to 0–100

### Step 4 — Power BI Dashboard
An interactive monitoring dashboard built to support fraud operations teams, featuring:
- High Risk Fraud % KPI
- Total fraud transaction count
- Average risk score by fraud label
- Risk score distribution histogram
- Fraud volume by hour of day
- Fraud count by merchant category (grocery_pos and shopping_net are highest-volume)

---

## Results Summary

| Metric | Value |
|--------|-------|
| Dataset size | 1,296,675 transactions |
| Overall fraud rate | 0.58% (7,506 fraud cases) |
| High-risk transactions (score = 2) | 18,887 (1.5% of volume) |
| Fraud rate in high-risk bucket | 25.64% |
| Avg risk score — legitimate | 20.5 |
| Avg risk score — fraudulent | 73.4 |
| Precision at risk score > 90 | ~59% |

---

## Tools & Technologies

| Tool | Usage |
|------|-------|
| Python (pandas, numpy, scikit-learn) | Feature engineering, risk scoring, Isolation Forest |
| SQL (SQLite) | Transaction querying, behavioral aggregation |
| Power BI | Interactive fraud monitoring dashboard |
| Jupyter Notebook | Analysis, experimentation, validation |

---

## Repository Structure

```
├── notebooks/
│   └── transaction_anomaly_analysis.ipynb   # Main analysis notebook
├── sql/
│   └── anomaly_analysis.sql                 # SQL queries for baseline analysis
├── outputs/
│   └── transaction_risk_scored.csv          # Scored transaction output
├── dashboard/
│   └── Transaction_Risk_Analysis.pbix       # Power BI dashboard
└── README.md
```

---

## Dataset

The dataset used is a publicly available synthetic credit card transaction dataset designed for fraud detection research. It contains anonymized cardholder and merchant data and is used here solely for educational and portfolio demonstration purposes.

**To run the notebook locally:**
1. Download the dataset from [Kaggle — Credit Card Transactions Fraud Detection](https://www.kaggle.com/datasets/kartik2112/fraud-detection)
2. Place `transactions.csv` in a `data/` folder at the repo root
3. Run `notebooks/transaction_anomaly_analysis.ipynb` end to end

---

## What This Demonstrates

- Translating a **business problem** (fraud triage efficiency) into an **end-to-end analytical solution**
- Combining **rule-based logic** with **unsupervised ML** for explainable risk scoring
- **Validating analytical outputs** against ground truth fraud labels
- Connecting analysis to **product decisions** — queue design, automated triggers, workload planning
- End-to-end workflow across **SQL → Python → BI tooling**
- Awareness of **banking risk governance** principles: interpretability, audit trails, threshold justification
