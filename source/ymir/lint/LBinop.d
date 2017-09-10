module ymir.lint.LBinop;
import ymir.lint._;
import ymir.semantic._;
import ymir.syntax._;

import std.outbuffer, std.string, std.conv;

class LBinop : LExp {

    private LExp _left, _right;
    private LExp _res;
    private LSize _size = LSize.NONE;
    private Tokens _op;
    
    this (LExp left, LExp right, Tokens op, LSize size = LSize.NONE) {
	this._left = left;
	this._right = right;
	this._op = op;
	this._size = size;
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

    override LSize size () {
	if (this._size != LSize.NONE) return this._size;
	if (this._res !is null) return this._res.size;
	return this._left.size;
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

    private LSize _size;
    
    this (LExp left, LExp right, Tokens op, LSize size) {
	super (left, right, op);
	this._size = size;
    }

    override LSize size () {
	return this._size;
    }
    
}
