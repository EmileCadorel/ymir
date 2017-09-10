module ymir.lint.LFromAddr;
import ymir.lint._;


class LFromAddr : LExp {

    private LExp _exp;
    private long _size;

    this (LExp what, long size) {
	this._exp = what;
	this._size = size;
    }
    
}
