#include "timer.h"

// Get time
float timer_time(XTime* xtimer)
{
	XTime_GetTime(xtimer);
    return *xtimer;
}

// Calculate the time differemce
float time_diff(float start_time, float stop_time)
{
	return ((float) (stop_time - start_time)/COUNTS_PER_SECOND);
}
