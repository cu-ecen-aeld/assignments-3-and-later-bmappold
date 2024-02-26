//HW #2
// 
#include <stdio.h> 
#include <stdlib.h>
#include <syslog.h>

int main( int argc, char *argv[]) {
	if( argc == 3 ) {
		/* for testing:
		printf("Number Of Arguments Passed: %d\n", argc);
		for (int i = 0; i < argc; i++)
			printf("argv[%d]: %s\n", i, argv[i]);    */
		//open file
		FILE *fp;
		if ((fp = fopen( argv[1], "w")) == NULL){
			printf("Error opening file. \n");
			openlog (NULL, 0, LOG_USER);
			syslog (LOG_ERR, "Error opening file. \n");
			//use syslog to log any unexpected errors with LOG ERR level
			closelog ();
			exit(1);
		}
		fprintf(fp, "%s", argv[2]);
		fclose(fp);
		//printf("Success1! \n");
		//syslog stuff
		//set up syslog using LOG USER facility
		//setlogmask (LOG_UPTO (LOG_NOTICE));
		openlog (NULL, 0/*LOG_CONS | LOG_PID | LOG_NDELAY*/, LOG_USER);
		//write a message "writing string to file", 1st and 2nd arguments passed, written at LOG DEBUG level
		syslog (LOG_DEBUG, "Writing %s to file: %s", argv[2], argv[1]);
		//use syslog to log any unexpected errors with LOG ERR level
		closelog ();
		//printf("Success2! \n");
	}
	else {
		printf("Two arguments expected.\n");
		openlog (NULL, 0, LOG_USER);
		syslog (LOG_ERR, "Error: incorrect number of arguments. \n");
		//use syslog to log any unexpected errors with LOG ERR level
		closelog ();
		//return 1;
		exit(1);
	}
	return 0;
}
