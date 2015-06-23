#include <iostream>
#include <stdlib.h>
#include <ctime>
#include <sys/time.h>


double getTime(){
	struct timeval tp;
	static double last_timestamp = 0.0;
	double timestamp;
	gettimeofday (&tp, 0);
	timestamp = (double) tp.tv_sec * 1e6 + tp.tv_usec;
	return timestamp;
}
