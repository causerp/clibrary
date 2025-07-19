#ifndef CLIB_H
#define CLIB_H

#include <math.h>
#include <stdint.h>

#ifdef _WIN32
    #define CLIB_API __declspec(dllexport)
#else
    #define CLIB_API __attribute__((visibility("default")))
#endif

CLIB_API double_t add_numbers(int64_t a, int64_t b, int32_t c, float_t d);

#endif
