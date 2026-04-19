#ifndef _ENV_IO_H_
#define _ENV_IO_H_

#include <stddef.h>
#include <stdarg.h>

int putchar(int c);

int simple_printf(char *fmt, ...);
int simple_sprintf(char *buf, char *fmt, ...);

#endif