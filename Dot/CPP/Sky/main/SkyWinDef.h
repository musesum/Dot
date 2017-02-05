#ifndef IncludeSkyWinDefH
#define IncludeSkyWinDefH

typedef unsigned char BYTE;
typedef unsigned short WORD;
typedef unsigned long DWORD;

#define LOBYTE(w)   ((BYTE)(w))
#define HIBYTE(w)   ((BYTE)(((WORD)(w) >> 8) & 0xFF))
#define LOWORD(l)   ((WORD)(DWORD)(l))
#define HIWORD(l)   ((WORD)((((DWORD)(l)) >> 16) & 0xFFFF))

#endif
