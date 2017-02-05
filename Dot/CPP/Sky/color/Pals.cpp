#import "../main/CellMain.h"
#import "../main/SkyDefs.h" 
#import "../color/Pals.h"
#import "../color/palSet.h"
#import "../pixel/Pix.h"
#import "../time/SkyClock.h"
#import <stdlib.h>
#import <math.h>

#define PrintPals(...)  //DebugPrint(__VA_ARGS__)

Pals::Pals() {
        
	newPal = true;
	rips   = 0;	// starting place for ripples
	dyna   = 0; // starting place for dynamic palette
	flip   = 0;
	fractalized[0]=false;
	fractalized[1]=false;
}
void Pals::bindTr3(Tr3*root) {

    Tr3*pal = root->bind("pal");
    
    Tr3*status = pal->bind("status");  
	bwOn  = status->bind("bw");
	bwVal = status->bind("bwVal");
    
    Tr3*change = pal->bind("change");
 	xfade  = change->bind("xfade");
	smooth = change->bind("smooth");
    insert = change->bind("insert");
    
    Tr3*ripple  = pal->bind("ripple");
    hue = ripple->bind("hue");
    sat = ripple->bind("sat");
    val = ripple->bind("val");

    Tr3*add = change->bind("add", (Tr3CallTo)(&Pals::call_palsShift),  (void*)this,0);
    Tr3*hue = ripple->bind("hue", (Tr3CallTo)(&Pals::call_palsRipple), (void*)this,0);
    
    change->bind("remove", (Tr3CallTo)(&Pals::call_palsShift),  (void*)this, (void*) &palSet.Hsv_Nil);
    change->bind("zeno"  , (Tr3CallTo)(&Pals::call_palsFractal),(void*)this, (void*) 0);
    change->bind("back"  , (Tr3CallTo)(&Pals::call_palsBack),   (void*)this, (void*) 0);
}
void Pals::initPresets() {
    
    int i=0;
    preset[i++] = &palSet.Pal_kw;
    preset[i++] = &palSet.Pal_kwk;
    preset[i++] = &palSet.Pal_wkw;
    preset[i++] = &palSet.Pal_kwz;
    preset[i++] = &palSet.Pal_wkz;
    
    preset[i++] = &palSet.Pal_krgbk;
    preset[i++] = &palSet.Pal_krygbk;
    preset[i++] = &palSet.Pal_kroygbpk;
    preset[i++] = &palSet.Pal_kroygbivk;
    preset[i++] = &palSet.Pal_wroygbpw;

#undef Pal5
#define Pal5(a)\
preset[i++] = &palSet.Pal_k##a##w;\
preset[i++] = &palSet.Pal_k##a##k;\
preset[i++] = &palSet.Pal_w##a##w;\
preset[i++] = &palSet.Pal_k##a##z;\
preset[i++] = &palSet.Pal_w##a##z;
    
    Pal5(r)
    Pal5(rrro)
    Pal5(o)
    Pal5(oooy)
    Pal5(y)
    Pal5(yyyg)
    Pal5(g)
    Pal5(gggb)
    Pal5(b)
    Pal5(bbbi)
    Pal5(i)
    Pal5(iiiv)
    Pal5(v)
    Pal5(vvvr)    
    
    preset[i] = 0;
        
}
void Pals::init(Tr3*root) {
    
    bindTr3(root);
    cycle.bindTr3(root);
    for (int i=0; i<RipMax; i++) {
        ripples[i].bindTr3(root);
    }
    initPresets();
	pal[0].copy(palSet.Pal_kroygbpk); 
    pal[0].renderPal(256);
    
	pal[1].copy(palSet.Pal_kwk); 
    pal[1].renderZenoPal(256);
	newPal = true;   
}

Hsv* Pals::getHsvFromEnum(int num) {
    
    Hsv*hsv;
    switch (num) {
        default:
        case 0: hsv = &palSet.Hsv_Red   ; break;
        case 1: hsv = &palSet.Hsv_Red   ; break;
        case 2: hsv = &palSet.Hsv_Orange; break;
        case 3: hsv = &palSet.Hsv_Yellow; break;
        case 4: hsv = &palSet.Hsv_Green ; break;
        case 5: hsv = &palSet.Hsv_Blue  ; break;
        case 6: hsv = &palSet.Hsv_Indigo; break;
        case 7: hsv = &palSet.Hsv_Violet; break;
        case 8: hsv = &palSet.Hsv_Black ; break;
        case 9: hsv = &palSet.Hsv_White ; break;
    }
    return hsv;
}
void Pals::palsShift(Tr3*from,void*vp) {
    
    
        Hsv*hsv = getHsvFromEnum(((Tr3ValScalar*)from->val)->num);
         int i = ((float)*xfade>128 ? 1 : 0); // which palette is more obvious
        if (pal[i].shift(*hsv,(int)*insert)) {
            pal[i].renderPal(256);
            newPal = true;
        }

}

void Pals::palsRipple(Tr3*from,void*vp) {
    
        static Hsv hsv;
        hsv.h = (int)*hue;
        hsv.s = (int)*sat;
        hsv.v = (int)*val;
        ripples[rips%RipMax].start(hsv);
        rips++;

}

void Pals::palsBack(Tr3*from,void*vp) {
    
	tem.copy(pal[1]);
	pal[1].copy(pal[0]);
	pal[0].copy(tem);
    
	tem.copy(palBack[1]);
	palBack[1].copy(palBack[0]);
	palBack[0].copy(tem);
    
	bool temp = fractalized[1];
	fractalized[1] = fractalized[0];
	fractalized[0] = temp;
    
    pal[1].renderPal(256);
	pal[0].renderPal(256); 
	newPal = true; 
}
void Pals::palsFractal(Tr3*from,void*vp) { // fractalize palette
    
	int i = ((float)*xfade>128 ? 1 : 0); // which palette is more obvious
    
	if (fractalized[i]) {
        
		fractalized[i] = false;
		pal[i].copy(palBack[i]);		// revert vback
    }
	else {
        
		fractalized[i] = true;
		palBack[i].copy(pal[i]);
		frac[i].copy(pal[i]); 
		pal[i].setPal(pal[i]);
		pal[i].subPals.push_back(&frac[i]);
    }
    pal[i].renderPal(256);
    newPal = true;
}

void Pals::goFade() {

    static float oldFade = 0;
    
	if (fabs((float)*xfade - oldFade) > (float)*smooth) {
        
		oldFade = (oldFade < (float)*xfade
                   ? MIN(oldFade + (float)*smooth, (float)*xfade)
                   : MAX(oldFade - (float)*smooth, (float)*xfade));
		final.fade(pal[0].rgbs, pal[1].rgbs, oldFade);
    }
	else {
        
		final.fade(pal[0].rgbs, pal[1].rgbs, *xfade);
		oldFade = *xfade; 
    }
}

void Pals::goPal() {
    
    if (!xfade)
        return;
    
    goFade();
	if (cycle.goCycle(final)) {
        
        newPal=true;
    }
	for (int i=0; i<RipMax; i++) {
        
		if (ripples[i].going(final)) {
            
			newPal=true;
        }
    }
	if ((int)flip>0) {
        
		final.flip();
		flip=flip&1;
		newPal=true;
    }
	if (*bwOn && *bwVal) {
        
		float ratio = ((float)*bwVal)/(bwVal->valMax());
		final.bw(ratio);
    }
}
void Pals::setPal(Pal &q) {
    
	int i = ((float)*xfade > 128 ? 1 : 0); // which palette is more obvious
	fractalized[i]=false;
	pal[i].copy(q);
    pal[i].renderPal(256);
    newPal = true; 
}
void Pals::dynaSet(int index) {
    
	if (index<DynaMax) {
        
		int i = ((int)*xfade>128 ? 1 : 0); // which palette is more obvious
		fractalized[i]=false;
		pal[i].copy(dynamic[index]);
        pal[i].renderPal(256);
        newPal = true; 
    }
}
bool Pals::dynaAdd(int index) {
    
	if (rips==0 || index>=DynaMax)
		return false;
    
	int size;
	if (dyna==rips)
		size = 1;
	else if (dyna>0)
    size = MIN(rips-dyna, RipMax);
	int start = max(0,rips-size);
    
	dyna = rips;
    
	dynamic[index].setPal(palSet.Pal_BlackBlack);
	int dynar = RipMax*index;
	for (int i=start; i<rips; i++)
    {
		dynaHsv[dynar].h = hsvs[i%RipMax].h;
		dynaHsv[dynar].s = hsvs[i%RipMax].s;
		dynaHsv[dynar].v = hsvs[i%RipMax].v;
		dynamic[index].shift(dynaHsv[dynar]);
		dynar++;
    }
	dynamic[index].shift(palSet.Hsv_Nil); // remove trailing black
	dynaSet(index);
	return true;
}
