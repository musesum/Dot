#import "ColorRGBA.h"

void ColorRGBA::HueSatVal(Float32 hue, Float32 sat, Float32 val) {
    
	if(sat == 0.0) {
		red   = val;
		green = val;
		blue  = val;
		return;
	}
	
	float temp1, temp2, temp[3];
	int i;
	
	if(val < 0.5) 
        temp2 = val * (1.0 + sat);
	else          
        temp2 = val + sat - val * sat;
	
    temp1 = 2.0 * val - temp2;
	
	temp[0] = hue + 1.0 / 3.0;
	temp[1] = hue;
	temp[2] = hue - 1.0 / 3.0;
    
	for(i = 0; i < 3; ++i) 
    {
		if(temp[i] < 0.0)   temp[i] += 1.0;
		if(temp[i] > 1.0)   temp[i] -= 1.0;
		
		if      (temp[i] < 1.0/6.0) temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
		else if (temp[i] < 3.0/6.0) temp[i] = temp2;
        else if (temp[i] < 4.0/6.0) temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
        else                        temp[i] = temp1;
    }    
	red   = temp[0];
	green = temp[1];
	blue  = temp[2];
}

