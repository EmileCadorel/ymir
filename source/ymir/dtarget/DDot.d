module ymir.dtarget.DDot;
import ymir.dtarget._;


import std.format;

class DDot : DExpression {

    private DExpression _who;

    private DVar _where;

    this (DExpression who, DVar where) {
	this._who = who;
	this._where = where;
    }

    override string toString () {
	return format ("%s.%s", this._who.toString, this._where.toString);
    }
    
}
