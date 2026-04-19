#ifndef _VIDEO_TEXT_MODE_H_
#define _VIDEO_TEXT_MODE_H_

#include <stdint.h>

#include "driver_structs.h"

extern void vidClearScreen(VIDEO_TEXTMODE_DRIVER* pDriver);
extern void vidSetCursor(VIDEO_TEXTMODE_DRIVER* pDriver, int8_t row, int8_t col);
extern void vidOutputChar(VIDEO_TEXTMODE_DRIVER* pDriver, char c);
extern void vidOutputString(VIDEO_TEXTMODE_DRIVER* pDriver, char* pString);


#endif