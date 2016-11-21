module lint.LCast;
import lint.LExp;

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
    
}



