#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

void error_message(const char *format, ...) {
  va_list args;
  va_start(args, format);

  vfprintf(stderr, format, args);

  va_end(args);

  fprintf(stderr, "\n");
}
