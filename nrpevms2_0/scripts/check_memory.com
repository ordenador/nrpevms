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
$ pct_free = 0
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
$    pct_free = free_mem * 100 / tot_mem
$    free_mem = free_mem * 8
$!    goto exit_loop
$ exit_loop:
$ !
$ close f
$ !
$EXIT:
$ write sys$output "Memory OK - [''free_mem' kB (''pct_free'%) free physical memory on ''nodename']"
$ !
$ if f$search ( RPT_FILE ) .nes. "" then deletes/noconfirm/nolog 'RPT_FILE';*
$ exit
