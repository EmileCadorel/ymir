module ymir.dtarget.DAccess;
import ymir.dtarget._;


import std.format;

class DAccess : DExpression {

    private DExpression _who;

    private DExpression _where;

    private DExpression _sec;

    this (DExpression who, DExpression where, DExpression sec = null) {
	this._who = who;
	this._where = where;
	this._sec = sec;
    }

    DExpression where () {
	return this._where;
    }
    
    override string toString () {
	if (!this._sec)
	    return format ("%s [%s]", this._who.toString, this._where.toString);
	else
	    return format ("%s [%s .. %s]", this._who.toString, this._where.toString, this._sec.toString);
    }
    
}
