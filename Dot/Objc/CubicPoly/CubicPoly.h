#include <iostream>
#include <cmath>

struct Vec2D {
    Vec2D() : x(0), y(0) {}
    Vec2D(float _x, float _y) : x(_x), y(_y) {}
    float x, y;
};


struct CubicPoly {
    
    float c0, c1, c2, c3;
    
    float eval(float t) {
        
        float t2 = t*t;
        float t3 = t2 * t;
        return c0 + c1*t + c2*t2 + c3*t3;
    }
    
    static Vec2D eval(float t,CubicPoly px, CubicPoly py) {
        
        Vec2D r(px.eval(t), py.eval(t));
        return r;
    }
    static float VecDistSquared(const Vec2D& p, const Vec2D& q);
    static void InitCubicPoly(float x0, float x1, float t0, float t1, CubicPoly &p);
    static void InitCatmullRom(float x0, float x1, float x2, float x3, CubicPoly &p);
    static void InitNonuniformCatmullRom(float x0, float x1, float x2, float x3, float dt0, float dt1, float dt2, CubicPoly &p);
    static void InitCentripetalCR(const Vec2D& p0, const Vec2D& p1, const Vec2D& p2, const Vec2D& p3, CubicPoly &px, CubicPoly &py);

};

