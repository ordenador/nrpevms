$ set mess/noFACILITY/noIDENTIFICATION/noSEVERITY/noTEXT
$ write sys$output "Test of NRPED is ok ''p1'"
$ EXIT ''p1'
