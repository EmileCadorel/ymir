module ymir.dtarget.DReturn;
import ymir.dtarget._;

import std.format;

class DReturn : DInstruction {

    private DExpression _expr;

    this (DExpression expr = null) {
	this._expr = expr;
    }
    
    override string toString () {
	if (this._expr)
	    return format ("return %s;", this._expr.toString);
	else return "return;";
    }
    

}
