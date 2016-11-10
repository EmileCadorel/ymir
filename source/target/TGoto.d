module target.TGoto;
import target.TInst;
import std.conv;

class TGoto : TInst {

    private ulong _id;
    
    this (ulong id) {
	this._id = id;
    }

    override string toString () {
	return "\tgoto\t" ~ to!string (this._id) ~ "\n";
    }
    
}
