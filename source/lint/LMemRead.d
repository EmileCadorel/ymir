module lint.LMemRead;
import lint.LExp;
import std.outbuffer;

class LMemRead : LExp {
    private LExp _where;
    private long _size;

    this (LExp where, long size) {
	this._where = where;
	this._size = size;
    }
    
}
