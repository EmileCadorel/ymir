module ymir.dtarget.DAccess;
import ymir.dtarget._;


import std.format;

class DAccess : DExpression {

    private DExpression _who;

    private DExpression _where;

    this (DExpression who, DExpression where) {
	this._who = who;
	this._where = where;
    }

    override string toString () {
	return format ("%s [%s]", this._who.toString, this._where.toString);
    }
    
}
