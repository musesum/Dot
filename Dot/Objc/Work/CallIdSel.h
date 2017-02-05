#ifndef CallIdSel_h
#define CallIdSel_h

#define Tr3Bind2(B,C) bind(B,(Tr3CallTo)(&C),(void*)new CallIdSel(self));

struct CallIdSel {
    
    CallIdSel(id id_) {
        tr3Id = id_;
    }
    id tr3Id;
};
#endif