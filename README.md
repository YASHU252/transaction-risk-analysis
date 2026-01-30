
---

## Key Analysis Components

### 1. Exploratory Transaction Analysis
- Transaction amount distribution
- Time-of-day risk patterns
- Fraud vs non-fraud behavior comparison

### 2. Risk Signal Engineering

Independent risk indicators used:
- Transaction amount (high-value outliers)
- Transaction timing (late-night activity)
- Historical fraud flag

These signals are combined into a **transparent composite risk score**, prioritizing interpretability over black-box modeling — aligned with banking risk governance principles.

---

## Power BI Dashboard

An interactive Power BI dashboard was built to support monitoring and investigation.

### Dashboard features:
- High Risk Fraud % KPI
- Total Fraud Transactions
- Average Risk Score
- Risk score distribution
- Fraud vs non-fraud comparison
- Drill-down capability for investigation support

The dashboard is designed to resemble fraud monitoring views used by banking risk and operations teams.

---

## Alert Simulation

A rule-based alerting framework was simulated:
- Transactions above a defined risk threshold are flagged
- Alerts are prioritized based on risk severity
- Effectiveness validated using fraud concentration in high-risk buckets

This reflects how banks manage alert queues and investigator workload.

---

## Key Insights

- High-value transactions show significantly higher fraud rates
- Late-night transactions exhibit elevated fraud risk
- High-risk transactions represent a small volume but a disproportionate share of fraud
- Risk scoring improves operational focus and investigation efficiency

---

## Tools & Technologies

- **Python**: pandas, numpy, scikit-learn  
- **Power BI**: Interactive dashboards & KPIs  
- **SQL**: Transaction querying & aggregation  
- **Jupyter Notebook**: Analysis and experimentation
