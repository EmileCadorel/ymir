module lint.LFromAddr;
import lint.LExp;


class LFromAddr : LExp {

    private LExp _exp;
    private long _size;

    this (LExp what, long size) {
	this._exp = what;
	this._size = size;
    }
    
}
