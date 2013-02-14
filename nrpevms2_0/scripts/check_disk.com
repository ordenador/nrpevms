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
$ if p1 .eqs. "" 
$ then 
$   exit
$ endif
$!
$ diskname  = p1
$ nodename  = f$getsyi("NODENAME")  
$ factor = " / (2097152)
$ diskspace = f$getdvi("''diskname'","MAXBLOCK")   'factor
$ diskfree  = f$getdvi("''diskname'","FREEBLOCKS") 'factor
$ diskused  = (diskspace - diskfree)
$ per_free  = (diskfree * 100) / (diskspace)
$!
$ write sys$output "DISK OK - [",          -
	diskfree * 1024 , " kB (", per_free, "%) free on ", -
	''nodename', "$", diskname - ":" , "]"
$!
$ if per_free .lt. 80
$ then
$   EXIT nrpe_ok
$ endif
$ if per_free .lt. 90
$ then
$   EXIT nrpe_warn
$ endif
$ EXIT nrpe_err
