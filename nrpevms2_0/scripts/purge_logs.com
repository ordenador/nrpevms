$ purge /nolog/IGNORE=INTERLOCK/KEEP=3 nrpe$:NRPE.LOG
$ purge /nolog/IGNORE=INTERLOCK/KEEP=3 nrpe$log:NRPE.LOG
$ exit