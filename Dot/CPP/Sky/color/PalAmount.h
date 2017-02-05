#import "Tr3.h"

typedef enum {
	ValError,
	ValNotInRange,
	ValChanged,
	ValSame,
} ValResult;

struct PalAmount {
    
    int deflt;	// default, ==0 calc from parent, >0 explicit
    int less;	// upper bound
    int more;	// lower bound
    int div;	// abstract divisor
    int muy;	// abstract multiplyer
    
    PalAmount();
    void init();
    
    void equals  (PalAmount&); 
    bool divide  (int i);		// set divisor
    bool multiply(int i);		// set multiplyer
    bool size (int i);			// set palette size ==0 makes it abstract and dependant on parent
    bool lessThan (int i);		// set upper bound
    bool greaterThan(int i);	// set lower bound
    bool inRange(int val);	// value is inside range
};
