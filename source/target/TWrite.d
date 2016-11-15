module target.TWrite;
import target.TInst, target.TExp;
import std.outbuffer, target.TSize;

class TWrite : TInst {

    private TExp _left;
    private TExp _right;

    this (TExp left, TExp right) {
	this._left = left;
	this._right = right;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writefln ("\tmove:%s\t%s, %s",
		      getSize (this._left.size).id,
		      this._left.toString (),
		      this._right.toString ());
	return buf.toString ();
    }
    
}
