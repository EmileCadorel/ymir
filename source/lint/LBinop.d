module lint.LBinop;
import lint.LExp;
import semantic.types.InfoType, syntax.Tokens;
import std.outbuffer, std.string, std.conv;

class LBinop : LExp {

    private LExp _left, _right;
    private LExp _res;
    private Tokens _op;
    
    this (LExp left, LExp right, Tokens op) {
	this._left = left;
	this._right = right;
	this._op = op;
    }

    this (LExp left, LExp right, LExp res, Tokens op) {
	this (left, right, op);
	this._res = res;
    }

    LExp left () {
	return this._left;
    }

    LExp right () {
	return this._right;
    }	

    LExp res () {
	return this._res;
    }
    
    Tokens op () {
	return this._op;
    }

    override bool isInst () {
	return this._res !is null;
    }
    
    override string toString () {
	if (this._res is null) {
	    return "("
		~ this._left.toString ()
		~ this._op.descr
		~ this._right.toString ()
		~ ")";
	} else {
	    OutBuffer buf = new OutBuffer ();
	    buf.writefln ("%s := %s %s %s",
			  this._res.toString (),
			  this._left.toString (),
			  this._op.descr,
			  this._right.toString ());
	    return buf.toString ();
	}
    }
    
}

class LBinopSized : LBinop {

    private int _size;
    
    this (LExp left, LExp right, Tokens op, int size) {
	super (left, right, op);
	this._size = size;
    }

    int size () {
	return this._size;
    }
    
}
