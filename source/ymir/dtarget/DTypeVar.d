module ymir.dtarget.DTypeVar;
import ymir.dtarget._;

import std.format;

class DTypeVar {

    private DVar _var;

    private DType _type;

    this (DType type, DVar var) {
	this._var = var;
	this._type = type;
    }
    
    override string toString () {
	return format ("%s %s", this._type.toString, this._var.toString);
    }
    
}
