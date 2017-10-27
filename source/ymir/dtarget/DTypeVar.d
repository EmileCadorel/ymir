module ymir.dtarget.DTypeVar;
import ymir.dtarget._;

import std.format;

class DTypeVar {

    private DVar _var;

    private DType _type;

    private bool _isStatic;

    this (DType type, DVar var, bool isStatic = false) {
	this._var = var;
	this._type = type;
	this._isStatic = isStatic;
    }

    DVar var () {
	return this._var;
    }
    
    override string toString () {
	return format ("%s %s %s", this._isStatic ? "static" : "",
		       this._type.toString, this._var.toString);
    }
    
}
