/*****************************************************************************
 *
 * Zakaria Yassine        07-17-2003  -  source added for VMS
 *  zakaria@sympatico.ca                  add specif for log functions
 *
 *
 *****************************************************************************/

#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <types.h>
#include <socket.h>
#include <netdb.h>
#include <in.h>
#include <inet.h>
#include <ctype.h>
#include <errno.h>

#define LOG_PID     111
#define LOG_DAEMON  777

#define LOG_ERR     99
#define LOG_DEBUG   20
#define LOG_NOTICE  10
#define LOG_INFO    00

void openlog(const char *ident, int logopt, int facility);
void closelog();
void syslog(int priority, char *message, ...);

