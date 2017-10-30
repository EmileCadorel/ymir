module ymir.dtarget.DDot;
import ymir.dtarget._;


import std.format;

class DDot : DExpression {

    private DExpression _who;

    private DExpression _where;

    this (DExpression who, DVar where) {
	this._who = who;
	this._where = where;
    }

    this (DExpression who, DDot where) {
	this._who = who;
	this._where = where;
    }

    ref DExpression who () {
	return this._who;
    }
    
    DExpression where () {
	return this._where;
    }

    private string toSimpleString () {
	if (auto d = cast (DDot) this._where) {
	    return format ("%s.%s", this._who, d.toSimpleString);
	} else 
	    return format ("%s.%s", this._who.toString, this._where.toString);
    }

    override string toString () {
	if (auto d = cast (DDot) this._where) {
	    return format ("(%s).%s", this._who, d.toSimpleString);
	} else 
	    return format ("(%s).%s", this._who.toString, this._where.toString);
    }
    
}
