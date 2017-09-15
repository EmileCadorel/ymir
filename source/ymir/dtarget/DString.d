module ymir.dtarget.DString;
import ymir.dtarget._;

import std.format;

class DString : DExpression {

    private string _value;

    this (string value) {
	this._value = value;
    }

    override string toString () {
	return format ("\"%s\"", this._value);
    }

    
}
