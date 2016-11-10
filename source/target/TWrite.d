module target.TWrite;
import target.TInst, target.TExp;
import std.outbuffer;

class TWrite : TInst {

    private TExp _left;
    private TExp _right;

    this (TExp left, TExp right) {
	this._left = left;
	this._right = right;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writefln ("\tmove\t%s, %s",
		    this._left.toString (),
		    this._right.toString ());
	return buf.toString ();
    }
    
}
