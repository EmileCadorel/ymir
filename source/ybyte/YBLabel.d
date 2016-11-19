module ybyte.YBLabel;
import target.TLabel, target.TInstList;
import std.outbuffer;
import std.conv, std.container;

class YBLabel : TLabel {

    private ulong _id;
    private TInstList _insts;
    
    this (ulong id) {
	this._id = id;
    }

    ref TInstList insts () {
	return this._insts;
    }
    
    override string toString () {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("lbl[l_%d] :", this._id);
	buf.writefln ("%s", this._insts.toString ());
	return buf.toString ();
    }

}

