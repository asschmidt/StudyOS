/*
 * Driver Structs Module
 *
 * This module provides structure definitions for lib_driver to help debugging
 *
 */

#include "driver_structs.h"


VIDEO_TEXTMODE_DRIVER gVideoTextmodeDriver __attribute__ ((section (".debug_helper"))) = {0};