$ define sys$output NLA0: !nrpe$log:nrpe.log
$ define sys$error  NLA0: !nrpe$log:nrpe.log
$ nrpe_aux="$nrpe$:nrpe_aux.exe"
$ nrpe_aux -c nrpe$:nrpe.cfg -d
