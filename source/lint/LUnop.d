module lint.LUnop;
import lint.LExp, lint.LSize;
import semantic.types.InfoType, syntax.Tokens;
import std.outbuffer, std.string, std.conv;


class LUnop : LExp {
    private LExp _elem;
    private Tokens _op;


    this (LExp elem, Tokens op) {
	this._elem = elem;
	this._op = op;
    }

    LExp elem () {
	return this._elem;
    }

    Tokens op () {
	return this._op;
    }

    override LSize size () {
	return this._elem.size ;
    }
    
    override bool isInst () {
	return false;
    }

    override string toString () {
	return this._op.descr ~ " " ~ this._elem.toString ();
    }

    
}
