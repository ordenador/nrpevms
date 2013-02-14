$ define sys$output nrpe$log:nrpe.log
$ define sys$error  nrpe$log:nrpe.log
$ nrpe_aux="$nrpe$:nrpe_aux.exe"
$ nrpe_aux -c nrpe$:nrpe.cfg -d 
