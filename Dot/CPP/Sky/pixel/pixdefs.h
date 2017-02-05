#ifndef PixDefsH
#define PixDefsH

#define PIX_RGBA 1

#ifdef PIX_565
#define PIX_SIZE unsigned short
#define PIX_SET_RGBA(R,G,B,A) (((((R & 0x1F) << 6) | G & 0x3F) << 5 ) | B & 0x1F) 
#define PIX_DEPTH 2
#define PIX_TYPE "565L" 
#elif PIX_888 
#define PIX_SIZE unsigned int
#define PIX_SET_RGBA(R,G,B,A) (((((R & 0xFF) << 8) | G & 0xFF) << 8 ) | B & 0xFF) 
#define PIX_DEPTH 4
#define PIX_TYPE "888L" 
#elif PIX_RGBA
#define PIX_SIZE unsigned long
#define PIX_SET_RGB(R,G,B) (((((((R & 0xFF) << 8) | G & 0xFF) << 8 ) | B & 0xFF) << 0))
#define PIX_DEPTH 4
#define PIX_TYPE "RGBA" 
#define PIX_R(v) ((v & 0xFF0000) >> 16)
#define PIX_G(v) ((v & 0x00FF00) >> 8)
#define PIX_B(v) ((v & 0x0000FF) >> 0)

#endif
#endif //PixDefsH