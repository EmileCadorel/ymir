module lint.LAlloc;
import lint.LExp;
import std.outbuffer;

class LAlloc : LExp {
    private LExp _how;

    this (LExp how) {
	this._how = how;
    }
    
}
