module lint.LRegRead;
import lint.LExp, lint.LData;
import std.outbuffer;

class LRegRead : LExp {

    private LData _data;
    private ulong _begin, _size;

    this (LData reg) {
	this._data = reg;
	this._begin = 0;
	this._size = 0;
    }

    this (LData str, ulong begin, ulong size) {
	this._data = str;
	this._begin = begin;
	this._size = size;
    }
	  
}
