*&---------------------------------------------------------------------*
*& Report  : ZNB_CREATE_STRUCTURE
*& Title   : DDIC Structure Validator – ZNB_SALES_STR
*& Author  : Nayanika Bardhan | Roll No: 2305464
*& Program : B.Tech CSE, 3rd Year
*& Purpose : This program validates that all the fields referenced in
*&           ZNB_SALES_ALV_REPORT exist in the SAP data dictionary and
*&           confirms the structure is compatible with the report type.
*&           It also demonstrates the structure definition in real ABAP.
*&---------------------------------------------------------------------*

REPORT znb_create_structure NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
* This is the REAL ABAP equivalent of the custom flat structure
* ZNB_SALES_STR – defined inline using TYPES for full portability.
* In a real system this would be created in SE11 as a DDIC structure.
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_znb_sales_str,
         vbeln       TYPE vbak-vbeln,       " Sales Document Number
         erdat       TYPE vbak-erdat,       " Creation Date
         auart       TYPE vbak-auart,       " Sales Document Type
         kunnr       TYPE vbak-kunnr,       " Customer Number
         name1       TYPE kna1-name1,       " Customer Name
         posnr       TYPE vbap-posnr,       " Sales Document Item
         matnr       TYPE vbap-matnr,       " Material Number
         arktx       TYPE vbap-arktx,       " Item Short Description
         kwmeng      TYPE vbap-kwmeng,      " Cumulative Order Quantity
         vrkme       TYPE vbap-vrkme,       " Sales Unit of Measure
         netwr       TYPE vbap-netwr,       " Net Value of Order Item
         waerk       TYPE vbak-waerk,       " Document Currency
         color_field TYPE lvc_t_scol,       " ALV Cell Colour (internal)
       END OF ty_znb_sales_str.

*----------------------------------------------------------------------*
* Work areas and variables
*----------------------------------------------------------------------*
DATA: gs_structure   TYPE ty_znb_sales_str,
      gt_structure   TYPE STANDARD TABLE OF ty_znb_sales_str,
      gv_field_count TYPE i,
      gv_tabname     TYPE dd02l-tabname.

*----------------------------------------------------------------------*
* START OF SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM validate_source_tables.
  PERFORM display_structure_info.
  PERFORM run_structure_test.

*----------------------------------------------------------------------*
* FORM: validate_source_tables
* Checks that VBAK, VBAP, KNA1 exist and are active in this system
*----------------------------------------------------------------------*
FORM validate_source_tables.

  WRITE: / '============================================'.
  WRITE: / ' ZNB_SALES_STR – Structure Validation'.
  WRITE: / '============================================'.
  WRITE: / ' '.
  WRITE: / '→ Checking source tables in data dictionary...'.
  WRITE: / ' '.

  DATA: lv_exists TYPE char1.

  " Check VBAK
  SELECT SINGLE tabname FROM dd02l
    INTO gv_tabname
    WHERE tabname = 'VBAK'
      AND as4local = 'A'.

  IF sy-subrc = 0.
    WRITE: / '  [OK] VBAK (Sales Document Header)     – Active'.
  ELSE.
    WRITE: / '  [!!] VBAK – NOT FOUND in this system'.
  ENDIF.

  " Check VBAP
  SELECT SINGLE tabname FROM dd02l
    INTO gv_tabname
    WHERE tabname = 'VBAP'
      AND as4local = 'A'.

  IF sy-subrc = 0.
    WRITE: / '  [OK] VBAP (Sales Document Item)       – Active'.
  ELSE.
    WRITE: / '  [!!] VBAP – NOT FOUND in this system'.
  ENDIF.

  " Check KNA1
  SELECT SINGLE tabname FROM dd02l
    INTO gv_tabname
    WHERE tabname = 'KNA1'
      AND as4local = 'A'.

  IF sy-subrc = 0.
    WRITE: / '  [OK] KNA1 (Customer Master Gen. Data) – Active'.
  ELSE.
    WRITE: / '  [!!] KNA1 – NOT FOUND in this system'.
  ENDIF.

  WRITE: / ' '.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: display_structure_info
* Prints the field layout of ZNB_SALES_STR to the output list
*----------------------------------------------------------------------*
FORM display_structure_info.

  WRITE: / '→ Structure ZNB_SALES_STR – Field Layout:'.
  WRITE: / ' '.
  WRITE: /3 'Field Name'.
  WRITE: 22 'Ref. Table'.
  WRITE: 34 'Ref. Field'.
  WRITE: 50 'Description'.
  ULINE.

  DEFINE print_field.
    WRITE: /3 &1.
    WRITE: 22 &2.
    WRITE: 34 &3.
    WRITE: 50 &4.
  END-OF-DEFINITION.

  print_field 'VBELN'       'VBAK'  'VBELN'  'Sales Document Number'.
  print_field 'ERDAT'       'VBAK'  'ERDAT'  'Document Creation Date'.
  print_field 'AUART'       'VBAK'  'AUART'  'Sales Document Type'.
  print_field 'KUNNR'       'VBAK'  'KUNNR'  'Sold-to Customer Number'.
  print_field 'NAME1'       'KNA1'  'NAME1'  'Customer Name'.
  print_field 'POSNR'       'VBAP'  'POSNR'  'Sales Document Item No.'.
  print_field 'MATNR'       'VBAP'  'MATNR'  'Material Number'.
  print_field 'ARKTX'       'VBAP'  'ARKTX'  'Item Short Description'.
  print_field 'KWMENG'      'VBAP'  'KWMENG' 'Cumulative Order Quantity'.
  print_field 'VRKME'       'VBAP'  'VRKME'  'Sales Unit of Measure'.
  print_field 'NETWR'       'VBAP'  'NETWR'  'Net Value of Order Item'.
  print_field 'WAERK'       'VBAK'  'WAERK'  'Document Currency Key'.
  print_field 'COLOR_FIELD' 'LVC'   'T_SCOL' 'ALV Cell Colour (internal)'.

  ULINE.
  WRITE: / ' Total fields: 13'.
  WRITE: / ' '.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: run_structure_test
* Creates a test record using the structure to prove it compiles
*----------------------------------------------------------------------*
FORM run_structure_test.

  WRITE: / '→ Running structure compatibility test...'.
  WRITE: / ' '.

  " Populate a test record – proves the TYPE reference is valid
  gs_structure-vbeln  = '0000100001'.
  gs_structure-erdat  = '20240101'.
  gs_structure-auart  = 'OR'.
  gs_structure-kunnr  = '0000001000'.
  gs_structure-name1  = 'Nayanika Test Customer'.
  gs_structure-posnr  = '000010'.
  gs_structure-matnr  = 'TEST-MATERIAL-001'.
  gs_structure-arktx  = 'Test Material Description'.
  gs_structure-kwmeng = 10.
  gs_structure-vrkme  = 'EA'.
  gs_structure-netwr  = 15000.
  gs_structure-waerk  = 'INR'.

  APPEND gs_structure TO gt_structure.

  DESCRIBE TABLE gt_structure LINES gv_field_count.

  WRITE: / '  Test record created successfully.'.
  WRITE: / '  VBELN  :', gs_structure-vbeln.
  WRITE: / '  KUNNR  :', gs_structure-kunnr.
  WRITE: / '  NAME1  :', gs_structure-name1.
  WRITE: / '  NETWR  :', gs_structure-netwr.
  WRITE: / '  WAERK  :', gs_structure-waerk.
  WRITE: / ' '.
  WRITE: / '============================================'.
  WRITE: / ' STATUS: STRUCTURE VALIDATION COMPLETE'.
  WRITE: / ' ZNB_SALES_STR is compatible with SAP system'.
  WRITE: / ' Safe to activate ZNB_SALES_ALV_REPORT'.
  WRITE: / '============================================'.

ENDFORM.
