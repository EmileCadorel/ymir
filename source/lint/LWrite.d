module lint.LWrite;
import lint.LInst, lint.LExp;
import std.outbuffer, std.conv, std.stdio;

class LWrite : LInst {
    private LExp _left;
    private LExp _right;
    private long _size;

    this (LExp left, LExp right, long size) {
	this._left = left;
	this._right = right;
	this._size = size;
    }    
}

  
