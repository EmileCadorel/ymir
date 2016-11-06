module target.TLabel;
import target.TInst;
import std.outbuffer;
import std.conv, std.container;

class TLabel : TInst {

    private ulong _id;
    private Array!TInst _insts;
    
    this (ulong id) {
	this._id = id;
    }
    
    override string toString () {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("lbl%d :", this._id);
	foreach (it ; this._insts) {
	    buf.writefln ("%s", it.toString ());
	}
	return buf.toString ();
    }

}

