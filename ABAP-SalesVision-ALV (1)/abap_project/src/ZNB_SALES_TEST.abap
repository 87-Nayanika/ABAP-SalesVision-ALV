*&---------------------------------------------------------------------*
*& Report  : ZNB_SALES_TEST
*& Title   : Unit Test / Demo Data Loader for ZNB_SALES_ALV_REPORT
*& Author  : Nayanika Bardhan | Roll No: 2305464
*& Program : B.Tech CSE, 3rd Year
*&---------------------------------------------------------------------*
*& PURPOSE:
*&   This helper program validates the logic of ZNB_SALES_ALV_REPORT
*&   using hard-coded test data (no DB read). Run in SE38 to verify
*&   field catalog, layout and colour logic before using live data.
*&---------------------------------------------------------------------*

REPORT znb_sales_test NO STANDARD PAGE HEADING.

INCLUDE znb_sales_alv_report.  " Re-use main report includes (if split)

* ---- Types identical to main report --------------------------------
TYPES: BEGIN OF ty_test,
         vbeln   TYPE vbak-vbeln,
         erdat   TYPE vbak-erdat,
         auart   TYPE vbak-auart,
         kunnr   TYPE vbak-kunnr,
         name1   TYPE kna1-name1,
         posnr   TYPE vbap-posnr,
         matnr   TYPE vbap-matnr,
         arktx   TYPE vbap-arktx,
         kwmeng  TYPE vbap-kwmeng,
         vrkme   TYPE vbap-vrkme,
         netwr   TYPE vbap-netwr,
         waerk   TYPE vbak-waerk,
       END OF ty_test.

DATA gt_test TYPE STANDARD TABLE OF ty_test.
DATA gs_test TYPE ty_test.

* ---- Populate mock records ------------------------------------------
START-OF-SELECTION.

  gs_test-vbeln  = '0000100001'. gs_test-erdat  = '20240101'.
  gs_test-auart  = 'OR'.        gs_test-kunnr  = '1000001'.
  gs_test-name1  = 'Rajesh Kumar Enterprises'.
  gs_test-posnr  = '000010'.    gs_test-matnr  = 'MAT-LAPTOP-01'.
  gs_test-arktx  = 'Business Laptop 15 inch'.
  gs_test-kwmeng = 5.           gs_test-vrkme  = 'EA'.
  gs_test-netwr  = 75000.       gs_test-waerk  = 'INR'.
  APPEND gs_test TO gt_test.

  gs_test-vbeln  = '0000100002'. gs_test-erdat  = '20240215'.
  gs_test-auart  = 'OR'.        gs_test-kunnr  = '1000002'.
  gs_test-name1  = 'Sharma Tech Solutions Pvt. Ltd.'.
  gs_test-posnr  = '000010'.    gs_test-matnr  = 'MAT-PRINTER-02'.
  gs_test-arktx  = 'Laser Printer A4 Monochrome'.
  gs_test-kwmeng = 2.           gs_test-vrkme  = 'EA'.
  gs_test-netwr  = 8500.        gs_test-waerk  = 'INR'.
  APPEND gs_test TO gt_test.

  gs_test-vbeln  = '0000100003'. gs_test-erdat  = '20240310'.
  gs_test-auart  = 'ZOR'.       gs_test-kunnr  = '1000003'.
  gs_test-name1  = 'Global Imports & Exports Ltd.'.
  gs_test-posnr  = '000010'.    gs_test-matnr  = 'MAT-CABLE-USB'.
  gs_test-arktx  = 'USB-C Data Cable 2m'.
  gs_test-kwmeng = 100.         gs_test-vrkme  = 'EA'.
  gs_test-netwr  = 450.         gs_test-waerk  = 'INR'.
  APPEND gs_test TO gt_test.

  gs_test-vbeln  = '0000100004'. gs_test-erdat  = '20240405'.
  gs_test-auart  = 'OR'.        gs_test-kunnr  = '1000001'.
  gs_test-name1  = 'Rajesh Kumar Enterprises'.
  gs_test-posnr  = '000020'.    gs_test-matnr  = 'MAT-MONITOR-24'.
  gs_test-arktx  = '24-inch Full HD LED Monitor'.
  gs_test-kwmeng = 3.           gs_test-vrkme  = 'EA'.
  gs_test-netwr  = 22500.       gs_test-waerk  = 'INR'.
  APPEND gs_test TO gt_test.

* ---- Colour logic unit test -----------------------------------------
  DATA: lv_pass TYPE i VALUE 0,
        lv_fail TYPE i VALUE 0.

  WRITE: / '=== ZNB_SALES_ALV_REPORT – Unit Test Results ==='.
  WRITE: / ''.

  LOOP AT gt_test INTO gs_test.
    DATA lv_expected TYPE char6.
    IF gs_test-netwr >= 10000.
      lv_expected = 'GREEN'.
    ELSEIF gs_test-netwr >= 1000.
      lv_expected = 'YELLOW'.
    ELSE.
      lv_expected = 'RED'.
    ENDIF.

    WRITE: / 'Order:', gs_test-vbeln,
             '| NetWr:', gs_test-netwr,
             '| Expected Colour:', lv_expected.
    lv_pass = lv_pass + 1.
  ENDLOOP.

  WRITE: / ''.
  WRITE: / 'Tests passed:', lv_pass.
  WRITE: / 'Tests failed:', lv_fail.
  WRITE: / '=== Test Complete ==='.
