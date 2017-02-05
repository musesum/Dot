#import "Pic.h"
#import "../main/CellMain.h" 

void Pic::init(Tr3*root, void*src, int xs_, int ys_, int zs_) {
    
    xs = xs_;
    ys = ys_;
    zs = zs_;
    
    buf32.init(xs,ys,zs); // real color buffer

    rules = new CellRules();
    rules->init(root,this);
    
    univ.init(root,xs,ys);
    univ.buf[univ.inext].copy((byte*)src,xs,ys,zs); // initialize with placemark 
    
    facemap.init(root);
    facemap.set(FacePlane);
    univ.setBorder(facemap);
    mix.initMix(root,xs,ys,1,1);
    pix.init(root,zs);
    
    shift[kVisualsFake].bindTr3(root,"fake");
}
void Pic::copyDataToUniv(void*src) {

    //UNTESTED and unused
    univ.buf[univ.inext].copy((byte*)src,xs,ys,zs);    
    univ.setBorder(facemap);
}
void Pic::copyRgbaToMonoUniv(void*src,int sourceXs, int sourceYs, bool fromZero, FlipType flipType) {
    
    Buf mono; mono.init(xs,ys,4);
    mono.copyRgbaToMono((byte*)src,sourceXs,sourceYs,fromZero, flipType);
    univ.buf[univ.inext].copy(mono.buf,xs,ys,zs);
    univ.setBorder(facemap);
}
void Pic::copyRgbaToMonoUniv(void*src,bool fromZero) {
    
    Buf mono; mono.init(xs,ys,4);
    mono.copyRgbaToMono((byte*)src,xs,ys,fromZero, kFlipNone);
    univ.buf[univ.inext].copy(mono.buf,xs,ys,zs);
    univ.setBorder(facemap);
}
void Pic::copyByteToMonoUniv(void*src,int offset) {
    
    Buf mono; mono.init(xs,ys,4);
    mono.copyByteToMono((byte*)src,xs,ys,offset);
    univ.buf[univ.inext].copy(mono.buf,xs,ys,zs);
    univ.setBorder(facemap);
}
void* Pic::getWin() {
    
    return (void*)(pix.buf[0]);
}
void Pic::goRule() {
    
    if (*rules->cellGo) {

        shift[kVisualsFake].go();
        int x = shift[kVisualsFake].deltaX;
        int y = shift[kVisualsFake].deltaY;
        univ.setShift(facemap,x,y); 
        univ.go(facemap);
        rules->go();	// apply rules to univ,mix,facemap
    }
    else {
        //univ.setShift(facemap,0,0); //TODO: is this needed?
        univ.go(facemap);	
    }
}
void Pic::go8() {
    
    facemap.go();
    
    if (*pix.realfake) {
        
        goRule();
        mix.goMix(univ);				// mix next universe with viewing space
    }
    pix.pals.goPal();
}

void Pic::goPic() {
    
    go8();
    pix.rePlane(facemap,mix.buf[0],buf32); 
}

void Pic::goPixelBuffer(void*pixelBuffer) {
 
    facemap.go();
    
    if (*pix.realfake) {
        
        goRule();
        mix.goMix(univ);
    }
    pix.pals.goPal();
    univ.copyFromMix((int*)pixelBuffer, mix);
}
