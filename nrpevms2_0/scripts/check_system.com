$!------------------------------------------------------------------------------
$!
$!                        System Check for Nagios
$!                        =======================
$!
$!
$! Zakaria Yassine   25-mar-2003     - Initial Version
$! Modified by Mario Faundez (mandfaundez@falabella.cl)
$!
$!      Parameters:
$!              p1 -    CPU
$!                      PRC
$!                      PFR
$!                      PRR
$!                      FPL,MPL
$!                      DIO,BIO
$!
$!------------------------------------------------------------------------------
$
$! Limpia logs
$! @nrpe$scripts:PURGE_LOGS.COM
$
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
$ cpu_idle = 0
$ proc_count = 0
$ cpu_used = 0
$
$ loop:
$    read f r /end_of_file=exit_loop
$    r = f$edit(r, "COMPRESS,TRIM")
$
$    if f$extract(0, 15, r) .eqs. "Interrupt State"
$    then
$       cpu_interrupt = f$element(0, ".", f$element(3, " ", r))
$       cpu_used = cpu_used + cpu_interrupt
$    endif
$    if f$extract(0, 18, r) .eqs. "MP Synchronization"
$    then
$       cpu_mpsynch = f$element(0, ".", f$element(3, " ", r))
$       cpu_used = cpu_used + cpu_mpsynch
$    endif
$    if f$extract(0, 11, r) .eqs. "Kernel Mode"
$    then
$       cpu_kernel = f$element(0, ".", f$element(3, " ", r))
$       cpu_used = cpu_used + cpu_kernel
$    endif
$    if f$extract(0, 14, r) .eqs. "Executive Mode"
$    then
$       cpu_executive = f$element(0, ".", f$element(3, " ", r))
$       cpu_used = cpu_used + cpu_executive
$    endif
$    if f$extract(0, 15, r) .eqs. "Supervisor Mode"
$    then
$       cpu_supervisor = f$element(0, ".", f$element(3, " ", r))
$       cpu_used = cpu_used + cpu_supervisor
$    endif
$    if f$extract(0,  9, r) .eqs. "User Mode"
$    then
$       cpu_user = f$element(0, ".", f$element(3, " ", r))
$       cpu_used = cpu_used + cpu_user
$    endif
$    if f$extract(0, 18, r) .eqs. "Compatibility Mode"
$    then
$       cpu_compatibility = f$element(0, ".", f$element(3, " ", r))
$       cpu_used = cpu_used + cpu_compatibility
$    endif
$    if f$extract(0,  9, r) .eqs. "Idle Time"
$    then
$       cpu_idle = f$element(0, ".", f$element(3, " ", r))
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
$  cpu_total = cpu_used + cpu_idle
$  cpu_pct = cpu_used * 100 / cpu_total
$       write sys$output "CPU STATISTICS OK (''cpu_pct'% usado.): interrupt=''cpu_interrupt' ",-
"mpsynch=''cpu_mpsynch' kernel=''cpu_kernel' ",-
"executive=''cpu_executive' supervisor=''cpu_supervisor' ",-
"user=''cpu_user' compatibility=''cpu_compatibility' idle=''cpu_idle'|",-
"'CpuInterrupt'=''cpu_interrupt' 'CpuMpsynch'=''cpu_mpsynch' 'CpuKernel'=''cpu_kernel' ",-
"'CpuExecutive'=''cpu_executive' 'CpuSupervisor'=''cpu_supervisor' 'CpuUser'=''cpu_user' ",-
"'CpuCompatibility'=''cpu_compatibility' 'CpuIdle'=''cpu_idle'"
$  endif
$  if p1 .eqs. "CPUINT"
$  then
$       write sys$output "CPU Interrupt State - ''cpu_interrupt'|",-
"CpuInterrupt=''cpu_interrupt';;;;"
$  endif
$  if p1 .eqs. "CPUMPS"
$  then
$       write sys$output "CPU MP Synchronization - ''cpu_mpsynch'|",-
"CpuMpsynch=''cpu_mpsynch';;;;"
$  endif
$  if p1 .eqs. "CPUKER"
$  then
$       write sys$output "CPU Kernel Mode - ''cpu_kernel'|",-
"CpuKernel=''cpu_kernel';;;;"
$  endif
$  if p1 .eqs. "CPUEXE"
$  then
$       write sys$output "CPU Executive Mode - ''cpu_executive'|",-
"CpuExecutive=''cpu_executive';;;;"
$  endif
$  if p1 .eqs. "CPUSUP"
$  then
$       write sys$output "CPU Supervisor Mode - ''cpu_supervisor'|",-
"CpuSupervisor=''cpu_supervisor';;;;"
$  endif
$  if p1 .eqs. "CPUUSR"
$  then
$       write sys$output "CPU User Mode - ''cpu_user'|",-
"CpuUser=''cpu_user';;;;"
$  endif
$  if p1 .eqs. "CPUCMP"
$  then
$       write sys$output "CPU Compatibility Mode - ''cpu_compatibility'|",-
"CpuCompatibility=''cpu_compatibility';;;;"
$  endif
$  if p1 .eqs. "CPUIDL"
$  then
$       write sys$output "CPU Idle Time - ''cpu_idle'|",-
"CpuIdle=''cpu_idle';;;;"
$  endif
$  if p1 .eqs. "PRC"
$  then
$       write sys$output "CPU OK - [''proc_count' processes running on ''nodename']|",-
"ProcCount=''proc_count';;;;"
$  endif
$  if p1 .eqs. "PFR"
$  then
$       write sys$output "PAGING OK - [''page_fault_rate' page fault rate on ''nodename']|",-
"PageFaultRate=''page_fault_rate';;;;"
$  endif
$  if p1 .eqs. "PRR"
$  then
$       write sys$output "PAGING OK - [''page_read_rate' page read rate on ''nodename']|",-
"PageReadRate=''page_read_rate';;;;"
$  endif
$  if p1 .eqs. "FPL"
$  then
$       write sys$output "MEMORY OK - [''free_list_size' pages in free list size on ''nodename']|",-
"MemFreeList=''free_list_size';;;;"
$  endif
$  if p1 .eqs. "MPL"
$  then
$       write sys$output "MEMORY OK - [''modif_list_size' pages in modified list size on ''nodename']|",-
"MemModifiedList=''modif_list_size';;;;"
$  endif
$  if p1 .eqs. "DIO"
$  then
$       write sys$output "I/O OK - [''dio_rate' Direct I/O rate on ''nodename']|",-
"DirectIO=''dio_rate';;;;"
$  endif
$  if p1 .eqs. "BIO"
$  then
$       write sys$output "I/O OK - [''bio_rate' Buffered I/O rate on ''nodename']|",-
"BufferedIO=''bio_rate';;;;"
$  endif
$ !
$ if f$search ( RPT_FILE ) .nes. "" then deletes/noconfirm/nolog 'RPT_FILE';*
$ exit