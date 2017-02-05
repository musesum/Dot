#import "CellRules.h"
#import "../main/CellMain.h"
#import "../main/SkyDefs.h" 
#import "../pixel/Univ.h"
#import "../pixel/Mix.h"
#import "../pixel/FaceMap.h"
#import "../pixel/Univ_def.h"  // relative rule location defines
#import <stdlib.h>
#import <stdio.h>
#import "CellRuleItem.h"
#import "TokTypes.h"

#define PrintRule(...)  //DebugPrint(__VA_ARGS__)
#define Rand32 (rand()|(rand()<<16))

void CellRules::init(Tr3* root, Pic* pic) {
 
    univ = &pic->univ;
    mix = &pic->mix;
    faceMap = &pic->facemap;
    
    rulePrev = 0;
    pushed = false;
    
    //TODO: memset(canvas, 0, sizeof(Tr3*)); ??

    cellRules = root->bind("cell.rule");
    cellGo    = root->bind("cell.go");
    cellNow   = root->bind("cell.now");
    // create callback to changeRule when cellNow is changed
    Tr3CallTo callTo = (Tr3CallTo)(&CellRules::call_changeRule);
    cellNow->bindCall(callTo,this,0);
    
    // parse list of rules
    for (Tr3* tr3 : cellRules->children) {
        addRule(tr3);
    }
    ruleNow = nameRules["null"];
 }


bool CellRules::addRule(Tr3*tr3) {
#define AddRule(fn) return addRuleCall(tr3,&CellRules::fn);
    switch (Str2int(tr3->name)) {
        case str2int("fill"):        AddRule(fill0);
        case str2int("one"):         AddRule(fill1);
        case str2int("zero"):        AddRule(fill0);
            
        case str2int("pause"):       AddRule(copy);
        case str2int("null"):        AddRule(copy);
        case str2int("copy"):        AddRule(copy);
        case str2int("add"):         AddRule(fade);
        case str2int("fade"):        AddRule(fade);
            
        case str2int("melt"):        AddRule(laplace);
        case str2int("laplace"):     AddRule(laplace);
            
        case str2int("average"):     AddRule(average);
        case str2int("timetunnel"):  AddRule(timetun);
        case str2int("slide"):       AddRule(slide);
        case str2int("drift"):       AddRule(drift);
        case str2int("fredkin"):     AddRule(fredkin);
        case str2int("zhabatinski"): AddRule(zha);
        case str2int("noise"):       AddRule(noise);
        case str2int("pixSort"):     AddRule(warren);
        case str2int("gas"):         AddRule(gas);
        case str2int("modulo"):      AddRule(modulo);
        default:                     return false;
    }
}
bool CellRules::addRuleCall(Tr3*tr3,RuleCall call) {
    
    CellRuleItem* ruleItem = new CellRuleItem(tr3,call);
    nameRules[tr3->name] = ruleItem;
    
    if (ruleItem->ruleOn) {
        Tr3CallTo callTo = (Tr3CallTo)(&CellRules::call_bangRule);
        ruleItem->ruleOn->bindCall(callTo,this,0);
        return true;
    }
    return false;
}



/* if bang() directly on a rule then change cellNow
 * for example: SkyRoot->bind("cell.rule.laplace")->bang();
 * will result: cellNow->setNow("laplace");
 */
void CellRules::bangRule(Tr3*tr3, void*ignore) {
    bool isOn = *tr3;
    if (isOn && tr3->parent) {
        cellNow->setNow((char*)tr3->parent->name.c_str());
    }
}
/* when cellNow's value is changed,
 * it looks up nameRules[*value]
 * and switches over to that rule
 */
void CellRules::changeRule(Tr3*tr3, void*ignore) {
    
    string name = *tr3;
    CellRuleItem* ruleNext = nameRules[name];
    if (ruleNext) {
        setRule(tr3, ruleNext);
    }
    else if (addRule(tr3)) {
        fprintf(stderr, "\n*** adding rule Tr3::%s:%s\n",tr3->parentPath(),name.c_str());
    }
    else {
        fprintf(stderr, "\n*** no call for rule Tr3::%s:%s\n",tr3->parentPath(),name.c_str());
    }
}
/* change to new Rule
 * some rules are run only once 
 * so, need to push and pop that rule
 */
void CellRules::setRule(Tr3*tr3, CellRuleItem*ruleNext) {
    
    pushed = *ruleNext->runOnce;
    if (pushed) {
        if (ruleNow == ruleNext) {
            return;			// double pushed, so skip
        }
        else {
            rulePrev = ruleNow;
            ruleNow = ruleNext;
            return;
        }
    }
    else {
        ruleNow = ruleNext;
        if (rulePrev != ruleNow) {
            rulePrev = ruleNow;
            if (ruleNow->mix2univ) {
                fromMix();
            }
            mix->mx = &ruleNext->mix;
        }
    }
}
/* when changing over to a new rule
 * optionally see if copying contents of output
 * from previous rule
 */
bool CellRules::fromMix() {
    
    for (int i=0; i < faceMap->univSurfs; i++) {
        
        univ->getU(i, next, prev); /// next = univ->next;
        byte* buf = mix->buf[i].buf;
        if (buf) {
            int ys  = univ->ys;
            int xs  = univ->xs;
            int bs2 = univ->bs2;
            for	 (y=0; y < ys; y++, next += bs2)  {
                for (x=0; x < xs; x++, buf++, next++)	{
                    *next = (*next & 0xffffff00) + (*buf & 0xff); //!! crash when
                }
            }
        }
    }
    return true;
}

CellRuleItem* CellRules::getRule(string* name) {

    CellRuleItem* ruleItem = nameRules[*name];
    return ruleItem ? ruleItem : ruleNow ? ruleNow : nameRules["null"];
}

void CellRules::go() {
    
    univ->getU(0,next,prev);
    buf = mix->buf[0].buf;
    mix->mx = &ruleNow->mix;
    (this->*(ruleNow->ruleCall))();
    
    if (pushed) {
        
        pushed=false;
        ruleNow = rulePrev;				// revert back to previous rule
    }
}

#define ForXYP \
for	(y=0; y<univ->ys; y++,		 prev+=univ->bs2, next+=univ->bs2) \
for (x=0; x<univ->xs; x++, buf++, prev++,	     next++)

#define ForXY \
for	(y=0; y<univ->ys; y++, prev+=univ->bs2, next+=univ->bs2) \
for (x=0; x<univ->xs; x++, prev++,		  next++)

#define NextR  \
int r2  = 256-r1;\
int r3 = (HiC+(r1&0x3));\
int r  = (r3<<16) | (r2<<8) | r1;\
*next = r;

#define ForXYR(f) ForXY { int r1 = (f); NextR } break;

void CellRules::average() {
    
	int cand[8],i,j;
    
    switch ((int)*ruleNow->version) {
            
        case 4:
            ForXY	{
                cand[0]=0;		cand[1]=0; 
                cand[2]=0;		cand[3]=0;
                cand[4]=0;		cand[5]=0; 
                cand[6]=0;		cand[7]=0;
                
                cand[LiNW&7]++;	cand[LiN &7]++;
                cand[LiNE&7]++;	cand[LiE &7]++;
                cand[LiSE&7]++;	cand[LiS &7]++;
                cand[LiSW&7]++;	cand[LiW &7]++;
                cand[LiC &7]+=1;
                for (i=0, j= 0; i <8; i++) 
                    if (cand[j] < cand [i]) 
                        j = i;
                int r1 = (C&0xf8) + (j&7);
                NextR
            }
            break;
        case 3:
            ForXY	{
                cand[0]=0;		cand[1]=0; 
                cand[2]=0;		cand[3]=0;
                cand[4]=0;		cand[5]=0; 
                cand[6]=0;		cand[7]=0;
                
                cand[LiNW&7]++;	cand[LiN &7]++;
                cand[LiNE&7]++;	cand[LiE &7]++;
                cand[LiSE&7]++;	cand[LiS &7]++;
                cand[LiSW&7]++;	cand[LiW &7]++;
                
                for (i=0, j= 0; i <8; i++) 
                    if (cand[j] < cand [i]) 
                        j = i;
                int r1 = (C&0xf8) + (j&7);
                NextR
            }
            break;
		case 2:
            ForXY {
                int ul = abs(LoNW-LoN)+abs(LoN-LoC)+abs(LoC-LoW)+abs(LoW-LoNW);
                int ur = abs(LoNE-LoE)+abs(LoE-LoC)+abs(LoC-LoN)+abs(LoN-LoNE);
                int lr = abs(LoSE-LoS)+abs(LoS-LoC)+abs(LoC-LoE)+abs(LoE-LoSE);
                int ll = abs(LoSW-LoW)+abs(LoW-LoC)+abs(LoC-LoS)+abs(LoS-LoSW);
                
                int m = max(max(ul,ur),max(ll,lr));
                int a = 0;
                int d = 0;
                if (ul==m) {a += (LoNW+LoN+LoC+LoW)/4; d++;}
                if (ur==m) {a += (LoNE+LoE+LoC+LoN)/4; d++;}
                if (lr==m) {a += (LoSE+LoS+LoC+LoE)/4; d++;}
                if (ll==m) {a += (LoSW+LoW+LoC+LoS)/4; d++;}
                
                int r1 = a / d;
                NextR
            }
            break;
		case 1:
            ForXY	{
                int r1 = ((LoN + LoS + LoE + LoW + LoC)/5)&0xff;
                NextR
            }
            break;
    }
}
void CellRules::laplace() {
    
#define Range(x,min,max) (x<min ? min : (x>max ? max :x))
    
    int version = (int)*ruleNow->version;
	switch (version) {
            
		case 1:
            ForXY	{
                int r1 = (    LiC +LiN+LiS+LiE+LiW)/5;
                int r2 = ((C>>10)+HiN+HiS+HiE+HiW)/68; // same as ((HiC*8)+HiN+HiS+HiE+HiW)
                
                int d1=(0xffff-r1)>>9;	
                
                r1 = Range(r1+d1, 0, 0xffff);
                r2 = Range(r2   , 0, 0xffff);
                
                int r = r1 | (r2<<16);
                *next = r;
            }
            break;
		case 2:
            ForXY	{
                int r1 = (    LiC +LiN+LiS+LiE+LiW)/5;
                int r2 = ((C>>13)+HiN+HiS+HiE+HiW)/12;
                
                int d1=2*( (14*(0xffff-r1)) >> 9);	
                //int d2=  ( (14*(0xffff-r1)) >> 8);	
                
                r1 = Range(r1+d1, 0, 0xffff);
                r2 = Range(r2	, 0, 0xffff);
                
                int r = r1 | (r2<<16);
                *next = r;
            }
            break;
        case 3:
            ForXY	{
                int r1 = (    LiC +LiN+LiS+LiE+LiW)/5;
                int r2 = ((C>>13)+HiN+HiS+HiE+HiW)/12;
                
                int d1=        (0xffff-r1)  >> 2;	
                
                r1 = Range(r1+d1, 0, 0xffff);
                r2 = Range(r2	, 0, 0xffff);
                
                int r = r1 | (r2<<16);
                *next = r;
            }
            break;
        case 4:
            ForXY	{
                int r1 = (    LiC +LiN+LiS+LiE+LiW)/5;
                int r2 = ((C>>13)+HiN+HiS+HiE+HiW)/12;
                
                int d1= (0xffff-r1) >> 1;
                
                r1 = Range(r1+d1, 0, 0xffff);
                r2 = Range(r2	, 0, 0xffff);
                
                int r = r1 | (r2<<16);
                *next = r;
            }
            break;
            
    }
}
void CellRules::timetun() {

	static int map0[] = {0,1,1,1,1,0};
	static int map1[] = {0,1,1,1,1,1,1,1,1,0};
    
    static Tr3* timeRepeat = 0;
    if (!timeRepeat) {
        timeRepeat = ruleNow->rule->bind("repeat");
    }
	int repeat = *timeRepeat;
    int version = (int)*ruleNow->version;
	for (int j=0; j<repeat; j++) {
        
        if (j>0) {
            
			univ->nextU();
			univ->setBorder(*faceMap);
			univ->getU(0,next,prev);
			buf = mix->buf[0].buf;
        }
        int cc = (version > 4); // map 5..6 to 0..1 (5..6 is for easy GUI selection)
  
        switch (version) {
                
            case 1:
            case 5: ForXYR((map0[(N&1)+(S&1)+(W&1)+(E&1)+(C&cc)]
                            ^ ((LiC>>1)&1))|(LiC<<1))
                
            case 2:
            case 6: ForXYR((map1[(N&1)+(S&1)+(W&1)+(E &1)+(C&cc)]
                            ^ ((LiC>>1)&1))|(LiC<<1))
                
            case 3:
            case 7:	ForXYR((map1[(NW&1)+(SW&1)+(NE&1)+(SE&1)+(C&cc)]
                            ^ ((LiC>>1)&1))|(LiC<<1))
                
            case 4:
            case 8: ForXYR((map1[(N&1)+(S&1)+(W&1)+(E&1)+(NW&1)+(SW&1)+(NE&1)+(SE&1)+(C&cc)]
                            ^ ((LiC>>1)&1))|(LiC<<1))
		}
    }
}
void CellRules::slide() {

    static Tr3* slideX = 0;
    static Tr3* slideY = 0;
    static Tr3* slideRange = 0;

    if (!slideX) {
        slideX     = ruleNow->rule->bind("slide.offset.x");
        slideY     = ruleNow->rule->bind("slide.offset.y");
        slideRange = ruleNow->rule->bind("slide.range");
    }
    
    int mask[8]; // bit slice mask 1,2,4,..,128
    int ofs[8]; // offset within array
    int i,j;
    
    #define OfsAve 8
    static int ofsX[8][OfsAve];
    static int ofsY[8][OfsAve];
    static bool firstTime = true;
    
    if (firstTime) {
        firstTime = false;
        for (i=0; i<8; i++)
            for (j=0; j<OfsAve; j++) {
                
                ofsX[i][j] = 0;
                ofsY[i][j] = 0;
            }
    }
    int ofsAveX = 0;
    int ofsAveY = 0;
    int x = *slideX;
    int y = *slideY;
    
    int range = abs(x)+abs(y)/2;

    for (i=0; i<8; i++) {
        for (j=OfsAve-1; j>0; j--) {
            
            ofsX[i][j] = ofsX[i][j-1];
            ofsY[i][j] = ofsY[i][j-1];
            ofsAveX += ofsX[i][j];
            ofsAveY += ofsY[i][j];
        }
        mask[i] = (1<<i); 

        ofsX[i][0] = ((mask[i] * x * range) / 1000) / 1000;
        ofsY[i][0] = ((mask[i] * y * range) / 1000) / 1000;
        ofsAveX = (ofsAveX + ofsX[i][0])/OfsAve;
        ofsAveY = (ofsAveY + ofsY[i][0])/OfsAve;
        ofs[i] = univ->uxyOfs(ofsAveX, ofsAveY);
    }
    int* first = prev;
    int* last = prev+(univ->xs*univ->ys);
    
    switch ((int)*ruleNow->version) {
            
        case 3: {
            
            ForXY {
                
                int r1=0;
                for (i=0; i<8; i++) {
                    
                    int*pp = prev+ofs[i];
                    if (pp>=first && pp < last) {
                        
                        r1 += *(pp)&mask[7-i]; // this is the only difference
                    }
                }
                int r2  = 255-r1;
                int r3  = (C>>24)+(r1 & 0x3);
                int r  = (r3<<24) | (r2<<16) | r1<<8 | LoC;
                *next = r; 
                
                //*next = LoC | (r1<<8) | (C & 0xFFFF0000);
            }
            break;
        }
        case 4: {
            
            ForXY {
                
                int r1=0;
                for (i=0; i<8; i++) {
                    
                    int*pp = prev+ofs[i];
                    if (pp>=first && pp < last) {
                        
                        r1 += *(pp)&mask[i]; // this is the only difference
                    }
                }
                int r2  = 255-r1;
                int r3  = (C>>24)+(r1 & 0x3);
                int r  = (r3<<24) | (r2<<16) | r1<<8 | LoC;
                *next = r; 
            }
            break;
        }
        case 1: {
            
            ForXY {
                int r1  = ((LiN  &   1)+ 
                           (LiNE &   2)+ 
                           (LiE  &   4)+ 
                           (LiSE &   8)+ 
                           (LiS  &  16)+ 
                           (LiSW &  32)+ 
                           (LiW  &  64)+ 
                           (LiNW & 128));								
                NextR
            }
            break;
        }
        case 2: {
            
            ForXY {
                int r1  = (LiN  &   GoDown )
                + (LiS  &   GoUp   )
                + (LiE  &   GoLeft )
                + (LiW  &   GoRight);
                NextR
            }
            break;
        }
    }
}

void CellRules::drift() {
    
    int version = (int)*ruleNow->version;
	int mask = (1<<version - 1)-1;
	int cand [4]; // border colors
    
    ForXY {
        
        if ((Rand32 & mask)==0) {
            
            cand [0] = 0; cand [1] = 0; cand [2] = 0; cand [3] = 0; 
            cand [N&3]++; cand [E&3]++; cand [S&3]++; cand [W&3]++;
            
            /*
             int buf =  self   &3;
             int q = (self+1)&3;
             int r = ((N&3)==buf) | ((N&3)==q)
             +((E&3)==buf) | ((E&3)==q)
             +((S&3)==buf) | ((S&3)==q)
             +((W&3)==buf) | ((W&3)==q)
             */
            if (    (  cand[((C+1)&3)] 
                     + cand[(C   &3)])
                == 4) {// all neighbors within 1 color?
                
                int r1 = LiC+1;
                NextR
            }
            else* next = C;
        }
    }
}
void CellRules::fredkin() {

    #define fredz(equ)  (( (C<<1) +  (( (C>>1) +equ ) &1 )) & 0xFF)
    int version = (int)*ruleNow->version;
	switch (version) {
            
		case 1:	ForXY {	int r1 = fredz(N  + W  + E  + S);  NextR }	break;
		case 2:	ForXY {	int r1 = fredz(NW + NE + SE + SW); NextR }	break;
		case 3:	ForXY {	int r1 = fredz(S  + NE + N  + NW); NextR }	break;		
        case 4:	ForXY {	int r1 = fredz(N  + W  + E  + S + C); NextR }	break;
    }
}
void CellRules::modulo() {

    static Tr3* modMod = 0;
    if (!modMod) {
        modMod = ruleNow->rule->bind("mod");
    }
	int mod = *modMod;
    
    int version = (int)*ruleNow->version;
    switch (version) {
            
		case 1: ForXYR (((LoN+LoE  + LoS+LoW))	% mod)
		case 2: ForXYR (((NW + NE  + SE + SW)	& 0xff) % mod)
		case 3: ForXYR (((N+E+S+W+NW+NE+SE+SW)	& 0xff) % mod)
		case 4:	ForXYR (((N+E+S+W+NW+NE+SE+SW+C)& 0xff) % mod)
		case 5:	ForXYR (((NW+NE+SE+SW+C) 		& 0xff) % mod)
		case 6:	ForXYR (((N+E+S+W+C)			& 0xff) % mod)
        case 7: ForXYR (((LoN^LoE^LoS^LoW^LoC)  & 0xff) % mod)
        case 8: ForXYR (((LoN|LoE|LoS|LoW|LoC)  ^ 0xff) % mod)
        case 9: ForXYR (((LoN|LoE|LoS|LoW)^LoC  & 0xff) % mod)

    }
}
void CellRules::zha() {

	int bits = 3;
    int version = (int)*ruleNow->version;
	int zmapt = version>>1;		// zmap threshold
	int zmapa = ((version&1)<<1) +zmapt;// zmap annealing //TODO: verify precedence correction ((zversion&1)<<1)
    
    static Tr3*zhaRepeat = 0;
    if (!zhaRepeat) {
        zhaRepeat = ruleNow->rule->bind("repeat");
    }
    int repeat = (int)*zhaRepeat;
#if 0

	int mask = ((1<<bits)-1)<<2;
    
    ForXY {
        
        int oldself  = C & 1;
        int alarm    = C & 2; //(C >> shift) & 1;
        int time     = C & 0xFC;//(C >> 1) & mask;
        int timeMask = C & mask;
        int newself  = (timeMask==0);
        
        if (timeMask > 0 || (oldself && alarm))
            time += 4;
        
        int sum =  ((NW&1)+(N&1)+(NE&1)+(E&1)+
                    (SE&1)+(S&1)+(SW&1)+(W&1));

        
        alarm =	(	(sum  > zmapt)	// threshold
                 &&	(sum != zmapa)); // annealed
        
        int r1 = (time&0xFC) | alarm<<1 | newself;
        int r2  = (255^r1)&255;
        int r3 = (HiC+(r1&0x3));
        int r  = (r3<<16) | (r2<<8) | r1;
        *next = r;
    }	
#else

	int shift= bits+1;
    int mask = (1<<bits)-1;

    if (repeat==0) 
        repeat = 1;
    
    for (int j=0; j<repeat; j++) {
        
        if (j>0) {
            
            univ->nextU();
            univ->setBorder(*faceMap);
            univ->getU(0,next,prev);
            buf = mix->buf[0].buf;
        }
        ForXY {
            
            int alarm  = (C >> shift) & 1;
            int time   = (C >> 1) & mask;
            int newself= (time==0);
            
            if (time > 0)		time --;
            if (C & alarm & 1)	
                time=mask;
            
            int sum =  ((NW&1)+(N&1)+(NE&1)+(E&1)+
                        (SE&1)+(S&1)+(SW&1)+(W&1));
            
            alarm =	(	(sum  > zmapt)	// threshold
                     &&	(sum != zmapa)); // annealed
            
            int r1 = (alarm << shift) | (time << 1) | newself;
            NextR
        }
    }
#endif
}
void CellRules::noise() {

    static Tr3* noiseBits = 0;
    if (!noiseBits) {
        noiseBits = ruleNow->rule->bind("noise.bits");
    }
	int prob = 1<<(int)(*noiseBits);
	int count = Rand32%prob;
	
    ForXY {
        
        if (--count<0) {
            
            count = Rand32%prob; // this saves on calls to Rand32
            *next = (C&0xffffff00) + (rand()&0xff);
        }
        else* next = C;
    }
}

void CellRules::fade() {

    int version = (int)*ruleNow->version;

    int fader[256];
    int fadeMinus = (1<<version);
    int fademax = (version==0 ? 256 : 255)-fadeMinus;
    for (int fi=0;fi<256;fi++) {
        fader[fi] = (fi*fademax)/255;
    }
    if (version==0) {
        ForXY {
            int r1 = x*y;
            NextR
        }
    }
    else if (version==1) {
        ForXY {
            int r1 = fader[LoC];
            NextR
        }
    }
    else {
        int hiMinus = fadeMinus/2;
        ForXY {
            int r1 = fader[LoC];
            int r2  = 255-r1;
            int hiC = HiC;
            int hiFade = hiC-hiMinus;
            if (hiFade < 0)
                hiFade = 0;
            int r3 = (hiFade+(r1&0x7)); // this is different from NextR
            int r  = (r3<<16) | (r2<<8) | r1;
            *next = r;
        }
    }
} 
void CellRules::copy() {

    //univ->nextU();
    ForXY {
        int r1 = LoC;
        NextR
    }
}
void CellRules::fill0() {
    
    int val = *ruleNow->canvas0;
    if (buf) {
        
        ForXYP	{
            
            *next = val;
            *prev = val;
            *buf  = val;
        }
    }
}

void CellRules::fill1() {
    
    int val = *ruleNow->canvas1;
    if (buf) {
        
        ForXYP	{
            
            *next = val;
            *prev = val;
            *buf  = val;
        }
    }
}

void CellRules::gas() {
    
    static int XNW[16]= {2,4,8,5,4,2,5,8,0,1,2,4,1,0,4,2}; // squared distances
    static int XNE[16]= {2,8,4,5,0,2,1,4,4,5,2,8,1,4,0,2};
    static int XSE[16]= {2,4,0,1,4,2,1,0,8,5,2,4,5,8,4,2};
    static int XSW[16]= {2,0,4,1,8,2,5,4,4,1,2,0,5,4,8,2};
    
    int left,leftX;
    int right,rightX;
    int r1,r2;
    
    int wd,w1,w2,
    ed,e1,e2,
    c0,c1,c2,c3,c4;
    
    switch ((int)*ruleNow->version) {
        case 1:
            univ->setBorder(*faceMap);
            
            ForXY	{
                if (LoNW>LoSW)	{ wd=LoNW-LoSW; w1=FromNw; w2=FromSw;}
                else			{ wd=LoSW-LoNW; w1=FromSw; w2=FromNw;}
                
                if (LoNE<LoSE)	{ ed=LoSE-LoNE; e1=FromNe; e2=FromSe;}
                else			{ ed=LoNE-LoSE; e1=FromSe; e2=FromNe;}
                
                if (wd>ed)		{ c1=w1; c2=e1; c3=w2; c4=e2;}
                else			{ c1=e1; c2=w1; c3=e2; c4=w2;}
                c0 = (((((c1<<3)+c2)<<3)+c3)<<3)+c4;
                *prev = LiC + (c0<<16);
            }
            
            univ->setBorder(*faceMap);
            univ->getU(0,next,prev);
            buf = mix->buf[0].buf;
            
            ForXY {
                
                if      (OctTest(HiNW,9,FromSe)) OctMove(r1,NW);
                else if (OctTest(HiNE,9,FromSw)) OctMove(r1,NE);
                else if (OctTest(HiSE,9,FromNw)) OctMove(r1,SE);
                else if (OctTest(HiSW,9,FromNe)) OctMove(r1,SW);
                
                else if (OctTest(HiNW,6,FromSe)) OctMove(r1,NW);
                else if (OctTest(HiNE,6,FromSw)) OctMove(r1,NE);
                else if (OctTest(HiSE,6,FromNw)) OctMove(r1,SE);
                else if (OctTest(HiSW,6,FromNe)) OctMove(r1,SW);
                
                else if (OctTest(HiNW,3,FromSe)) OctMove(r1,NW);
                else if (OctTest(HiNE,3,FromSw)) OctMove(r1,NE);
                else if (OctTest(HiSE,3,FromNw)) OctMove(r1,SE);
                else if (OctTest(HiSW,3,FromNe)) OctMove(r1,SW);
                
                else if (OctTest(HiNW,0,FromSe)) OctMove(r1,NW);
                else if (OctTest(HiNE,0,FromSw)) OctMove(r1,NE);
                else if (OctTest(SE,0,FromNw))   OctMove(r1,SE);
                else					         OctMove(r1,SW);
                
                *next = r1;
            }
            break;
            
        case 2:
            
#define Xnw XNW[HiNW & 0xf]
#define Xne XNE[HiNE & 0xf]
#define Xse XSE[HiSE & 0xf]
#define Xsw XSW[HiSW & 0xf]
            
            ForXY	{
                if	    (LoNW > LoSW)  { left  = LoNW;	leftX = Xnw;}
                else if (LoNW < LoSW)  { left  = LoSW;	leftX = Xsw;}
                else	   		       { left  = LoNW; leftX = MIN(Xnw,Xsw);}
                
                if (LoNE<LoSE){	right = LoNE; 	rightX= Xne;}
                if (LoNE>LoSE){	right = LoSE; 	rightX= Xse;}
                else		  {	right = LoNE;	rightX= MIN(Xse,Xne);}
                
                if	    (leftX < rightX)			r1 = left;	// shorter distance
                else if (leftX > rightX)			r1 = right;
                
                else if (LoNW==LoSW && LoNE!=LoSE)	r1 = right; // favor unique
                else if (LoNW!=LoSW && LoNE==LoSE)	r1 = left;
                
                else if (Xnw+Xsw < Xne+Xse)			r1 = left; // shorter combined distance
                else if (Xnw+Xsw > Xne+Xse)			r1 = right;
                
                else								r1 = LoC;
                
                r2  = ((r1==LoNW ? 8 : 0) +
                       (r1==LoNE ? 4 : 0) +
                       (r1==LoSE ? 2 : 0) +
                       (r1==LoSW ? 1 : 0));
                
                *next = r1 + (r2<<16);
            }
            break;
        case 3: {
            
            static int cycle=1;
            cycle++;
            
            switch (cycle&7) {
                    
                case 0: swap(univ,-1,-1); break;
                case 1: swap(univ, 0,-1); break;
                case 2: swap(univ,+1,-1); break;
                case 3: swap(univ,+1, 0); break;
                case 4: swap(univ,+1,+1); break;
                case 5: swap(univ, 0,+1); break;
                case 6: swap(univ,-1,+1); break;
                case 7: swap(univ,-1, 0); break;
            }
            univ->getU(0,next,prev);
            
            ForXY {
                int r1 = LoC;
                int r2  = 256-r1;
                int r3 = (HiC+(r1&0x3));
                int r  = (r3<<16) | (r2<<9) | r1;
                *next = r;
                //*next  = LoC;
            }
            break;
        }
    }
}
void CellRules::warren() {
    
    static int XNW[16]= {2,4,8,5,4,2,5,8,0,1,2,4,1,0,4,2}; // squared distances
    static int XNE[16]= {2,8,4,5,0,2,1,4,4,5,2,8,1,4,0,2};
    static int XSE[16]= {2,4,0,1,4,2,1,0,8,5,2,4,5,8,4,2};
    static int XSW[16]= {2,0,4,1,8,2,5,4,4,1,2,0,5,4,8,2};
    
    int  left, leftX;
    int right,rightX;
    int r1,r2;
    
    int wd,w1,w2,
    ed,e1,e2,
    c0,c1,c2,c3,c4;
    
    switch ((int)*ruleNow->version) {
            
        case 0:
            univ->setBorder(*faceMap);
            
            ForXY	{
                if (LoNW>LoSW)	{ wd=LoNW-LoSW; w1=FromNw; w2=FromSw;}
                else			{ wd=LoSW-LoNW; w1=FromSw; w2=FromNw;}
                
                if (LoNE<LoSE)	{ ed=LoSE-LoNE; e1=FromNe; e2=FromSe;}
                else			{ ed=LoNE-LoSE; e1=FromSe; e2=FromNe;}
                
                if (wd>ed)		{ c1=w1; c2=e1; c3=w2; c4=e2;}
                else			{ c1=e1; c2=w1; c3=e2; c4=w2;}
                c0 = (((((c1<<3)+c2)<<3)+c3)<<3)+c4;
                *prev = LiC + (c0<<16);
            }
            
            univ->setBorder(*faceMap);
            univ->getU(0,next,prev);
            buf = mix->buf[0].buf;
            
            ForXY {
                
                if      (OctTest(HiNW,9,FromSe)) OctMove(r1,NW);
                else if (OctTest(HiNE,9,FromSw)) OctMove(r1,NE);
                else if (OctTest(HiSE,9,FromNw)) OctMove(r1,SE);
                else if (OctTest(HiSW,9,FromNe)) OctMove(r1,SW);
                
                else if (OctTest(HiNW,6,FromSe)) OctMove(r1,NW);
                else if (OctTest(HiNE,6,FromSw)) OctMove(r1,NE);
                else if (OctTest(HiSE,6,FromNw)) OctMove(r1,SE);
                else if (OctTest(HiSW,6,FromNe)) OctMove(r1,SW);
                
                else if (OctTest(HiNW,3,FromSe)) OctMove(r1,NW);
                else if (OctTest(HiNE,3,FromSw)) OctMove(r1,NE);
                else if (OctTest(HiSE,3,FromNw)) OctMove(r1,SE);
                else if (OctTest(HiSW,3,FromNe)) OctMove(r1,SW);
                
                else if (OctTest(HiNW,0,FromSe)) OctMove(r1,NW);
                else if (OctTest(HiNE,0,FromSw)) OctMove(r1,NE);
                else if (OctTest(SE,0,FromNw))   OctMove(r1,SE);
                else					         OctMove(r1,SW);
                
                *next = r1;
            }
            break;
            
        case 1:
            
#define Xnw XNW[HiNW & 0xf]
#define Xne XNE[HiNE & 0xf]
#define Xse XSE[HiSE & 0xf]
#define Xsw XSW[HiSW & 0xf]
            
            ForXY	{
                if	    (LoNW > LoSW)  { left  = LoNW;	leftX = Xnw;}
                else if (LoNW < LoSW)  { left  = LoSW;	leftX = Xsw;}
                else	   		       { left  = LoNW; leftX = MIN(Xnw,Xsw);}
                
                if (LoNE<LoSE){	right = LoNE; 	rightX= Xne;}
                if (LoNE>LoSE){	right = LoSE; 	rightX= Xse;}
                else		  {	right = LoNE;	rightX= MIN(Xse,Xne);}
                
                if	    (leftX < rightX)			r1 = left;	// shorter distance
                else if (leftX > rightX)			r1 = right;
                
                else if (LoNW==LoSW && LoNE!=LoSE)	r1 = right; // favor unique
                else if (LoNW!=LoSW && LoNE==LoSE)	r1 = left;
                
                else if (Xnw+Xsw < Xne+Xse)			r1 = left; // shorter combined distance
                else if (Xnw+Xsw > Xne+Xse)			r1 = right;
                
                else								r1 = LoC;
                
                r2  = ((r1==LoNW ? 8 : 0) +
                       (r1==LoNE ? 4 : 0) +
                       (r1==LoSE ? 2 : 0) +
                       (r1==LoSW ? 1 : 0));
                
                *next = r1 + (r2<<16);
            }
            break;
    }		
}
void inline CellRules::swap(Univ* univ, int xd, int yd) {
    
    int tem;
    xd+=univ->xs;	// to eliminate negative offsets
    yd+=univ->ys;
    
    for	 (y=0; y<univ->ys; y++, prev+=univ->bs2) {
        
        for (x=0; x<univ->xs; x++, prev++)
        {
            int xx = (x+xd)%univ->xs;
            int yy = (y+yd)%univ->ys;
            int &i = univ->uxyp(xx,yy);
            if (   ((C & 0x100) ==0)
                && ((i & 0x100) ==0)
                && ((i&0xff) > (C&0xff)))
            {
                tem = i;
                i=  C|0x100;
                C=tem|0x100;
            } 
        }
    }
}
bool inline CellRules::OctTest(int rule, int shift, FromCell from) {
    
#define Occupied 0x10000000
    int fromTest = (int)from;
    if (rule & Occupied) // already occupied
        return false;
    
    int scell = (rule>>shift) &7;
    if (scell == fromTest)// preference matches toCell
        return true;
    else	return false;
}
void inline CellRules::OctMove(int &r1, int &rule) {
    
    r1 = rule;
    rule |= Occupied;
}

#import "univ_und.h"  // relative rule location undefs


