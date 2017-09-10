module ymir.lint.LReserve;
import ymir.lint._;

import std.conv;

class LReserve : LExp {

    private LExp _size;
    private LReg _reg;
    private LSize _innerSize;
    
    this (LExp size) {
	this._reg = new LReg (LSize.LONG);
	this._size = size;
    }

    LReg id () {
	return this._reg;
    }

    LExp length () {
	return this._size;
    }
    
    override LSize size () {
	return LSize.LONG;
    }    
    
    override bool isInst () {
	return true;
    }	
    
    override string toString () {
	import std.format;
	return format ("RESERVE %s:%s", this._reg.to!string, this._size.to!string);
    }
    
}
