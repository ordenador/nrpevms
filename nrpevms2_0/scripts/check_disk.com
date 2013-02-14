$!------------------------------------------------------------------------------
$!
$!                         Disk Check for Nagios
$!                        =======================
$!
$!      Parameters:
$!
$!           p1:  device name
$!
$!------------------------------------------------------------------------------
$
$! Limpia logs
$! @nrpe$scripts:PURGE_LOGS.COM
$
$ if p1 .eqs. ""
$ then
$   exit
$ endif
$!
$ diskname  = p1
$ nodename  = f$getsyi("NODENAME")
$! factor = " / (2097152)
$! Factor para transformar de blocks a MB: Bloques * (512)/(1024*1024) MB
$ factor = " / (2048)
$ diskspace = f$getdvi("''diskname'","MAXBLOCK")   'factor
$ diskfree  = f$getdvi("''diskname'","FREEBLOCKS") 'factor
$ diskused  = (diskspace - diskfree)
$ per_free  = (diskfree * 100) / (diskspace)
$ per_used  = (diskused * 100) / (diskspace)
$!
$ diskfree_k = diskfree * 1024
$ write sys$output "DISK OK - ''diskname' ''per_used'% (''diskused'MB) used. - free space: ''diskfree'MB (''per_free'%)| ",-
"''diskname'=''diskused'MB;",diskspace*90/100,";",diskspace*95/100,";0;",diskspace
$!
$ if per_free .lt. 90
$ then
$   EXIT nrpe_ok
$ endif
$ if per_free .lt. 95
$ then
$   EXIT nrpe_warn
$ endif
$ EXIT nrpe_err