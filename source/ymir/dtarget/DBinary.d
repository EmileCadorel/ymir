module ymir.dtarget.DBinary;
import ymir.dtarget._;
import ymir.syntax._;

import std.format;

class DBinary : DExpression {

    private DExpression _left;

    private DExpression _right;

    private Token _op;

    this (DExpression left, DExpression right, Token op) {
	this._left = left;
	this._right = right;
	this._op = op;
    }

    DExpression left () {
	return this._left;
    }

    DExpression right () {
	return this._right;
    }

    Token op () {
	return this._op;
    }
    
    override string toString () {
	string l, r;
	if (cast (DBinary) this._left) l = format ("(%s)", this._left.toString);
	else l = this._left.toString;
	
	if (cast (DBinary) this._right) r = format ("(%s)", this._right.toString);
	else r = this._right.toString;
	
	return format ("%s %s %s", l, this._op.descr, r);
    }
    

}
