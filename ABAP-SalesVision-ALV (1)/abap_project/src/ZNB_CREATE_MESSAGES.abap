*&---------------------------------------------------------------------*
*& Report  : ZNB_CREATE_MESSAGES
*& Title   : Message Class Setup Utility – ZNB_SALES_MSG
*& Author  : Nayanika Bardhan | Roll No: 2305464
*& Program : B.Tech CSE, 3rd Year
*& Purpose : This program programmatically inserts all required messages
*&           into the ZNB_SALES_MSG message class using SAP standard
*&           function modules. Run this ONCE after creating the empty
*&           message class shell via SE91.
*&---------------------------------------------------------------------*

REPORT znb_create_messages NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
* Type definitions
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_msg,
         msgnr TYPE t100-msgnr,
         msgty TYPE t100-msgty,
         text  TYPE t100-text,
       END OF ty_msg.

*----------------------------------------------------------------------*
* Internal table with all messages to be created
*----------------------------------------------------------------------*
DATA: gt_messages TYPE STANDARD TABLE OF ty_msg,
      gs_message  TYPE ty_msg,
      gs_t100     TYPE t100,
      gv_lines    TYPE i,
      gv_success  TYPE i VALUE 0,
      gv_failed   TYPE i VALUE 0.

CONSTANTS: gc_arbgb TYPE t100-arbgb VALUE 'ZNB_SALES_MSG'.

*----------------------------------------------------------------------*
* START OF SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM populate_messages.
  PERFORM insert_messages.
  PERFORM display_results.

*----------------------------------------------------------------------*
* FORM: populate_messages
* Fills the internal table with all message definitions
*----------------------------------------------------------------------*
FORM populate_messages.

  " Message 001 – Information: No data found
  gs_message-msgnr = '001'.
  gs_message-msgty = 'I'.
  gs_message-text  = 'No records found for the selection criteria entered'.
  APPEND gs_message TO gt_messages.

  " Message 002 – Error: Invalid date range
  gs_message-msgnr = '002'.
  gs_message-msgty = 'E'.
  gs_message-text  = 'From Date must not be greater than To Date'.
  APPEND gs_message TO gt_messages.

  " Message 003 – Error: Invalid row count
  gs_message-msgnr = '003'.
  gs_message-msgty = 'E'.
  gs_message-text  = 'Maximum rows value must be a positive integer'.
  APPEND gs_message TO gt_messages.

  " Message 004 – Success: Report ran OK (& = placeholder for record count)
  gs_message-msgnr = '004'.
  gs_message-msgty = 'S'.
  gs_message-text  = 'Report executed successfully. & record(s) retrieved'.
  APPEND gs_message TO gt_messages.

  " Message 005 – Warning: Customer not in master data
  gs_message-msgnr = '005'.
  gs_message-msgty = 'W'.
  gs_message-text  = 'Customer & does not exist in master data (KNA1)'.
  APPEND gs_message TO gt_messages.

  DESCRIBE TABLE gt_messages LINES gv_lines.
  WRITE: / '→ Prepared', gv_lines, 'messages for class', gc_arbgb.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: insert_messages
* Writes each message into table T100 (SAP message store)
*----------------------------------------------------------------------*
FORM insert_messages.

  WRITE: / ' '.
  WRITE: / '→ Inserting messages into T100...'.
  WRITE: / ' '.

  LOOP AT gt_messages INTO gs_message.

    " Check if message already exists
    SELECT SINGLE * FROM t100
      INTO gs_t100
      WHERE sprsl = sy-langu
        AND arbgb = gc_arbgb
        AND msgnr = gs_message-msgnr.

    IF sy-subrc = 0.
      " Message exists – update it
      UPDATE t100 SET text = gs_message-text
        WHERE sprsl = sy-langu
          AND arbgb = gc_arbgb
          AND msgnr = gs_message-msgnr.

      IF sy-subrc = 0.
        gv_success = gv_success + 1.
        WRITE: / '  [UPDATED] Msg', gs_message-msgnr,
                 '(', gs_message-msgty, ') -', gs_message-text.
      ELSE.
        gv_failed = gv_failed + 1.
        WRITE: / '  [FAILED ] Msg', gs_message-msgnr, '- Could not update'.
      ENDIF.

    ELSE.
      " Message does not exist – insert it fresh
      CLEAR gs_t100.
      gs_t100-sprsl = sy-langu.
      gs_t100-arbgb = gc_arbgb.
      gs_t100-msgnr = gs_message-msgnr.
      gs_t100-msgty = gs_message-msgty.
      gs_t100-text  = gs_message-text.

      INSERT t100 FROM gs_t100.

      IF sy-subrc = 0.
        gv_success = gv_success + 1.
        WRITE: / '  [CREATED] Msg', gs_message-msgnr,
                 '(', gs_message-msgty, ') -', gs_message-text.
      ELSE.
        gv_failed = gv_failed + 1.
        WRITE: / '  [FAILED ] Msg', gs_message-msgnr, '- Insert error'.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: display_results
* Shows a summary of what was created / updated / failed
*----------------------------------------------------------------------*
FORM display_results.

  WRITE: / ' '.
  WRITE: / '============================================'.
  WRITE: / ' ZNB_SALES_MSG – Message Creation Summary'.
  WRITE: / '============================================'.
  WRITE: / ' Messages processed :', gv_lines.
  WRITE: / ' Successfully done  :', gv_success.
  WRITE: / ' Failed             :', gv_failed.
  WRITE: / '============================================'.

  IF gv_failed = 0.
    WRITE: / ' STATUS: ALL MESSAGES CREATED SUCCESSFULLY'.
    WRITE: / ' You can now activate ZNB_SALES_ALV_REPORT'.
  ELSE.
    WRITE: / ' STATUS: SOME MESSAGES FAILED – CHECK AUTHORIZATION'.
    WRITE: / ' Ensure you have S_DEVELOP and S_TABU_DIS access'.
  ENDIF.

  WRITE: / '============================================'.

ENDFORM.
