
#define MaxOscTouches 10

struct Tr3;

typedef enum {

    kOscProfile2Dobj,
    kOscProfile2Dcur,
    kOscProfile2Dblb,
    kOscProfile25Dobj,
    kOscProfile25Dcur,
    kOscProfile25Dblb,
    kOscProfile3Dobj,
    kOscProfile3Dcur,
    kOscProfile3Dblb,
    kOscProfileMidiNote,
} OscProfileType;

typedef enum {
    kX=0,
    kY=1,
    kZ=2,
    kF=3
} OscIndex;
