precision mediump float;
varying highp vec2 vTexCoord;

uniform mediump sampler2D drawBuf; // 2D texture
uniform mediump sampler2D drawPal; // 256x1 color palette for texture

uniform float fade; // fade key slider value
uniform vec2 repeat;
uniform vec2 mirror;
uniform vec2 shift;

void main () {
    vec2 m;
    
    if (mirror.x < 0.5) {
        m.x = mod(vTexCoord.x /* + s.x*repeat.x*/, repeat.x);
    }
    else {
        m.x = mod(vTexCoord.x /* + s.x*repeat.x*/, repeat.x*2.);
        if (m.x > repeat.x) {
            m.x = repeat.x * 2.0 - m.x;
        }
    }
    if (mirror.y <.5) {
        m.y = mod(vTexCoord.y /* + s.y*repeat.y*/, repeat.y);
    }
    else {
        m.y = mod(vTexCoord.y /* + s.y*repeat.y*/, repeat.y*2.);
        if (m.y > repeat.y) {
            m.y = repeat.y * 2.0 - m.y;
        }
    }
    vec4 realColor = texture2D(drawBuf, vec2(m.x/repeat.x,
                                             m.y/repeat.y));
    
    vec4 falseColorB = texture2D(drawPal, vec2(realColor.b,0.));
    vec4 falseColorR = texture2D(drawPal, vec2(realColor.r,0.));
    
    float fadeInverse = 1.0 - fade;
    gl_FragColor = vec4(falseColorR.r * fadeInverse + falseColorB.r * fade,
                        falseColorR.g * fadeInverse + falseColorB.g * fade,
                        falseColorR.b * fadeInverse + falseColorB.b * fade,
                        1.0);
}
