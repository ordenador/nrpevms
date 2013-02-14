$ nrpe_aux == "$ nrpe$:nrpe_aux.exe"
$ check_nrpe == "$ nrpe$:check_nrpe.exe"
$ NRPE_ERR == 3   
$ NRPE_OK == 1
$ NRPE_WARN == 2 
$! define/syst nrpe$        SYS$SYSDEVICE:[NRPE2A.NRPEVMS2_0]
$! define/syst nrpe$log     SYS$SYSDEVICE:[NRPE2A.NRPEVMS2_0.log]
$! define/syst nrpe$scripts SYS$SYSDEVICE:[NRPE2A.NRPEVMS2_0.scripts]
