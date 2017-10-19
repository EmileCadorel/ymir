module ymir.dtarget.DNew;
import ymir.dtarget._;


import std.format;

class DNew : DExpression {

    private DExpression _what;

    private DExpression _size;
    
    this (DExpression what, DExpression size = null) {
	this._what = what;
	this._size = size;
    }

    override string toString () {
	if (!this._size) {
	    return format ("(cast (byte*) GC.malloc (%s.sizeof))", this._what.toString);
	} else {
	    return format ("(cast (%s) GC.malloc (%s))", this._what.toString, this._size.toString);
	}
    }
    
}


class DRealNew : DExpression {

    private DExpression _what;
    
    this (DExpression what) {
	this._what = what;
    }

    override string toString () {
	return format ("new %s", this._what.toString);
    }    
    
}
