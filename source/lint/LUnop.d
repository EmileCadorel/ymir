module lint.LUnop;
import lint.LExp, lint.LSize;
import semantic.types.InfoType, syntax.Tokens;
import std.outbuffer, std.string, std.conv;


class LUnop : LExp {
    private LExp _elem;
    private Tokens _op;
    private bool _modify;
    

    this (LExp elem, Tokens op, bool modify = false) {
	this._elem = elem;
	this._op = op;
	this._modify = modify;
    }
    
    LExp elem () {
	return this._elem;
    }

    Tokens op () {
	return this._op;
    }

    bool modify () {
	return this._modify;
    }
    
    override LSize size () {
	return this._elem.size ;
    }
    
    override bool isInst () {
	if (this._op == Tokens.DPLUS || this._op == Tokens.DMINUS)
	    return true;
	return false;
    }

    override string toString () {
	if (this._op == Tokens.DPLUS || this._op == Tokens.DMINUS)
	    return this._op.descr ~ " " ~ this._elem.toString () ~ "\n";
	else
	    return this._op.descr ~ " " ~ this._elem.toString ();
    }

    
}
