
#include "video_textmode.h"



void vidPrintMessage(VIDEO_TEXTMODE_DRIVER* pDriver)
{
    vidOutputString(pDriver, "Some Message from C\n");
}