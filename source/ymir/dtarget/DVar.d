module ymir.dtarget.DVar;
import ymir.dtarget._;

import std.format;

class DVar : DExpression {

    private string _name;

    this (string name) {
	this._name = name;
    }

    string name () {
	return this._name;
    }
    
    override string toString () {
	return this._name;
    }    
}

class DAuxVar : DVar {

    private static ulong __last__ = 0;

    private ulong _id;
    
    this () {
	super (format ("__%d__", __last__));
	this._id = __last__;
	__last__ ++;
    }

    static void reset () {
	__last__ = 0;
    }
    
}
