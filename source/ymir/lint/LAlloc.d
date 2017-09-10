module ymir.lint.LAlloc;
import ymir.lint._;
import std.outbuffer;

class LAlloc : LExp {
    private LExp _how;

    this (LExp how) {
	this._how = how;
    }
    
}
