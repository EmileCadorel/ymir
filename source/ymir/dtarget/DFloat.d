module ymir.dtarget.DFloat;
import ymir.dtarget._;
import ymir.lint._;

import std.conv;

class DFloat : DExpression {

    private double _value;

    this (double  value) {
	this._value = value;
    }
    
    override string toString () {
	return this._value.to!string;
    }    
    
}
