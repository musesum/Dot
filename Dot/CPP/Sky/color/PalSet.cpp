#import "PalSet.h" 

Hsv PalSet::Hsv_Nil     = {  0,  0,  0};
Hsv PalSet::Hsv_Red		= {  0,100,100};
Hsv PalSet::Hsv_Orange	= { 30,100,100};
Hsv PalSet::Hsv_Yellow	= { 60,100,100};
Hsv PalSet::Hsv_Green	= {120,100,100};
Hsv PalSet::Hsv_Teal    = {180,100,100};
Hsv PalSet::Hsv_Blue    = {240,100,100};
Hsv PalSet::Hsv_Indigo	= {270,100,100};
Hsv PalSet::Hsv_Purple	= {285,100,100};
Hsv PalSet::Hsv_Violet	= {300,100,100};
Hsv PalSet::Hsv_Magenta	= {300,100,100};
Hsv PalSet::Hsv_White	= {  0,  0,100};
Hsv PalSet::Hsv_Gray    = {  0,  0, 50};
Hsv PalSet::Hsv_Black	= {  0,  0,  0};

Hsv PalSet::Hsv_r		= {  0,100,100};
Hsv PalSet::Hsv_rrrrro	= {  5,100,100};
Hsv PalSet::Hsv_rrrro	= { 10,100,100};
Hsv PalSet::Hsv_rrro    = { 15,100,100};
Hsv PalSet::Hsv_rro		= { 20,100,100};
Hsv PalSet::Hsv_ro		= { 25,100,100};
Hsv PalSet::Hsv_o		= { 30,100,100};
Hsv PalSet::Hsv_oooooy	= { 35,100,100};
Hsv PalSet::Hsv_ooooy	= { 40,100,100};
Hsv PalSet::Hsv_oooy    = { 45,100,100};
Hsv PalSet::Hsv_ooy		= { 50,100,100};
Hsv PalSet::Hsv_oy		= { 55,100,100};
Hsv PalSet::Hsv_y		= { 60,100,100};
Hsv PalSet::Hsv_yyyyyg	= { 70,100,100};
Hsv PalSet::Hsv_yyyyg	= { 80,100,100};
Hsv PalSet::Hsv_yyyg    = { 90,100,100};
Hsv PalSet::Hsv_yyg		= {100,100,100};
Hsv PalSet::Hsv_yg		= {110,100,100};
Hsv PalSet::Hsv_g		= {120,100,100};
Hsv PalSet::Hsv_gggggb	= {130,100,100};
Hsv PalSet::Hsv_ggggb	= {150,100,100};
Hsv PalSet::Hsv_gggb    = {170,100,100};
Hsv PalSet::Hsv_ggb		= {190,100,100};
Hsv PalSet::Hsv_gb		= {210,100,100};
Hsv PalSet::Hsv_b		= {240,100,100};
Hsv PalSet::Hsv_bbbbbi	= {245,100,100};
Hsv PalSet::Hsv_bbbbi	= {250,100,100};
Hsv PalSet::Hsv_bbbi    = {255,100,100};
Hsv PalSet::Hsv_bbi		= {260,100,100};
Hsv PalSet::Hsv_bi		= {265,100,100};
Hsv PalSet::Hsv_i		= {270,100,100};
Hsv PalSet::Hsv_iiiiiv	= {275,100,100};
Hsv PalSet::Hsv_iiiiv	= {280,100,100};
Hsv PalSet::Hsv_iiiv    = {285,100,100};
Hsv PalSet::Hsv_iiv		= {290,100,100};
Hsv PalSet::Hsv_iv		= {295,100,100};
Hsv PalSet::Hsv_v		= {300,100,100};
Hsv PalSet::Hsv_vvvvvr	= {310,100,100};
Hsv PalSet::Hsv_vvvvr	= {320,100,100};
Hsv PalSet::Hsv_vvvr    = {330,100,100};
Hsv PalSet::Hsv_vvr		= {340,100,100};
Hsv PalSet::Hsv_vr		= {350,100,100};

Pal PalSet::Pal_BlackBlack   (Hsv_Black  ,Hsv_Black  );
Pal PalSet::Pal_BlackWhite   (Hsv_Black  ,Hsv_White  );
Pal PalSet::Pal_WhiteBlack   (Hsv_White  ,Hsv_Black  );
Pal PalSet::Pal_WhiteWhite   (Hsv_White  ,Hsv_White  );

Pal PalSet::Pal_BlackRed     (Hsv_Black  ,Hsv_Red    );
Pal PalSet::Pal_RedBlack     (Hsv_Red    ,Hsv_Black  );
Pal PalSet::Pal_RedWhite     (Hsv_Red    ,Hsv_White  );
Pal PalSet::Pal_WhiteRed     (Hsv_White  ,Hsv_Red    );
Pal PalSet::Pal_BlackOrange  (Hsv_Black  ,Hsv_Orange );
Pal PalSet::Pal_OrangeBlack  (Hsv_Orange ,Hsv_Black  );
Pal PalSet::Pal_BlackYellow  (Hsv_Black  ,Hsv_Yellow );
Pal PalSet::Pal_YellowBlack  (Hsv_Yellow ,Hsv_Black  );
Pal PalSet::Pal_BlackGreen   (Hsv_Black  ,Hsv_Green  );
Pal PalSet::Pal_GreenBlack   (Hsv_Green  ,Hsv_Black  );
Pal PalSet::Pal_BlueBlack    (Hsv_Blue   ,Hsv_Black  );
Pal PalSet::Pal_BlackBlue    (Hsv_Black  ,Hsv_Blue   );
Pal PalSet::Pal_BlueWhite    (Hsv_Blue   ,Hsv_White  );
Pal PalSet::Pal_WhiteBlue    (Hsv_White  ,Hsv_Blue   );
Pal PalSet::Pal_BlueRed      (Hsv_Blue   ,Hsv_Red    );
Pal PalSet::Pal_RedBlue      (Hsv_Red    ,Hsv_Blue   );
Pal PalSet::Pal_BlackIndigo  (Hsv_Black  ,Hsv_Indigo );
Pal PalSet::Pal_IndigoBlack  (Hsv_Indigo ,Hsv_Black  );
Pal PalSet::Pal_BlackViolet  (Hsv_Black  ,Hsv_Violet );
Pal PalSet::Pal_VioletBlack  (Hsv_Violet ,Hsv_Black  );
Pal PalSet::Pal_YellowIndigo (Hsv_Yellow ,Hsv_Indigo );
Pal PalSet::Pal_RedYellow    (Hsv_Red    ,Hsv_Yellow );  
Pal PalSet::Pal_YellowWhite  (Hsv_Yellow ,Hsv_White  );
Pal PalSet::Pal_GreenBlue    (Hsv_Green  ,Hsv_Blue   );
Pal PalSet::Pal_BlueMagenta  (Hsv_Blue   ,Hsv_Magenta);
Pal PalSet::Pal_MagentaWhite (Hsv_Magenta,Hsv_White  );
Pal PalSet::Pal_WhiteGreen   (Hsv_White  ,Hsv_Green  );
Pal PalSet::Pal_MagentaGreen (Hsv_Magenta,Hsv_Green  );
Pal PalSet::Pal_OrangeGreen  (Hsv_Orange ,Hsv_Green  );
Pal PalSet::Pal_GreenTeal    (Hsv_Green  ,Hsv_Teal   );
Pal PalSet::Pal_TealViolet   (Hsv_Teal   ,Hsv_Violet );

Pal PalSet::Pal_kw;	
Pal PalSet::Pal_kwk;	
Pal PalSet::Pal_wkw;	
Pal PalSet::Pal_kwz;
Pal PalSet::Pal_wkz;

Pal PalSet::Pal_krgbk;
Pal PalSet::Pal_krygbk;
Pal PalSet::Pal_kroygbpk;
Pal PalSet::Pal_kroygbivk;
Pal PalSet::Pal_kroygbivz;
Pal PalSet::Pal_wroygbpw;

#undef Pal5    
#define Pal5(a) \
Pal PalSet::Pal_k##a##w;\
Pal PalSet::Pal_k##a##k;\
Pal PalSet::Pal_w##a##w;\
Pal PalSet::Pal_k##a##z;\
Pal PalSet::Pal_w##a##z;

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

PalSet palSet;

PalSet::PalSet() {// initalize the default palettes

#undef Pal5    
#define Pal5(a) \
Pal_k##a##w.setPal(Pal_WhiteBlack); Pal_k##a##w.shift(Hsv_##a); Pal_k##a##w.shift(Hsv_Nil); Pal_k##a##w.renderPal(256);\
Pal_k##a##k.setPal(Pal_BlackBlack); Pal_k##a##k.shift(Hsv_##a); Pal_k##a##k.shift(Hsv_Nil); Pal_k##a##k.renderPal(256);\
Pal_w##a##w.setPal(Pal_WhiteWhite); Pal_w##a##w.shift(Hsv_##a); Pal_w##a##w.shift(Hsv_Nil); Pal_w##a##w.renderPal(256);\
Pal_k##a##z.setPal(Pal_BlackBlack); Pal_k##a##z.shift(Hsv_##a); Pal_k##a##z.shift(Hsv_Nil); Pal_k##a##z.renderZenoPal(256);\
Pal_w##a##z.setPal(Pal_WhiteWhite); Pal_w##a##z.shift(Hsv_##a); Pal_w##a##z.shift(Hsv_Nil); Pal_w##a##z.renderZenoPal(256);

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
    
    Pal_kw.setPal(Pal_BlackWhite); 
    Pal_kw.renderPal(256); 
    
    Pal_kwk.setPal(Pal_BlackBlack); 
	Pal_kwk.shift(Hsv_White,true);
	Pal_kwk.shift(Hsv_Nil,true);
    Pal_kwk.renderPal(256); 
    
    Pal_wkw.setPal(Pal_WhiteWhite); 
	Pal_wkw.shift(Hsv_Black,true);
    Pal_wkw.shift(Hsv_Nil,true);
    Pal_wkw.renderPal(256); 
    
    Pal_kwz.copy(Pal_kwk);
    Pal_kwz.renderZenoPal(256);
    
    Pal_wkz.copy(Pal_wkw);
    Pal_wkz.renderZenoPal(256);
    
    Pal_krgbk.setPal(Pal_BlackBlack);
    Pal_krgbk.shift(Hsv_Red   ,true);
    Pal_krgbk.shift(Hsv_Green ,true);
    Pal_krgbk.shift(Hsv_Blue  ,true);
    Pal_krgbk.shift(Hsv_Nil   ,true);
    Pal_krgbk.renderPal(256); 
    
    Pal_krygbk.setPal(Pal_BlackBlack);
    Pal_krygbk.shift(Hsv_Red   ,true);
    Pal_krygbk.shift(Hsv_Yellow,true);
    Pal_krygbk.shift(Hsv_Green ,true);
    Pal_krygbk.shift(Hsv_Blue  ,true);
    Pal_krygbk.shift(Hsv_Nil   ,true);
    Pal_krygbk.renderPal(256); 
    
    Pal_kroygbivk.setPal(Pal_BlackBlack);
    Pal_kroygbivk.shift(Hsv_Red	  ,true);
    Pal_kroygbivk.shift(Hsv_Orange,true);
    Pal_kroygbivk.shift(Hsv_Yellow,true);
    Pal_kroygbivk.shift(Hsv_Green ,true);
    Pal_kroygbivk.shift(Hsv_Blue  ,true);
    Pal_kroygbivk.shift(Hsv_Indigo,true);
    Pal_kroygbivk.shift(Hsv_Violet,true);
    Pal_kroygbivk.shift(Hsv_Nil   ,true);
    Pal_kroygbivk.renderPal(256); 
    
    Pal_kroygbpk.setPal(Pal_BlackBlack);
    Pal_kroygbpk.shift(Hsv_Red   ,true);
    Pal_kroygbpk.shift(Hsv_Orange,true);
    Pal_kroygbpk.shift(Hsv_Yellow,true);
    Pal_kroygbpk.shift(Hsv_Green ,true);
    Pal_kroygbpk.shift(Hsv_Blue  ,true);
    Pal_kroygbpk.shift(Hsv_Purple,true);
    Pal_kroygbpk.shift(Hsv_Nil   ,true);
    Pal_kroygbpk.renderPal(256); 
    
    Pal_wroygbpw.setPal(Pal_WhiteWhite);
    Pal_wroygbpw.shift(Hsv_Red	 ,true);
    Pal_wroygbpw.shift(Hsv_Orange,true);
    Pal_wroygbpw.shift(Hsv_Yellow,true);
    Pal_wroygbpw.shift(Hsv_Green ,true);
    Pal_wroygbpw.shift(Hsv_Blue  ,true);
    Pal_wroygbpw.shift(Hsv_Purple,true);
    Pal_wroygbpw.shift(Hsv_Nil,true);
    Pal_wroygbpw.renderPal(256); 

    
	}

































































































