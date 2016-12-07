module lint.LCast;
import lint.LExp;
import std.conv;

class LCast : LExp {
    
    private LExp _what;
    private int _size;
    
    this (LExp what, int size) {
	this._what = what;
	this._size = size;
    }

    LExp what () {
	return this._what;
    }

    override int size () {
	return this._size;
    }
    
    override bool isInst () {
	return false;
    }

    override string toString () {
	return "$(" ~ this._what.toString ~ " :->" ~ to!string (this._size) ~ ")";
    }    
}



