# ABAP-SalesVision-ALV
## Custom ALV Report – Customer-wise Sales Order Analysis

**Author:** Nayanika Bardhan  
**Roll No:** 2305464  
**Program:** B.Tech CSE, 3rd Year  

---

## 📋 Overview

This project implements a fully functional **Custom ALV (ABAP List Viewer) Report** in SAP ABAP that provides a consolidated, interactive view of customer-wise sales order data. The report fetches data from standard SAP tables (`VBAK`, `VBAP`, `KNA1`) and presents it in a formatted, sortable, and exportable ALV grid.

---

## 🎯 Problem Statement

In large SAP environments, sales teams and managers frequently need to review open and completed sales orders across multiple customers and materials. The standard SAP transaction `VA05` provides limited filtering and no colour-coded value indicators. This custom report bridges that gap by offering:

- Multi-field selection screen filters
- Customer name resolution from master data
- Automatic subtotals per customer
- Colour-coded net value indicators (green / yellow / red)
- Excel export and layout variant save

---

## 🛠️ Tech Stack

| Component | Detail |
|-----------|--------|
| Language  | ABAP (Advanced Business Application Programming) |
| SAP System | SAP ECC 6.0 / S/4HANA compatible |
| ALV Framework | `REUSE_ALV_GRID_DISPLAY_LVC` (Function Module) |
| DB Tables | `VBAK`, `VBAP`, `KNA1` |
| Transaction | SE38 (ABAP Editor), SE11 (DDIC), SE91 (Messages) |
| GUI Framework | `CL_GUI_ALV_GRID`, `CL_GUI_CUSTOM_CONTAINER` |

---

## 📁 Project Structure

```
ABAP-SalesVision-ALV/
├── src/
│   ├── ABAP-SalesVision-ALV.abap     ← Main Report Program
│   ├── ZNB_SALES_TEST.abap           ← Unit Test / Mock Data Runner
│   ├── ZNB_SALES_STR_DDIC.txt        ← DDIC Structure Definition Guide
│   └── ZNB_SALES_MSG_Class.txt       ← Message Class Setup Guide
├── docs/
│   └── ZNB_SALES_ALV_Documentation.pdf
├── README.md
└── .gitignore
```

---

## ⚙️ Features

1. **Selection Screen** with ranges for Sales Order, Customer, Order Type, and Date
2. **JOIN query** across VBAK + VBAP + KNA1 for enriched output
3. **Field Catalog** built programmatically with column labels and output lengths
4. **Colour Coding** on Net Value column:
   - 🟢 Green → Net Value ≥ ₹10,000
   - 🟡 Yellow → ₹1,000 ≤ Net Value < ₹10,000
   - 🔴 Red → Net Value < ₹1,000
5. **Subtotals** grouped by Customer Number
6. **Toolbar Callbacks** – Refresh button re-executes the DB query live
7. **Layout Variant** save/restore (`/DEFAULT`)
8. **Excel Export** via standard ALV toolbar button

---

## 🚀 Installation / Activation Steps

### Step 1 – Create Message Class
1. Open transaction **SE91**
2. Enter message class name: `ZNB_SALES_MSG`
3. Add messages as documented in `ZNB_SALES_MSG_Class.txt`
4. Save and activate

### Step 2 – Create DDIC Structure (Optional)
1. Open transaction **SE11**
2. Create structure `ZNB_SALES_STR` using the field list in `ZNB_SALES_STR_DDIC.txt`
3. Save and activate

### Step 3 – Create Report
1. Open transaction **SE38**
2. Enter program name: `ABAP-SalesVision-ALV`
3. Create → paste the full source from `ABAP-SalesVision-ALV.abap`
4. Assign to a development package (e.g. `$TMP` for local testing)
5. **Activate** (Ctrl+F3)

### Step 4 – Run Unit Test
1. In SE38, open `ZNB_SALES_TEST.abap` and activate
2. Execute (F8) to verify colour logic output in the SAP list

### Step 5 – Execute Main Report
1. SE38 → `ABAP-SalesVision-ALV` → F8
2. Enter desired filter values on the selection screen
3. Click Execute

---

## 📊 Sample Output

```
+──────────────+────────────+───────+───────────+──────────────────────────────────+
| Sales Order  | Created On | Type  | Customer  | Customer Name                    |
+──────────────+────────────+───────+───────────+──────────────────────────────────+
| 0000100001   | 01.01.2024 | OR    | 1000001   | Rajesh Kumar Enterprises          |
|   000010     |            |       |           | MAT-LAPTOP-01  Qty:5  INR 75,000  | 🟢
| 0000100002   | 15.02.2024 | OR    | 1000002   | Sharma Tech Solutions Pvt. Ltd.   |
|   000010     |            |       |           | MAT-PRINTER-02 Qty:2  INR 8,500   | 🟡
| 0000100003   | 10.03.2024 | ZOR   | 1000003   | Global Imports & Exports Ltd.     |
|   000010     |            |       |           | MAT-CABLE-USB  Qty:100 INR 450    | 🔴
+──────────────+────────────+───────+───────────+──────────────────────────────────+
```

---

## 🔮 Future Improvements

- Add drill-down to `VA03` (Display Sales Order) on row double-click
- Include delivery status from `VBUK` table
- Add chart visualisation using `CL_GUI_CHART_ENGINE`
- Extend to purchase orders (EKKO/EKPO) for a procurement view
- Scheduled background execution with email delivery of output

---

## 📄 License

This project is submitted as an academic project. All code is original and written from scratch for educational purposes.

---

*Generated as part of ABAP Development coursework — B.Tech CSE, 3rd Year*
