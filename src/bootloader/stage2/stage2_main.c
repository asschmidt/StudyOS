#include "video_textmode.h"
#include "env_io.h"

extern VIDEO_TEXTMODE_DRIVER VGA_TEXTMODE_DRIVER;

void stage2Main()
{
    int intValue = 100;

    vidOutputString(&VGA_TEXTMODE_DRIVER, "Stage 2 Main started\n");

    simple_printf("Some Text %d\n", intValue);
}