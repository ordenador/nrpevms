$!------------------------------------------------------------------------------
$!
$!                         Acms_Users for Nagios
$!                         ===================== 
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
$ CUR_NODE = f$getsyi("NODENAME")
$ RPT_FILE = "ACMSUSR_''CUR_PID'.RPT"
$ !
$ if f$search ( RPT_FILE ) .nes. "" then deletes/noconfirm/nolog 'RPT_FILE';*
$ define/user sys$output 'RPT_FILE'
$ acms/show user
$ !
$ usr_cnt = 0
$ lrl = f$file_attr(rpt_file, "lrl")
$ if lrl .lt. 79 then goto exit
$ !
$ open f 'RPT_FILE'
$ read f r
$ read f r /end_of_file=exit_loop_sum_server
$ if f$locate ( "..No matching users found...", r ) .lt. f$length ( r )
$ then
$    goto exit_loop_sum_server
$ endif
$ usr_cnt = 1
$ loop_sum_server:
$    read f r /end_of_file=exit_loop_sum_server
$    if f$extract(2, 4, r) .nes. "User" then goto loop_sum_server
$    usr_cnt = usr_cnt + 1
$    goto loop_sum_server
$ exit_loop_sum_server:
$ !
$ close f
$ !
$EXIT:
$ write sys$output "ACMS OK - [", f$fao("!3SL", usr_cnt), " ACMS users connected on ''cur_node']"
$ !
$ if f$search ( RPT_FILE ) .nes. "" then deletes/noconfirm/nolog 'RPT_FILE';*
$ exit
