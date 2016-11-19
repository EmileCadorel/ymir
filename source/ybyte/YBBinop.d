module ybyte.YBBinop;
import target.TExp, target.TInst;
import syntax.Tokens, std.outbuffer, std.string;
import std.conv, ybyte.YBSize, std.stdio;

class YBBinop : TInst {

    private TExp _left;
    private TExp _right;
    private TExp _res;
    private Tokens _op;

    this (Tokens op, TExp left, TExp right, TExp res) {
	this._op = op;
	this._left = left;
	this._right = right;
	this._res = res;
    }

    override string toString () {
	OutBuffer buf = new OutBuffer ();
	buf.writefln ("\t%s:%s\t%s, %s, %s",
		      toLower (to!string (this._op)),
		      getSize (this._left.size).id,
		      this._left.toString (),
		      this._right.toString (),
		      this._res.toString ());
	return buf.toString ();
    }
    
}
