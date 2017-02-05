#import <stdlib.h>

#import "Mix.h"
#import "../pixel/Univ.h"
#import <stdio.h>

Mix::Mix() {
    
	pixCount = 1;
    mx=0; //&mixSet;
}

void Mix::bindTr3(Tr3*root) {
    
    Tr3*mix   = root->bind("cell.mix");
    Tr3*edit  = mix->bind("edit");  
    Tr3*op    = mix->bind("op");  
    
    editPlane = edit->bind("plane");
    editPage  = edit->bind("page");
    editBits  = edit->bind("bits");
    
    edit->bind("plane" , (Tr3CallTo)(&Mix::call_mixPlane), (void*)this, (void*) 0);
    edit->bind("bits"  , (Tr3CallTo)(&Mix::call_mixBits),  (void*)this, (void*) 0);
    op->bind(  "zero"  , (Tr3CallTo)(&Mix::call_mixZero),  (void*)this, (void*) 0);
    op->bind(  "equals", (Tr3CallTo)(&Mix::call_mixPlus),  (void*)this, (void*) 0);
    op->bind(  "plus"  , (Tr3CallTo)(&Mix::call_mixEquals),(void*)this, (void*) 0);
}

void Mix::initMix(Tr3*root, int xs, int ys, int zs, int univSurfs) {
    
    bindTr3(root);
    pixCount = univSurfs;
    int i=0;
    for (; i<pixCount; i++)
    buf[i].init(xs,ys,zs);
    
    for (;i<FaceMax; i++)
    buf[i].clear();
}

#pragma mark - callbacks

void Mix::mixZero(Tr3*from,void*vp) {
    
	mx->zero = true;
}
void Mix::mixPlane(Tr3*from,void*vp) {
    if (mx && mx->plane) {
        mx->plane->sneak((int)*editPlane); //ooo
    }
}
void Mix::mixBits(Tr3*from,void*vp) {
    
	mx->bits->setNow((float)*editBits);
}
void Mix::mixPlus(Tr3*from,void*vp) {
    
	if (mx)
		mx->op->setNow(MixAdd);
}
void Mix::mixEquals(Tr3*from,void*vp) {
    
	if (mx)
		mx->op->setNow(MixMov);
}

#pragma mark - go

#define ForXYP \
for	(y=0; y<ys; y++, next+=univ.bs2) \
for (x=0; x<xs; x++, b++, next++)	

byte Mix::edge(Univ&univ, int i) {
    
    int w,x,y;
	int plane = *(mx->plane);
    int unflash = *(mx->unflash);
	 
    int values[256];
    int count=0;
    for (w=0; w<256; w++)
        values[w]=0;
    
    byte*b = buf[i].buf;
    int xs = buf[i].xs; // assumes that all of buf are the same size
    int ys = buf[i].ys; // assumes that all of buf are the same size
    
    int* next, *prev;
    univ.getU(i,next,prev);
    
    ForXYP {
        byte v = (*next)>>plane;
        values[v]++;
        count++;
    }
    /*
    //top row
    y = 0; 
    for (x=0; x<xs; x++) {
        
        byte v = (*univ.pxy(0,x,y)>>plane);
        values[v]++;
        count++;
    }
    //bottom row
    y = xs-1; 
    for (x=0; x<xs; x++) {
        
        byte v = (*univ.pxy(0,x,y)>>plane);
        values[v]++;
        count++;
    }
    // left column
    x=0;    
    for (y=0; y<ys; y++) {
        
        byte v = (*univ.pxy(0,x,y)>>plane);
        values[v]++;
        count++;
    }    
    // right column
    x=xs-1;    
    for (y=0; y<ys; y++) {
        
        byte v = (*univ.pxy(0,x,y)>>plane);
        values[v]++;
        count++;
    }
    */
    count /= (unflash+1); // set count threshold to remove value
    
    for (w=0; w<256;w++) 
        if (values[w]>count)
            break;
    if (w<256) 
        return (byte)w;
    else 
        return 0;
}

void Mix::goMix(Univ&univ) {
    
	int x,y;
    int plane   = (mx && mx->plane  ) ? *(mx->plane)    : 127;
    int bits    = (mx && mx->bits   ) ? *(mx->bits)     : 8;
    int unflash = (mx && mx->unflash) ?(int) *(mx->unflash)  : 0;
    
	MixOp op  = (MixOp) (int)*(mx->op);
    
	for (int i=0; i<pixCount; i++) {
        
        byte*b = buf[i].buf;
		int xs = buf[i].xs; // assumes that all of buf are the same size
		int ys = buf[i].ys; // assumes that all of buf are the same size
        
		int* next, *prev;
		univ.getU(i,next,prev);
        
		if (mx->zero) {
			mx->zero = false;
			op = MixZero;
        }
        byte remove=0;
        if (unflash>0) remove = edge(univ,i);
        if (remove>0) {
            
            switch (op) {
                    
				default:
 				case MixZero:	ForXYP* b = (byte)0;                 break;
				case MixMov:	ForXYP {
                    (*b) =((*next)>>plane); 
                    if ((byte)(*b)==remove) 
                        (*b)=0;
                } break;
				case MixAdd:	ForXYP {(*b) += ((*next)>>plane); if ((*b)==remove) (*b)=0;} break;
				case MixSub:	ForXYP {(*b)  = ((*next)>>plane); if ((*b)==remove) (*b)=0;} break;
                case MixAnd:	ForXYP {(*b)  = ((*b)>>1)+((*next)>>plane);}    break;
				case MixOr:		ForXYP {(*b) |= ((*next)>>plane); if ((*b)==remove) (*b)=0;} break;
                case MixXor:	ForXYP {(*b) ^= ((*next)>>plane); if ((*b)==remove) (*b)=0;} break;
            }
        }
                
		else if ((plane==0 && bits==8) || bits==0) {
            
			switch (op) {
                    
				default:
				case MixZero:	ForXYP {*b = (byte)0;                  }    break;
				case MixMov:	ForXYP {*b = (byte)              *next;}	break;
				case MixAdd:	ForXYP {*b = ((byte)*b   )+(byte)*next;}	break;
				case MixSub:	ForXYP {*b = ((byte)*b   )-(byte)*next;}	break;
				case MixAnd:	ForXYP {*b = ((byte)*b>>1)+(byte)*next;}	break;
				case MixOr:		ForXYP {*b = ((byte)*b   )|(byte)*next;}	break;
				case MixXor:	ForXYP {*b = ((byte)*b   )^(byte)*next;}	break;
            }
        }
		else if (bits == 8) {
            
			switch (op) {
                    
				default:
 				case MixZero:	ForXYP {(*b) =(( 0)>>plane);}                 break;
				case MixMov:	ForXYP {(*b) =((*next)>>plane);}              break;
				case MixAdd:	ForXYP {(*b)+=((*next)>>plane);}              break;
				case MixSub:	ForXYP {(*b) =((*next)>>plane);}              break;
				case MixAnd:	ForXYP {(*b) =((*b)>>1)+((*next)>>plane);}    break;
				case MixOr:		ForXYP {(*b)|=((*next)>>plane);}              break;
                case MixXor:	ForXYP {(*b)^=((*next)>>plane);}              break;
            }
        }
        else {
            int mask = (1<<bits)-1;
            
			switch (op) {
                    
				default:
 				case MixZero:	ForXYP {(*b) =(( 0)>>plane)&mask;}                break;
				case MixMov:	ForXYP {(*b) =((*next)>>plane)&mask;}             break;
				case MixAdd:	ForXYP {(*b)+=((*next)>>plane)&mask;}             break;
				case MixSub:	ForXYP {(*b) =((*next)>>plane)&mask;}             break;
				case MixAnd:	ForXYP {(*b) =((*b)>>1)+((*next)>>plane)&mask;}   break;
				case MixOr:		ForXYP {(*b)|=((*next)>>plane)&mask;}             break;
                case MixXor:	ForXYP {(*b)^=((*next)>>plane)&mask;}             break;;
            }
            
        }
    }
}

