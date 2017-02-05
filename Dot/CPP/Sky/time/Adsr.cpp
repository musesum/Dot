#import "Adsr.h"

Adsr::Adsr() {
    
    atkTime=0;
    decTime=0;
    susTime=0;
    relTime=0;
    state=AdsrWait;  
}
void Adsr::bindTr3(Tr3*root) {
    
    Tr3*adsr = root->bind("time.adsr");
    aAmp = adsr->bind("attack.amp");
    aDur = adsr->bind("attack.dur");
    dAmp = adsr->bind("decay.amp");
    dDur = adsr->bind("decay.dur");
    sAmp = adsr->bind("sustain.amp");
    sDur = adsr->bind("sustain.dur");
    rAmp = adsr->bind("release.amp");
    rDur = adsr->bind("release.dur");
    on    = adsr->bind("on");
    count = adsr->bind("count");
    value = adsr->bind("value"); // used to be simply adsr
}
void Adsr::set(Adsr &q) {

    aAmp->setNow((float)*q.aAmp);   aDur->setNow((float)*q.aDur);
    dAmp->setNow((float)*q.dAmp);   dDur->setNow((float)*q.dDur);
    sAmp->setNow((float)*q.sAmp);   sDur->setNow((float)*q.sDur);
    rAmp->setNow((float)*q.rAmp);   rDur->setNow((float)*q.rDur);
    
    atkVal = q.atkVal;  atkTime = q.atkTime;
    decVal = q.decVal;  decTime = q.decTime;
    susVal = q.susVal;  susTime = q.susTime;
    relVal = q.relVal;  relTime = q.relTime;
    
    state   = q.state;
}
void Adsr::go() {

    switch (state) {
        case AdsrWait:      wait   ();  break;
        case AdsrAttack:    attack ();  break;
        case AdsrDecay:     decay  ();  break;
        case AdsrSustain:   sustain();  break;
        case AdsrRelease:   release();  break;
    }
}
inline void Adsr::wait() {

    if (*on) {
        state   = AdsrAttack;
        atkTime = *count;
        zapVal  = 0;
        value->setNow((float)0); // there's a new pulse in town
    }
}
inline void Adsr::attack() {

    int elapse = (int)*count - atkTime; 
    if (elapse > (int)*aDur) {
        
        state   = AdsrDecay;
        decTime = (int)*count;
        atkVal  = (int)*aAmp;
    }
    else if (!*on) { // bypass Sustain
    
        state = AdsrRelease;
        relTime = (int)*count;
        susTime = (int)*count; // skip sustain
        decTime = (int)*count; // and decay, so
        susVal  = atkVal; // set both equal to
        decVal  = atkVal; // last attack value
    }
    else {
        atkVal  = zapVal + (  ((int)*aAmp - zapVal) 
                            * elapse / (int)*aDur);
    }
   value->changeValNow(atkVal);
}
inline void Adsr::decay() {

    int elapse = (int)*count - decTime; 
    if (elapse > (int)*dDur) {
        
        state = AdsrSustain;
        susTime = *count;
        decVal  = *dAmp;
    }
    else if (!*on) {
        
        state = AdsrRelease;
        relTime = *count;
        susTime = *count;    // skip sustain
        susVal  = decVal;   // so same as decay
    }
    else {
        decVal = atkVal + (  ((int)*dAmp - atkVal) 
                           * elapse / (int)*dDur);
    }   
    value->changeValNow (decVal);
}
inline void Adsr::sustain() {

    int elapse = (int)*count - susTime; 
    if (elapse > (int)*sDur)
        susVal  = (int)*sAmp;
    else
        susVal = decVal + (  ((int)*sAmp - decVal) * elapse / (int)*sDur);
    
    if (!*on) {
        
        state = AdsrRelease;
        relTime = *count;
    }

    value->changeValNow(susVal);
}
inline void Adsr::release() {

    int elapse = (int)*count - relTime; 
    if (elapse > (int)*rDur) {
        
        state=AdsrWait;
        on->setNow((float)0);
        zapVal = 0;
        value->changeValNow(0);
    }
    else if (*on) {
        
        state=AdsrAttack; // another attack before completing release
        atkTime = *count;
        zapVal=relVal;        // start attack from current value
    }
    else {
        relVal = susVal+ ( ((int)*rAmp - susVal)
                          * elapse / (int)*rDur);
    }
    value->changeValNow(relVal);
}

