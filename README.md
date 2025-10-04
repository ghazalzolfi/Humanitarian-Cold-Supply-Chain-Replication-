# Humanitarian Cold Supply Chain Distribution

This repository contains the implementation and replication of a **Mixed Integer Programming (MIP)** model for a **humanitarian cold supply chain distribution problem**.  
The project was developed as part of the *Fundamentals of Healthcare Systems Engineering* course (2024–2025, Spring semester).

---

## Problem Overview
The project focuses on the **distribution of COVID-19 vaccines** within a humanitarian logistics context.  
The selected study emphasizes two critical social cost components in healthcare logistics:
- **Deprivation costs**: economic valuation of human suffering caused by delayed access to essential goods.  
- **Equity considerations**: fair allocation of limited vaccines across different regions.  

The challenge is to replicate the published model, implement it with available tools, and analyze the performance under real-world case data.

---

## Objective
The project aims to:  
- Replicate the **mathematical model** proposed in the selected article.  
- Implement and validate the model using **GAMS**.  
- Provide a structured **project report** and **presentation**.  
- Compare findings against the results of the original article.

---

## Model & Methodology
- The original article develops a **three-echelon supply chain model** (suppliers, distributors, affected regions).  
- The model minimizes total costs, including transportation, shortage, deprivation, and holding costs, while considering equity in vaccine distribution.  
- Our project replicates this approach using **GAMS** and documents the process in a detailed project report and slides.  

The reference article is:  
*Khodaee, V., Kayvanfar, V., & Haji, A. (2022). A humanitarian cold supply chain distribution model with equity consideration: The case of COVID-19 vaccine distribution in the European Union. Decision Analytics Journal, 4, 100126.*  

---

## Input Parameters
This project does not include a separate dataset file.  
All parameters used in the model are documented inside the **report** and implemented directly within the **GAMS code**.

---

## How to Run

### Run with GAMS
Execute the GAMS model using GAMS Studio or command line:

Command example:  
```bash
gams implementation/Model.gms
```

The outputs and results are discussed in the **project report** and were presented in class.

---

## Tools & Libraries
- **GAMS**: Main solver and modeling environment  
- **LaTeX / Word**: Report preparation  
- **Google Slides**: Presentation  
- **Academic Articles**: Reference materials for literature review  

---
