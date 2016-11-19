module ybyte.YBGoto;
import target.TInst;
import std.conv;

class YBGoto : TInst {

    private ulong _id;
    
    this (ulong id) {
	this._id = id;
    }

    override string toString () {
	return "\tgoto\tl_" ~ to!string (this._id) ~ "\n";
    }
    
}
