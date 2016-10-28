module lint.LUnref;
import lint.LExp;
import std.conv;

class LUnref : LExp {

    private LExp _exp;
    private LExp _padd = null;
    private long _size;

    this (LExp what, long size) {
	this._exp = what;
	this._size = size;
    }

    this (LExp what, LExp padd, long size) {
	this._exp = what;
	this._padd = padd;
	this._size = size;
    }
        
}
