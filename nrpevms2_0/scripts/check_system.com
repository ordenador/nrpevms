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
$ set on
$ on error then goto exit
$ !
$ CUR_PID  = f$getjpi ( "", "PID" )
$ CUR_UIC  = f$getjpi ( "", "UIC" )
$ nodename = f$getsyi ( "nodename" )
$ RPT_FILE = "SYSMON_''CUR_PID'.RPT"
$ !
$ if f$search ( RPT_FILE ) .nes. "" then deletes/noconfirm/nolog 'RPT_FILE';*
$ monitor system/summary='RPT_FILE/interval=1/nodisplay/ending="+00:00:02"
$ !
$
$ open f 'RPT_FILE'
$ read f r
$ read f r /end_of_file=exit_loop
$ 
$ cpu_idle_time = 0
$ cpu_time      = 0
$ proc_count    = 0
$ 
$ loop:
$    read f r /end_of_file=exit_loop
$    r = f$edit(r, "COMPRESS,TRIM")
$
$    if f$extract(0, 15, r) .eqs. "Interrupt State"    .OR. -     
        f$extract(0, 18, r) .eqs. "MP Synchronization" .OR. -  
        f$extract(0, 11, r) .eqs. "Kernel Mode"        .OR. -  
        f$extract(0, 14, r) .eqs. "Executive Mode"     .OR. -  
        f$extract(0, 15, r) .eqs. "Supervisor Mode"    .OR. -  
        f$extract(0,  9, r) .eqs. "User Mode"          .OR. -  
        f$extract(0, 18, r) .eqs. "Compatibility Mode" .OR. -  
        f$extract(0,  9, r) .eqs. "Idle Time"             
$    then
$       cpu_time = cpu_time + f$element(0, ".", f$element(3, " ", r))
$    endif
$    if f$extract(0,  9, r) .eqs. "Idle Time"             
$    then
$       cpu_idle_time = f$element(0, ".", f$element(3, " ", r))
$    endif
$    if f$extract(0, 13, r) .eqs. "Process Count"         
$    then
$       proc_count = f$element(0, ".", f$element(3, " ", r))
$    endif
$    if f$extract(0, 15, r) .eqs. "Page Fault Rate"       
$    then
$       page_fault_rate = f$element(0, ".", f$element(4, " ", r))
$    endif
$    if f$extract(0, 18, r) .eqs. "Page Read I/O Rate"    
$    then
$       page_read_rate  = f$element(0, ".", f$element(5, " ", r))
$    endif
$    if f$extract(0, 14, r) .eqs. "Free List Size"        
$    then
$       free_list_size = f$element(0, ".", f$element(4, " ", r))
$    endif
$    if f$extract(0, 18, r) .eqs. "Modified List Size"    
$    then
$       modif_list_size = f$element(0, ".", f$element(4, " ", r))
$    endif
$    if f$extract(0, 15, r) .eqs. "Direct I/O Rate"       
$    then
$       dio_rate = f$element(0, ".", f$element(4, " ", r))
$    endif
$    if f$extract(0, 17, r) .eqs. "Buffered I/O Rate"     
$    then
$       bio_rate = f$element(0, ".", f$element(4, " ", r))
$    endif
$
$    goto loop
$ exit_loop:
$ !
$ close f
$ !
$EXIT:
$  if p1 .eqs. "CPU"
$  then
$	cpu_pct = cpu_time * 100 / (cpu_time + cpu_idle_time) 
$	write sys$output "CPU OK - [''cpu_pct'% CPU Usage on ''nodename']"
$  endif
$  if p1 .eqs. "PRC"
$  then
$	write sys$output "CPU OK - [''proc_count' processes running on ''nodename']"
$  endif
$  if p1 .eqs. "PFR"
$  then
$	write sys$output "PAGING OK - [''page_fault_rate' page fault rate on ''nodename']"
$  endif
$  if p1 .eqs. "PRR"
$  then
$	write sys$output "PAGING OK - [''page_read_rate' page read rate on ''nodename']"
$  endif
$  if p1 .eqs. "FPL"
$  then
$	write sys$output "MEMORY OK - [''free_list_size' pages in free list size on ''nodename']"
$  endif
$  if p1 .eqs. "MPL"
$  then
$	write sys$output "MEMORY OK - [''modif_list_size' pages in modified list size on ''nodename']"
$  endif
$  if p1 .eqs. "DIO"
$  then
$	write sys$output "I/O OK - [''dio_rate' Direct I/O rate on ''nodename']"
$  endif
$  if p1 .eqs. "BIO"
$  then
$	write sys$output "I/O OK - [''bio_rate' Buffered I/O rate on ''nodename']"
$  endif
$ !
$ if f$search ( RPT_FILE ) .nes. "" then deletes/noconfirm/nolog 'RPT_FILE';*
$ exit
