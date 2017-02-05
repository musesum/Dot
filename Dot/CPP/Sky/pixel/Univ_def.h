#define xOfs 1			    /* change to sizeof(int) for explicit pointer arithmatic */
#define yOfs univ->xsb 	/* change to  (xsb*xOfs) for explicit pointer arithmatic */

#define  C 	(*(prev))
#define  N 	(*(prev-yOfs))
#define  S  (*(prev+yOfs))
#define  E 	(*(prev+xOfs))
#define  W 	(*(prev-xOfs))
#define NE  (*(prev-yOfs+xOfs))
#define NW  (*(prev-yOfs-xOfs))
#define SE  (*(prev+yOfs+xOfs))
#define SW  (*(prev+yOfs-xOfs))

#define LiC  (C &0xffff)
#define LiN  (N &0xffff)
#define LiS  (S &0xffff)
#define LiE  (E &0xffff)
#define LiW  (W &0xffff)
#define LiNE (NE&0xffff)
#define LiNW (NW&0xffff)
#define LiSE (SE&0xffff)
#define LiSW (SW&0xffff)

#define LoC  (C &0xff)
#define LoN  (N &0xff)
#define LoS  (S &0xff)
#define LoE  (E &0xff)
#define LoW  (W &0xff)
#define LoNE (NE&0xff)
#define LoNW (NW&0xff)
#define LoSE (SE&0xff)
#define LoSW (SW&0xff)

#define HiC  (C>>16)
#define HiN  (N>>16)
#define HiS  (S>>16)
#define HiE  (E>>16)
#define HiW  (W>>16)
#define HiNE (NE>>16)
#define HiNW (NW>>16)
#define HiSE (SE>>16)
#define HiSW (SW>>16)


