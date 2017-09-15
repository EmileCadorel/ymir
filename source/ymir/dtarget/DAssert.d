module ymir.dtarget.DAssert;
import ymir.dtarget._;

import std.format;

class DAssert : DInstruction {

    private DExpression _val;
    
    private DExpression _msg;

    this (DExpression value, DExpression msg) {
	this._val = value;
	this._msg = msg;
    }
    
    override string toString () {
	if (this._msg)
	    return format ("assert (%s, %s);", this._val.toString, this._msg.toString);
	else return format ("assert (%s);", this._val.toString);
    }
    
}
