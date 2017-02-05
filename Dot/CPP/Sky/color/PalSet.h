
#import "Pal.h"
#import "Colors.h"

struct PalSet {

		PalSet();
    
    static Hsv Hsv_Nil;
    static Hsv Hsv_Red;
    static Hsv Hsv_Orange;
    static Hsv Hsv_Yellow;
    static Hsv Hsv_Green;
    static Hsv Hsv_Teal;
    static Hsv Hsv_Blue;
    static Hsv Hsv_Indigo;
    static Hsv Hsv_Purple;
    static Hsv Hsv_Violet;
    static Hsv Hsv_Magenta;
    static Hsv Hsv_White;
    static Hsv Hsv_Gray;
    static Hsv Hsv_Black;
    
    static Hsv Hsv_r;
    static Hsv Hsv_rrrrro;
    static Hsv Hsv_rrrro;
    static Hsv Hsv_rrro;
    static Hsv Hsv_rro;
    static Hsv Hsv_ro;
    static Hsv Hsv_o;
    static Hsv Hsv_oooooy;
    static Hsv Hsv_ooooy;
    static Hsv Hsv_oooy;
    static Hsv Hsv_ooy;
    static Hsv Hsv_oy;
    static Hsv Hsv_y;
    static Hsv Hsv_yyyyyg;
    static Hsv Hsv_yyyyg;
    static Hsv Hsv_yyyg;
    static Hsv Hsv_yyg;
    static Hsv Hsv_yg;
    static Hsv Hsv_g;
    static Hsv Hsv_gggggb;
    static Hsv Hsv_ggggb;
    static Hsv Hsv_gggb;
    static Hsv Hsv_ggb;
    static Hsv Hsv_gb;
    static Hsv Hsv_b;
    static Hsv Hsv_bbbbbi;
    static Hsv Hsv_bbbbi;
    static Hsv Hsv_bbbi;
    static Hsv Hsv_bbi;
    static Hsv Hsv_bi;
    static Hsv Hsv_i;
    static Hsv Hsv_iiiiiv;
    static Hsv Hsv_iiiiv;
    static Hsv Hsv_iiiv;
    static Hsv Hsv_iiv;
    static Hsv Hsv_iv;
    static Hsv Hsv_v;
    static Hsv Hsv_vvvvvr;
    static Hsv Hsv_vvvvr;
    static Hsv Hsv_vvvr;
    static Hsv Hsv_vvr;
    static Hsv Hsv_vr;
    
    static Pal Pal_BlackBlack;
    static Pal Pal_BlackWhite;
    static Pal Pal_WhiteBlack;
    static Pal Pal_WhiteWhite;
    
    static Pal Pal_BlackRed;
    static Pal Pal_RedBlack;
    static Pal Pal_RedWhite;
    static Pal Pal_WhiteRed;
    static Pal Pal_BlackOrange;
    static Pal Pal_OrangeBlack;
    static Pal Pal_BlackYellow;
    static Pal Pal_YellowBlack;
    static Pal Pal_BlackGreen;
    static Pal Pal_GreenBlack;
    static Pal Pal_BlueBlack;
    static Pal Pal_BlackBlue;
    static Pal Pal_BlueWhite;
    static Pal Pal_WhiteBlue;
    static Pal Pal_BlueRed;
    static Pal Pal_RedBlue;
    static Pal Pal_BlackIndigo;
    static Pal Pal_IndigoBlack;
    static Pal Pal_BlackViolet;
    static Pal Pal_VioletBlack;
    static Pal Pal_YellowIndigo;
    static Pal Pal_RedYellow;  
    static Pal Pal_YellowWhite;
    static Pal Pal_GreenBlue;
    static Pal Pal_BlueMagenta;
    static Pal Pal_MagentaWhite;
    static Pal Pal_WhiteGreen;
    static Pal Pal_MagentaGreen;
    static Pal Pal_OrangeGreen;
    static Pal Pal_GreenTeal;
    static Pal Pal_TealViolet;
    
    static Pal Pal_kw;
    static Pal Pal_kwk; 
    static Pal Pal_wkw; 
    static Pal Pal_kwz; 
    static Pal Pal_wkz; 
    
    static Pal Pal_krgbk; 
    static Pal Pal_krygbk; 
    static Pal Pal_kroygbpk;
    static Pal Pal_kroygbivk;
    static Pal Pal_kroygbivz;
    static Pal Pal_wroygbpw;
    
#define Pal5(a)\
static  Pal Pal_k##a##w;\
static  Pal Pal_k##a##k;\
static  Pal Pal_w##a##w;\
static  Pal Pal_k##a##z;\
static  Pal Pal_w##a##z;
    
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
};

extern PalSet palSet;




