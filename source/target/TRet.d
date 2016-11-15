module target.TRet;
import target.TInst, target.TExp;
import std.outbuffer, target.TSize;

class TRet : TInst {

    private TExp _exp;
    
    this (TExp exp) {
	this._exp = exp;
    }

    this () {
	this (null);
    }

    override string toString () {
	OutBuffer buf = new OutBuffer ();
	if (this._exp !is null) {
	    buf.writefln ("\tret:%s %s",
			  getSize (this._exp.size).id,
			  this._exp.toString ());
	} else buf.writefln ("\tret");
	return buf.toString ();
    }    
    
}


