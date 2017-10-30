module ymir.dtarget.DUnary;
import ymir.dtarget._;
import ymir.syntax._;

import std.format;

class DBefUnary : DExpression {

    private DExpression _expr;

    private Token _op;

    this (DExpression expr, Token op) {
	this._expr = expr;
	this._op = op;
    }

    override string toString () {
	return format ("(%s(%s))", this._op.descr, this._expr.toString);
    }   
} 


class DAfUnary : DExpression {

    private DExpression _expr;

    private Token _op;

    this (DExpression expr, Token op) {
	this._expr = expr;
	this._op = op;
    }

    override string toString () {
	return format ("((%s)%s)", this._expr.toString, this._op.descr);
    }   

} 

