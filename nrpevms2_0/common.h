/************************************************************************
 *
 * COMMON.H - NRPE Common Include File
 * Copyright (c) 1999-2003 Ethan Galstad (nagios@nagios.org)
 * Last Modified: 03-05-2003
 *
 * License:
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 ************************************************************************/

#define PROGRAM_VERSION "2.0"
#define MODIFICATION_DATE "09-08-2003"

#define OK		0
#define ERROR		-1

#define TRUE		1
#define FALSE		0

#define STATE_UNKNOWN  	3	/* service state return codes */
#define	STATE_CRITICAL 	2
#define STATE_WARNING 	1
#define STATE_OK       	0


#define DEFAULT_SOCKET_TIMEOUT	10	/* timeout after 10 seconds */

#define MAX_INPUT_BUFFER	2048	/* max size of most buffers we use */
#define MAX_FILENAME_LENGTH     256

#define MAX_HOST_ADDRESS_LENGTH	256	/* max size of a host address */

#define NRPE_HELLO_COMMAND      "_NRPE_CHECK"

#define MAX_COMMAND_ARGUMENTS   16


/**************** PACKET STRUCTURE DEFINITION **********/

#define QUERY_PACKET		1		/* id code for a packet containing a query */
#define	RESPONSE_PACKET		2		/* id code for a packet containing a response */

#define NRPE_PACKET_VERSION_2   2               /* packet version identifier */
#define NRPE_PACKET_VERSION_1	1		/* older packet version identifiers (no longer supported) */

#define MAX_PACKETBUFFER_LENGTH	1024		/* max amount of data we'll send in one query/response */

typedef struct packet_struct{
	short    int packet_version;
	short    int packet_type;
	unsigned int crc32_value;
	short    int result_code;
	char      buffer[MAX_PACKETBUFFER_LENGTH];
        }packet;
