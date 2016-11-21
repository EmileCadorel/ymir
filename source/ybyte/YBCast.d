module ybyte.YBCast;
import target.TExp, target.TInst;
import syntax.Tokens, std.outbuffer, std.string;
import std.conv, ybyte.YBSize, std.stdio;

class YBCast : TInst {

    private TExp _left;
    private TExp _right;

    this (TExp left, TExp right) {
	this._left = left;
	this._right = right;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writefln ("\tcast:%s:%s\t%s, %s",
		      getSize (this._left.size).id,
		      getSize (this._right.size).id,
		      this._left.toString (),
		      this._right.toString ());
	return buf.toString ();
    }
    

}
