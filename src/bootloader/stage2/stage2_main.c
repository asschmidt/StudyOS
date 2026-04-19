#include "video_textmode.h"

extern VIDEO_TEXTMODE_DRIVER VGA_TEXTMODE_DRIVER;

void stage2Main()
{
    vidOutputString(&VGA_TEXTMODE_DRIVER, "Stage 2 Main started\n");
}