module ymir.dtarget.DTemplate;
import ymir.dtarget._;

import std.format;

class DTemplate : DExpression {

    private DExpression _left;
    
    private DParamList _params;

    this (DExpression left, DParamList params) {
	this._left = left;
	this._params = params;
    }

    override string toString () {
	return format ("%s!(%s)", this._left.toString, this._params.toString);
    }        
}
