#ifndef _VIDEO_TEXT_MODE_H_
#define _VIDEO_TEXT_MODE_H_

#include "driver_structs.h"

void vidPrintMessage(VIDEO_TEXTMODE_DRIVER* pDriver);


extern void vidOutputString(VIDEO_TEXTMODE_DRIVER* pDriver, char* pString);


#endif