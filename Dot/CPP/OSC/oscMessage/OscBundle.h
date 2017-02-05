/*
 OscMessage -- Open Sound Control message wrapper for oscpack
 http://www.muse.com/tr3
 
 Copyright (c) 2010 Warren Stringer <warren@muse.com>
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files
 (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software,
 and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 Any person wishing to distribute modifications to the Software is
 requested to send the modifications to the original developer so that
 they can be incorporated into the canonical version.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef OscBundle_H
#define OscBundle_H

#include <vector>
#include "OscMessage.h"

struct OscBundle {
    
	OscBundle();
	OscBundle( const OscBundle& other ) { copy ( other ); }
	OscBundle& operator= ( const OscBundle& other ) { return copy( other ); }
	OscBundle& copy( const OscBundle& other);
    
		~OscBundle();
    
	void clear() { _messages.clear(); _bundles.clear(); }
 
	std::vector<OscMessage> _messages;
	std::vector<OscBundle> _bundles;
};


#endif
