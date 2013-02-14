$!------------------------------------------------------------------------------
$!
$!                        System Check for Nagios
$!                        =======================
$!
$!
$! Zakaria Yassine   25-mar-2003     - Initial Version
$!
$!      Parameters:
$!              p1 - 	CPU
$!			PRC
$!			PFR
$!			PRR
$!			FPL,MPL
$!			DIO,BIO
$!
$!------------------------------------------------------------------------------
$
$ !
$ set noon
$ say = "write sys$output "
$ CURR_NODE = f$getsyi ( "nodename" )
$ CURR_PID  = f$getjpi ( "", "PID" )
$ INP_FILE  = "WTASKS_''CURR_PID'.TMP"
$ APPL_NAME = p1
$ if APPL_NAME .eqs. ""
$ then
$   APPL_NAME = "PRD_BCC"
$ endif
$ WAIT_CNT  = 0
$ !
$ define/user sys$output 'INP_FILE'
$ acms/show appl 'APPL_NAME'
$ !
$ open/read F_ACMS 'INP_FILE' /error = EXIT_LOOP
$LOOP:
$    read F_ACMS R /end_of_file = EXIT_LOOP
$    TARGET = f$extract( 0, 8, R )
$    if TARGET .eqs. "CS_PRISM"
$    then
$       SERV_STAT = f$extract (30, 80, R )
$       SERV_STAT = f$edit ( SERV_STAT, "TRIM,COMPRESS" )
$	WAIT_CNT  = WAIT_CNT + f$element ( 4, " ", serv_stat )
$    endif
$    goto loop
$EXIT_LOOP:
$ close F_ACMS
$ say "''CURR_NODE' OK - [''WAIT_CNT' Waiting Tasks ''APPL_NAME' on ''curr_node']"
$ deletes/noconf/nolog 'INP_FILE';*
$ exit
