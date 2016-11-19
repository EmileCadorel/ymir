module ybyte.YBParams;
import target.TExp, target.TInst;
import std.outbuffer, ybyte.YBSize;

class YBParams : TInst {
    
    private TExp _what;

    this (TExp what) {
	this._what = what;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writefln ("\tparam:%s\t%s",
		      getSize (this._what.size).id,
		      this._what.toString ());
	
	return buf.toString ();
    }
    
}
