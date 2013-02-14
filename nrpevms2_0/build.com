$ cc/define=(_VMS_WAIT)/pref=all nrpe_aux,utils,custom,check_nrpe
$ link nrpe_aux,utils,custom, a/opt
$ link check_nrpe,utils, a/opt
