
typedef unsigned short ushort;
typedef unsigned long ulong;
typedef unsigned char byte;
typedef unsigned int  unt;

#define AnimUserContinue (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState) 
// UIViewAnimationOptionAllowAnimatedContent

#define PI 3.14159265358979323846

#ifndef MAX
#define MAX(a,b) ( (a) > (b) ? (a) : (b))
#endif

#ifndef MIN
#define MIN(a,b) ( (a) < (b) ? (a) : (b))
#endif

#define SkyLog(a,b) if (a) {b;}
