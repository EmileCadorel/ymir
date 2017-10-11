module ymir.dtarget.DNew;
import ymir.dtarget._;


import std.format;

class DNew : DExpression {

    private DExpression _what;

    this (DExpression what) {
	this._what = what;
    }

    override string toString () {
	return format ("new %s", this._what.toString);
    }
    
}

