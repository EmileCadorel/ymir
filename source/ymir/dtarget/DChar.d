module ymir.dtarget.DChar;
import ymir.dtarget._;

import std.format;

class DChar : DExpression {

    private char _value;

    this (char value) {
	this._value = value;
    }

    override string toString () {
	return format ("'%c'", this._value);
    }
    
    
}
