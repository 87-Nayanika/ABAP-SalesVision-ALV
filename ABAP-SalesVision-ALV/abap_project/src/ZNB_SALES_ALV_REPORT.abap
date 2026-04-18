*&---------------------------------------------------------------------*
*& Report  : ZNB_SALES_ALV_REPORT
*& Title   : Customer-wise Sales Order Analysis – ALV Report
*& Author  : Nayanika Bardhan
*& Roll No : 2305464
*& Program : B.Tech CSE, 3rd Year
*& Created : 2024
*&---------------------------------------------------------------------*
*& DESCRIPTION:
*& This custom ALV report fetches sales order data from SAP standard
*& tables (VBAK, VBAP, KNA1) and displays a formatted, interactive
*& ALV grid. It supports selection-screen filters, subtotals, colour
*& coding for order values, and Excel export capability.
*&---------------------------------------------------------------------*

REPORT znb_sales_alv_report
  LINE-SIZE  255
  LINE-COUNT 65
  NO STANDARD PAGE HEADING
  MESSAGE-ID znb_sales_msg.

*----------------------------------------------------------------------*
* Type Definitions
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_sales_data,
         vbeln    TYPE vbak-vbeln,       " Sales Order Number
         erdat    TYPE vbak-erdat,       " Creation Date
         auart    TYPE vbak-auart,       " Order Type
         kunnr    TYPE vbak-kunnr,       " Customer Number
         name1    TYPE kna1-name1,       " Customer Name
         posnr    TYPE vbap-posnr,       " Item Number
         matnr    TYPE vbap-matnr,       " Material Number
         arktx    TYPE vbap-arktx,       " Short Description
         kwmeng   TYPE vbap-kwmeng,      " Order Quantity
         vrkme    TYPE vbap-vrkme,       " Unit of Measure
         netwr    TYPE vbap-netwr,       " Net Value
         waerk    TYPE vbak-waerk,       " Currency
         color_field TYPE lvc_t_scol,   " ALV Colour Column
       END OF ty_sales_data.

TYPES: ty_t_sales_data TYPE STANDARD TABLE OF ty_sales_data.

*----------------------------------------------------------------------*
* Internal Tables and Work Areas
*----------------------------------------------------------------------*
DATA: gt_sales_data  TYPE ty_t_sales_data,
      gs_sales_data  TYPE ty_sales_data,
      gt_fieldcat    TYPE lvc_t_fcat,
      gs_fieldcat    TYPE lvc_s_fcat,
      gt_layout      TYPE lvc_s_layo,
      gt_sort        TYPE lvc_t_sort,
      gs_sort        TYPE lvc_s_sort,
      go_grid        TYPE REF TO cl_gui_alv_grid,
      go_container   TYPE REF TO cl_gui_custom_container,
      gs_variant     TYPE disvariant.

*----------------------------------------------------------------------*
* Constants
*----------------------------------------------------------------------*
CONSTANTS: gc_x      TYPE char1   VALUE 'X',
           gc_green  TYPE char4   VALUE 'C310',
           gc_yellow TYPE char4   VALUE 'C510',
           gc_red    TYPE char4   VALUE 'C610'.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS: so_vbeln FOR gs_sales_data-vbeln,
                  so_kunnr FOR gs_sales_data-kunnr,
                  so_auart FOR gs_sales_data-auart,
                  so_erdat FOR gs_sales_data-erdat.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
  PARAMETERS: p_maxrow TYPE i DEFAULT 1000,
              p_color  TYPE char1 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
* Initialization
*----------------------------------------------------------------------*
INITIALIZATION.
  TEXT-t01 = 'Selection Criteria'.
  TEXT-t02 = 'Display Options'.

*----------------------------------------------------------------------*
* At Selection Screen
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM validate_selection.

*----------------------------------------------------------------------*
* Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM fetch_data.
  IF gt_sales_data IS INITIAL.
    MESSAGE 'No records found for the given selection.' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF p_color = gc_x.
    PERFORM apply_color_coding.
  ENDIF.

  PERFORM display_alv.

*----------------------------------------------------------------------*
* FORM: validate_selection
*----------------------------------------------------------------------*
FORM validate_selection.
  " Ensure date range is logical
  IF so_erdat-low IS NOT INITIAL AND so_erdat-high IS NOT INITIAL.
    IF so_erdat-low > so_erdat-high.
      MESSAGE 'From Date cannot be greater than To Date.' TYPE 'E'.
    ENDIF.
  ENDIF.

  " Validate max rows
  IF p_maxrow <= 0.
    MESSAGE 'Maximum rows must be greater than zero.' TYPE 'E'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* FORM: fetch_data
*----------------------------------------------------------------------*
FORM fetch_data.
  DATA: lv_count TYPE i VALUE 0.

  SELECT vbak~vbeln
         vbak~erdat
         vbak~auart
         vbak~kunnr
         kna1~name1
         vbap~posnr
         vbap~matnr
         vbap~arktx
         vbap~kwmeng
         vbap~vrkme
         vbap~netwr
         vbak~waerk
    INTO TABLE gt_sales_data
    FROM vbak
    INNER JOIN vbap ON vbap~vbeln = vbak~vbeln
    LEFT OUTER JOIN kna1 ON kna1~kunnr = vbak~kunnr
    WHERE vbak~vbeln IN so_vbeln
      AND vbak~kunnr IN so_kunnr
      AND vbak~auart IN so_auart
      AND vbak~erdat IN so_erdat
    UP TO p_maxrow ROWS.

  IF sy-subrc <> 0.
    CLEAR gt_sales_data.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* FORM: apply_color_coding
*  - Green  : Net value >= 10,000
*  - Yellow : Net value >= 1,000 and < 10,000
*  - Red    : Net value < 1,000
*----------------------------------------------------------------------*
FORM apply_color_coding.
  DATA: ls_color TYPE lvc_s_scol.

  LOOP AT gt_sales_data INTO gs_sales_data.
    CLEAR gs_sales_data-color_field.

    ls_color-fname = 'NETWR'.
    ls_color-nokeycol = space.

    IF gs_sales_data-netwr >= 10000.
      ls_color-color-col = '5'.    " Green
      ls_color-color-int = '1'.
      ls_color-color-inv = '0'.
    ELSEIF gs_sales_data-netwr >= 1000.
      ls_color-color-col = '6'.    " Yellow/Orange
      ls_color-color-int = '1'.
      ls_color-color-inv = '0'.
    ELSE.
      ls_color-color-col = '6'.    " Red-ish
      ls_color-color-int = '0'.
      ls_color-color-inv = '1'.
    ENDIF.

    APPEND ls_color TO gs_sales_data-color_field.
    MODIFY gt_sales_data FROM gs_sales_data.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------*
* FORM: build_fieldcatalog
*----------------------------------------------------------------------*
FORM build_fieldcatalog.
  DEFINE add_field.
    CLEAR gs_fieldcat.
    gs_fieldcat-fieldname = &1.
    gs_fieldcat-coltext   = &2.
    gs_fieldcat-seltext   = &2.
    gs_fieldcat-outputlen = &3.
    gs_fieldcat-col_pos   = &4.
    gs_fieldcat-just      = &5.
    IF &6 = gc_x.
      gs_fieldcat-do_sum = gc_x.
    ENDIF.
    APPEND gs_fieldcat TO gt_fieldcat.
  END-OF-DEFINITION.

  "          Fieldname    Column Text              Len Pos Just  Sum
  add_field 'VBELN'      'Sales Order'             12  1   'L'  space.
  add_field 'ERDAT'      'Created On'              10  2   'C'  space.
  add_field 'AUART'      'Order Type'               4  3   'C'  space.
  add_field 'KUNNR'      'Customer No.'            10  4   'L'  space.
  add_field 'NAME1'      'Customer Name'           35  5   'L'  space.
  add_field 'POSNR'      'Item'                     6  6   'R'  space.
  add_field 'MATNR'      'Material'                18  7   'L'  space.
  add_field 'ARKTX'      'Description'             40  8   'L'  space.
  add_field 'KWMENG'     'Qty'                      8  9   'R'  space.
  add_field 'VRKME'      'UoM'                      3  10  'C'  space.
  add_field 'NETWR'      'Net Value'               16  11  'R'  gc_x.
  add_field 'WAERK'      'Currency'                 5  12  'C'  space.

  " Colour column – hidden from display
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname  = 'COLOR_FIELD'.
  gs_fieldcat-no_out     = gc_x.
  gs_fieldcat-tech       = gc_x.
  APPEND gs_fieldcat TO gt_fieldcat.
ENDFORM.

*----------------------------------------------------------------------*
* FORM: build_layout
*----------------------------------------------------------------------*
FORM build_layout.
  gt_layout-zebra        = gc_x.
  gt_layout-cwidth_opt   = gc_x.
  gt_layout-sel_mode     = 'A'.
  gt_layout-info_fname   = space.
  gt_layout-ctab_fname   = 'COLOR_FIELD'.
  gt_layout-grid_title   = 'Customer-wise Sales Order Analysis'.
  gt_layout-no_rowmark   = space.
  gt_layout-col_opt      = gc_x.
ENDFORM.

*----------------------------------------------------------------------*
* FORM: build_sort
*----------------------------------------------------------------------*
FORM build_sort.
  CLEAR gs_sort.
  gs_sort-spos      = 1.
  gs_sort-fieldname = 'KUNNR'.
  gs_sort-up        = gc_x.
  gs_sort-subtot    = gc_x.
  APPEND gs_sort TO gt_sort.

  CLEAR gs_sort.
  gs_sort-spos      = 2.
  gs_sort-fieldname = 'VBELN'.
  gs_sort-up        = gc_x.
  APPEND gs_sort TO gt_sort.
ENDFORM.

*----------------------------------------------------------------------*
* FORM: display_alv
*----------------------------------------------------------------------*
FORM display_alv.
  PERFORM build_fieldcatalog.
  PERFORM build_layout.
  PERFORM build_sort.

  gs_variant-report  = sy-repid.
  gs_variant-variant = '/DEFAULT'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_pf_status_set= 'SET_PF_STATUS'
      i_callback_user_command = 'USER_COMMAND'
      is_layout_lvc           = gt_layout
      it_fieldcat_lvc         = gt_fieldcat
      it_sort_lvc             = gt_sort
      i_save                  = 'A'
      is_variant              = gs_variant
      i_grid_title            = 'Customer-wise Sales Order Analysis'
    TABLES
      t_outtab                = gt_sales_data
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Error displaying ALV report.' TYPE 'E'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* FORM: SET_PF_STATUS  (Callback)
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZNB_STATUS' EXCLUDING rt_extab.
ENDFORM.

*----------------------------------------------------------------------*
* FORM: USER_COMMAND  (Callback – handles toolbar button events)
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     TYPE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN 'REFR'.
      " Refresh – re-fetch data
      CLEAR gt_sales_data.
      PERFORM fetch_data.
      IF p_color = gc_x.
        PERFORM apply_color_coding.
      ENDIF.
      rs_selfield-refresh = gc_x.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE PROGRAM.

    WHEN OTHERS.
      " No action for unrecognised commands
  ENDCASE.
ENDFORM.
