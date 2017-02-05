#import "Pal.h" 
#import "PalSet.h" 

Pal::Pal() {
	
    abstract= true;
}
Pal::Pal(bool abstract_) {
	
    abstract = abstract_;
}
Pal::Pal(Rgb i, Rgb j) {
    
	abstract = false;
	colors.init(i,j);				
}
Pal::Pal(Hsv i, Hsv j) {
	abstract=0;
	colors.init(i,j);
}
Pal::Pal(Rgb i, Rgb j, Rgb k) {
	
    abstract = false;
	colors.init(i,j);		
	colors.addRgb(k);
}
Pal::Pal(Hsv i, Hsv j, Hsv k) {
	
    abstract = false;
	colors.init(i,j);
	colors.addHsv(k);
}

void Pal::renderSubPal(int size,int firstSizeExpand) {
    
    float subIncrement = (float)size / (float)subPals.size();
    float subIndex = 0; 
    int index = 0;
    int oldIndex = 0; 
    int subSize = subIncrement;
    
    for (Pal* subPal : subPals) {
    
        if (subSize<1)
            break;
        subPal->renderColorRamp(subSize+firstSizeExpand);
        firstSizeExpand = 0;
        rgbs.addRgbs(subPal->rgbs);
        
        subIndex += subIncrement;
        oldIndex = index;
        index = (int)subIndex;
        subSize = MIN(subIncrement, index-oldIndex);        
    }    
}
void Pal::renderZenoPal(int size) {
    
    Rgbs rgbs2; // zeno palette divide by 2 recursive
    rgbs2.clear();

    int rampCount = subPals.size(); // for debug only
    int totalSize = 0;
    for (int size2 = size/2; size2>0; size2/=2) {
        
        int rampSize = size2/rampCount;
        if (rampSize <1) 
            break;
        totalSize += (rampSize*rampCount);
    }
    int remainder = size-totalSize;
    totalSize = 0;
    for (int size2 = size/2; size2>0; size2/=2) {

        int rampSize = size2/rampCount;
        if (rampSize <1) 
            break;
        totalSize += (rampSize*rampCount);
        rgbs.clear();
        // expand ramps of first set by remainder
        renderSubPal(size2+remainder,0); 
        remainder = 0;
        rgbs2.addRgbs(rgbs);
    }
    rgbs.setRgbs(rgbs2);
}
void Pal::renderPal(int size) {
    
    rgbs.clear();
    int rampCount = subPals.size();
    int remainder = size%rampCount;
    renderSubPal(size,remainder);
 }
void Pal::renderColorRamp(int size) {
    
    if (size < 1)
        return;
	rgbs.clear();
	colors.ramps(rgbs,size);
}
void Pal::setPal(Pal&q) {
    
    subPals.clear();
    subPals.push_back(&q);
}
bool Pal::copy(Pal&q) {

    abstract = q.abstract;
	rgbs.clear();
	rgbs.addRgbs(q.rgbs);
	colors	= q.colors;
    subPals = q.subPals;
	return true;
}
bool Pal::shift(Hsv&newHsv, bool insert) { // add a new main.pal ramp from right

	if (subPals.empty()) {
        
		Pal* temp = new Pal(palSet.Hsv_Black,newHsv);
		setPal(*temp);
		return true;
    }
	if ( &newHsv == &palSet.Hsv_Nil) { // remove arc from left
     
        //Debug(Pal*oldPal = subPals.front();)
        subPals.pop_front();
        // delete oldPal; //TODO: this could be either a static or dynamic pal
        
        if (subPals.empty()) {
            Pal* temp = new Pal(palSet.Hsv_Black,newHsv);
            setPal(*temp);
        }
 		return true;
    }

	if (insert) {
        
        Pal* newPal = new Pal(/*abstract*/false);
		newPal->colors._splice=NoSplice;
		newPal->colors.addHsv(subPals.back()->colors.last());
		newPal->colors.addHsv(newHsv);
		newPal->colors.addHsv(subPals.front()->colors.first());
        subPals.push_back(newPal);
    }
	else{
        Pal* newPal = new Pal(/*abstract*/false);
		newPal->colors._splice=NoSplice;
		newPal->colors.addHsv(subPals.back()->colors.last());
		newPal->colors.addHsv(newHsv);
        subPals.push_back(newPal);
        if (subPals.size()>1) {
            //Pal* oldPal = subPals.front();
            subPals.pop_front();
            //TODO: delete (oldPal)? 
        }
    }
	return true;
}

