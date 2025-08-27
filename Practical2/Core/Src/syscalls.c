/*
 * syscalls.c
 *
 *  Created on: Aug 27, 2025
 *      Author: kudzainyika
 */




// Core/Src/syscalls.c
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>

int _close(int)                         { errno = ENOSYS; return -1; }
int _lseek(int, int, int)               { errno = ENOSYS; return -1; }
int _read (int, void *, unsigned int)   { return 0; }
int _write(int, const void *, unsigned int) { return 0; }
int _fstat(int, struct stat *st)        { st->st_mode = S_IFCHR; return 0; }
int _isatty(int)                        { return 1; }

// Optional heap stub (only if malloc/new):
caddr_t _sbrk(int incr) {
  extern char _end;           // from linker script
  static char *heap_end;
  if (!heap_end) heap_end = &_end;
  char *prev = heap_end;
  heap_end += incr;
  return (caddr_t)prev;
}
