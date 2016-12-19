module lint.LCast;
import lint.LExp;
import std.conv, lint.LSize;

class LCast : LExp {
    
    private LExp _what;
    private LSize _size;
    
    this (LExp what, LSize size) {
	this._what = what;
	this._size = size;
    }

    LExp what () {
	return this._what;
    }

    override LSize size () {
	return this._size;
    }
    
    override bool isInst () {
	return false;
    }

    override string toString () {
	return "$(" ~ this._what.toString ~ " :->" ~ to!string (this._size) ~ ")";
    }    
}



