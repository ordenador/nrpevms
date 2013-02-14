/*****************************************************************************
 *
 * Zakaria Yassine        07-17-2003  -  source added for VMS
 *  zakaria@sympatico.ca                  add specif for log functions
 *                                       
 *
 *****************************************************************************/

#include <stdio.h>
#include <stdarg.h>
#include "common.h"

void openlog(const char *ident, int logopt, int facility){
        printf("nrped: opening log file....\n");
}

void closelog(){
        printf("nrped: closing log file....\n");
}

void syslog(int priority, char *message, ...){                    
        char buffer[MAX_INPUT_BUFFER];                            
        va_list arguments;                                        
                                                                  
        va_start(arguments, message);                             
                                                                  
        sprintf(buffer, message, va_arg(arguments, char *));      
        printf("%d: %s\n", priority, buffer);                  
                                                                  
        va_end(arguments);                                        
}                                                                 
                                                                  
