module ymir.dtarget.DChar;
import ymir.dtarget._;

import std.format, std.conv;

class DChar : DExpression {

    private char _value;

    this (char value) {
	this._value = value;
    }

    override string toString () {
	return format ("cast (char) (%d)", this._value.to!ubyte);
    }
    
    
}
