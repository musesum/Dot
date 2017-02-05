
#import "OsGetTime.h"
#import "mach/mach_time.h"


long double OSGetTime() {
    
    mach_timebase_info_data_t tTBI;                                                                               
    mach_timebase_info(&tTBI);                                                                                   
    long double _cv = 1E-9 * ((long double) tTBI.numer) / ((long double) tTBI.denom);                              
    return ((long double) mach_absolute_time()) * _cv ;                                                           
} 

CMTime CMTimeSinceStartup() {
    
    long double dTime = OSGetTime();
    CMTime thisTime = CMTimeMakeWithSeconds(dTime, 1000000000);
    return thisTime;
}