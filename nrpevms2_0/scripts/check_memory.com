$!------------------------------------------------------------------------------
$!
$!                     Physical Memory Check for Nagios
$!                     ================================
$!
$!
$! Zakaria Yassine   25-mar-2003     - Initial Version
$!
$!      Parameters:
$!              N/A
$!
$!------------------------------------------------------------------------------
$
$! Limpia logs
@ nrpe$scripts:PURGE_LOGS.COM
$
$
$ set on
$ on error then goto exit
$ !
$ CUR_PID  = f$getjpi ( "", "PID" )
$ CUR_UIC  = f$getjpi ( "", "UIC" )
$ nodename = f$getsyi ( "nodename" )
$ RPT_FILE = "PHYMEM_''CUR_PID'.RPT"
$ !
$ if f$search ( RPT_FILE ) .nes. "" then deletes/noconfirm/nolog 'RPT_FILE';*
$ define/user sys$output 'RPT_FILE'
$ show memory/physical
$ !
$ free_mem = 0
$ tot_mem = 0
$ modi_mem = 0
$ pct_free = 0
$ used_mem = 0
$ pct_used = 0
$
$ open f 'RPT_FILE'
$ read f r
$ read f r /end_of_file=exit_loop
$ usr_cnt = 1
$ loop:
$    read f r /end_of_file=exit_loop
$    if f$extract(2, 11, r) .nes. "Main Memory" then goto loop
$    r = f$edit(r, "COMPRESS,TRIM")
$    tot_mem  = f$element(3, " ", r)
$    free_mem = f$element(4, " ", r)
$    used_mem = f$element(5, " ", r)
$    modi_mem = f$element(6, " ", r)
$    pct_free = free_mem * 100 / tot_mem
$    pct_used = used_mem * 100 / tot_mem
$    free_mem = free_mem * 8
$    used_mem = used_mem * 8
$    modi_mem = modi_mem *8
$    tot_mem = tot_mem *8
$!    goto exit_loop
$ exit_loop:
$ !
$ close f
$ !
$EXIT:
$ write sys$output "OK - ''pct_used'% (''used_mem' kB) used. ||TOTAL=''tot_mem'KB;;;; USED=''used_mem'KB;;;; FREE=''free_mem'KB;;;; MODIFIED=''modi_mem'KB;;;;"
$ !
$ if f$search ( RPT_FILE ) .nes. "" then deletes/noconfirm/nolog 'RPT_FILE';*
$ exit