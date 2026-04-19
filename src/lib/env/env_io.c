
#include "video_textmode.h"

#include "env_io.h"

extern VIDEO_TEXTMODE_DRIVER VGA_TEXTMODE_DRIVER;

int putchar(int  c)
{
    vidOutputChar(&VGA_TEXTMODE_DRIVER, (char)c);

    return 0;
}